package com.nanisamireddy.later

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class LaterWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        update(context, manager, ids)
    }
    companion object {
        fun update(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val preferences = context.getSharedPreferences("later_widget", Context.MODE_PRIVATE)
            val items = org.json.JSONArray(preferences.getString("items", "[]") ?: "[]")
            var next: org.json.JSONObject? = null
            for (i in 0 until items.length()) {
                val item = items.getJSONObject(i)
                val time = item.optLong("time")
                if (time > System.currentTimeMillis() && (next == null || time < next!!.optLong("time"))) next = item
            }
            val upcoming = next?.let {
                it.optString("title") + "\n" + java.text.DateFormat.getDateTimeInstance(java.text.DateFormat.SHORT, java.text.DateFormat.SHORT).format(java.util.Date(it.optLong("time")))
            } ?: if (preferences.contains("items")) "No upcoming reminders" else "Open Later to see what’s coming up"
            for (id in ids) {
                val views = RemoteViews(context.packageName, R.layout.later_widget)
                views.setTextViewText(R.id.widget_greeting, preferences.getString("greeting", "later."))
                views.setTextViewText(R.id.widget_upcoming, upcoming)
                for ((view, action) in listOf(R.id.widget_add to "add", R.id.widget_upcoming to "upcoming")) {
                    val intent = Intent(context, MainActivity::class.java).apply {
                        this.action = Intent.ACTION_MAIN
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        putExtra("later_widget_action", action)
                    }
                    val pending = PendingIntent.getActivity(context, id * 2 + if (action == "add") 0 else 1, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                    views.setOnClickPendingIntent(view, pending)
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}
