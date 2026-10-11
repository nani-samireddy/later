package com.nanisamireddy.later

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.*
import io.flutter.plugin.common.MethodChannel

/** Queries/downloads language support without recording microphone audio. */
class NativeSpeechPacks(private val activity: Activity) {
    private val handler = Handler(Looper.getMainLooper())
    private var recognizer: SpeechRecognizer? = null
    private var pending: ((Map<String, Any>) -> Unit)? = null

    fun request(method: String, language: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33 || !SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)) {
            result.success(mapOf("status" to "unavailable", "message" to "This device cannot manage on-device speech packs. Choose another language or allow online recognition."))
            return
        }
        if (pending != null) {
            result.error("busy", "A language pack request is already running.", null)
            return
        }
        var completed = false
        val finish: (Map<String, Any>) -> Unit = { value ->
            if (!completed) {
                completed = true
                pending = null
                handler.removeCallbacksAndMessages(null)
                result.success(value)
            }
        }
        try {
            if (recognizer == null) {
                recognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
                recognizer?.setRecognitionListener(object : RecognitionListener {
                    override fun onReadyForSpeech(params: Bundle?) {}
                    override fun onBeginningOfSpeech() {}
                    override fun onRmsChanged(rmsdB: Float) {}
                    override fun onBufferReceived(buffer: ByteArray?) {}
                    override fun onEndOfSpeech() {}
                    override fun onError(error: Int) {}
                    override fun onResults(results: Bundle?) {}
                    override fun onPartialResults(results: Bundle?) {}
                    override fun onEvent(eventType: Int, params: Bundle?) {}
                })
            }
            pending = finish
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                .putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            if (method == "languageSupport") {
                handler.postDelayed({ finish(mapOf("status" to "unknown", "message" to "Android did not report language support. Choose another language or allow online recognition.")) }, 8000)
                recognizer?.checkRecognitionSupport(intent, activity.mainExecutor, object : RecognitionSupportCallback {
                    override fun onSupportResult(support: RecognitionSupport) {
                        finish(mapOf(
                            "status" to "checked",
                            "installed" to support.installedOnDeviceLanguages,
                            "pending" to support.pendingOnDeviceLanguages,
                            "supported" to support.supportedOnDeviceLanguages
                        ))
                    }
                    override fun onError(error: Int) {
                        finish(mapOf("status" to "unknown", "message" to "Android could not report installed language packs. Choose another language or allow online recognition."))
                    }
                })
            } else if (Build.VERSION.SDK_INT >= 34) {
                // Scheduling is not completion. The UI explicitly asks users to recheck.
                handler.postDelayed({ finish(mapOf("status" to "requested")) }, 15000)
                recognizer?.triggerModelDownload(intent, activity.mainExecutor, object : ModelDownloadListener {
                    override fun onProgress(progress: Int) {}
                    override fun onSuccess() { finish(mapOf("status" to "installed")) }
                    override fun onScheduled() { finish(mapOf("status" to "scheduled")) }
                    override fun onError(error: Int) {
                        if (error == SpeechRecognizer.ERROR_CANNOT_LISTEN_TO_DOWNLOAD_EVENTS) {
                            recognizer?.triggerModelDownload(intent)
                            finish(mapOf("status" to "requested"))
                        } else {
                            finish(mapOf("status" to "failed", "message" to "Android could not download this language pack. It may be unsupported; check your connection, choose another language, or allow online recognition."))
                        }
                    }
                })
            } else {
                recognizer?.triggerModelDownload(intent)
                finish(mapOf("status" to "requested"))
            }
        } catch (_: Exception) {
            finish(mapOf("status" to "failed", "message" to "Android could not manage this language pack. Choose another language or allow online recognition."))
        }
    }

    fun dispose() {
        pending?.invoke(mapOf("status" to "cancelled"))
        handler.removeCallbacksAndMessages(null)
        recognizer?.destroy()
        recognizer = null
    }
}
