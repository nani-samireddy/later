package com.nanisamireddy.later

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private var speechBridge: NativeSpeechBridge? = null
    private var widgetChannel: io.flutter.plugin.common.MethodChannel? = null
    override fun configureFlutterEngine(engine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(engine)
        speechBridge = NativeSpeechBridge(this, engine.dartExecutor.binaryMessenger)
        widgetChannel = io.flutter.plugin.common.MethodChannel(engine.dartExecutor.binaryMessenger, "later/home_widget").also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumeAction" -> {
                        val action = intent.getStringExtra("later_widget_action")
                        intent.removeExtra("later_widget_action")
                        result.success(action)
                    }
                    "update" -> {
                        getSharedPreferences("later_widget", MODE_PRIVATE).edit()
                            .putString("greeting", call.argument<String>("greeting"))
                            .putString("upcoming", call.argument<String>("upcoming"))
                            .putString("items", org.json.JSONArray(call.argument<List<Map<String, Any>>>("items") ?: emptyList<Map<String, Any>>()).toString()).apply()
                        val manager = android.appwidget.AppWidgetManager.getInstance(this)
                        LaterWidgetProvider.update(this, manager, manager.getAppWidgetIds(android.content.ComponentName(this, LaterWidgetProvider::class.java)))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        speechBridge?.dispose()
        super.onDestroy()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val rejected = rejectUnreadableShare(intent)
        super.onCreate(savedInstanceState)
        if (rejected) showShareError()
    }

    override fun onNewIntent(intent: Intent) {
        val rejected = rejectUnreadableShare(intent)
        super.onNewIntent(intent)
        intent.getStringExtra("later_widget_action")?.let { action ->
            widgetChannel?.invokeMethod("action", action)
            intent.removeExtra("later_widget_action")
        }
        if (rejected) showShareError()
    }

    // The sharing plugin opens the URI during Activity attachment/onNewIntent.
    // A revoked or missing read grant otherwise throws before Dart can handle it.
    private fun rejectUnreadableShare(incoming: Intent): Boolean {
        if (incoming.action != Intent.ACTION_SEND ||
            incoming.type?.startsWith("image/") != true) return false
        val readable = try {
            val uri = if (Build.VERSION.SDK_INT >= 33) {
                incoming.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                incoming.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            }
            uri != null && contentResolver.openInputStream(uri).use { it != null }
        } catch (_: Exception) {
            false
        }
        if (readable) {
            // The URI grant is already attached to this Activity. Keep the
            // EXTRA_STREAM and MIME type, but consume share data so Flutter
            // does not also interpret the image URI as a navigation route.
            incoming.setDataAndType(null, incoming.type)
            return false
        }
        incoming.removeExtra(Intent.EXTRA_STREAM)
        incoming.clipData = null
        incoming.data = null
        incoming.action = Intent.ACTION_MAIN
        return true
    }

    private fun showShareError() {
        Toast.makeText(this, "Could not read the shared image. Share it again from Photos.", Toast.LENGTH_LONG).show()
    }
}
