package com.nanisamireddy.later

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Short, foreground dictation sessions. Android's service owns the microphone. */
class NativeSpeechBridge(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "later/speech")
    private val packs = NativeSpeechPacks(activity)
    private val handler = Handler(Looper.getMainLooper())
    private var recognizer: SpeechRecognizer? = null
    private var generation = 0
    private var running = false
    private var stopping: MethodChannel.Result? = null
    private var onDevice = true
    private var language = "en-IN"
    private var emptyTurns = 0
    private var utterance = 0

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "languageSupport", "downloadLanguage" -> packs.request(call.method, call.argument<String>("language") ?: "en-IN", result)
                "start" -> {
                    cancel()
                    if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        result.error("permission", "Allow microphone access or type your note.", null)
                    } else {
                        generation = call.argument<Int>("generation") ?: 0
                        language = call.argument<String>("language") ?: "en-IN"
                        onDevice = call.argument<Boolean>("allowOnline") != true && Build.VERSION.SDK_INT >= 31 && SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)
                        if (!onDevice && call.argument<Boolean>("allowOnline") != true) {
                            result.error("unavailable", "On-device recognition is unavailable. You can enable the system online service below or type your note.", null)
                        } else if (!onDevice && !SpeechRecognizer.isRecognitionAvailable(activity)) {
                            result.error("unavailable", "No speech service is installed. Enable Speech Recognition & Synthesis in Android settings or type your note.", null)
                        } else {
                            try {
                                recognizer = if (onDevice && Build.VERSION.SDK_INT >= 31) SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
                                    else SpeechRecognizer.createSpeechRecognizer(activity)
                                running = true
                                emptyTurns = 0
                                listen()
                                result.success(null)
                            } catch (_: Exception) {
                                cancel()
                                result.error("unavailable", "Could not start the Android speech service. Check device speech settings and retry.", null)
                            }
                        }
                    }
                }
                "stop" -> {
                    if (!running) result.success(null)
                    else {
                        running = false
                        stopping = result
                        handler.removeCallbacksAndMessages(null)
                        try { recognizer?.stopListening() } catch (_: Exception) { finishStop() }
                        handler.postDelayed({ finishStop() }, 2000)
                    }
                }
                "cancel" -> { cancel(); packs.dispose(); result.success(null) }
                else -> result.notImplemented()
            }
        }
    }

    private fun event(type: String, vararg values: Pair<String, Any>) {
        channel.invokeMethod("event", mapOf("type" to type, "generation" to generation) + values)
    }

    private fun listen() {
        if (!running) return
        val turn = ++utterance
        recognizer?.setRecognitionListener(object : RecognitionListener {
            private var terminal = false
            private fun valid() = !terminal && turn == utterance && (running || stopping != null)
            override fun onReadyForSpeech(params: Bundle?) { if (valid()) event("ready", "onDevice" to onDevice) }
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) { if (valid()) event("level", "level" to ((rmsdB + 2) / 12).coerceIn(0f, 1f).toDouble()) }
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onPartialResults(results: Bundle?) {
                if (valid()) event("partial", "text" to text(results))
            }
            override fun onResults(results: Bundle?) {
                if (!valid()) return
                terminal = true
                val value = text(results)
                if (value.isNotEmpty()) emptyTurns = 0 else emptyTurns++
                event("final", "text" to value)
                if (stopping != null) finishStop() else restart()
            }
            override fun onError(error: Int) {
                if (!valid()) return
                terminal = true
                if (stopping != null) { finishStop(); return }
                if (error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT) {
                    emptyTurns++
                    if (emptyTurns < 2) { restart(); return }
                }
                running = false
                val message = when (error) {
                    SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED, SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE ->
                        "This language is unavailable for on-device recognition. Install its speech pack in Android settings, choose another language, or enable the system online service."
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Allow microphone access in Android settings or type your note."
                    SpeechRecognizer.ERROR_NETWORK, SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "The speech service could not connect. Check your connection and retry."
                    SpeechRecognizer.ERROR_NO_MATCH, SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech detected. Your words are kept; tap the microphone to resume."
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "The microphone or speech service is busy. Close other voice apps and retry."
                    else -> "Android speech recognition stopped. Your words are kept; tap the microphone to retry."
                }
                event("error", "message" to message)
                release()
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            .putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            .putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        recognizer?.startListening(intent)
    }

    private fun text(bundle: Bundle?) = bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: ""
    private fun restart() {
        // Never busy-loop on silence, errors, cancellation or backgrounding.
        if (running) handler.postDelayed({
            try { listen() } catch (_: Exception) {
                running = false
                event("error", "message" to "Could not resume Android speech recognition. Your words are kept; tap the microphone to retry.")
                release()
            }
        }, 350)
    }
    private fun release() {
        utterance++
        recognizer?.cancel()
        recognizer?.destroy()
        recognizer = null
    }
    private fun finishStop() {
        handler.removeCallbacksAndMessages(null)
        val pending = stopping
        stopping = null
        release()
        pending?.success(null)
    }
    fun cancel() {
        running = false
        finishStop()
    }
    fun dispose() { cancel(); packs.dispose(); channel.setMethodCallHandler(null) }
}
