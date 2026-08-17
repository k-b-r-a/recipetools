package com.example.recipetools

import android.media.Ringtone
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.recipetools/alarm"
    private var ringtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSystemAlarm" -> {
                    try {
                        if (ringtone == null) {
                            var alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                            if (alarmUri == null) {
                                alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                            }
                            ringtone = RingtoneManager.getRingtone(applicationContext, alarmUri)
                        }
                        if (ringtone != null && !ringtone!!.isPlaying) {
                            ringtone!!.play()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ALARM_ERROR", e.localizedMessage, null)
                    }
                }
                "stopSystemAlarm" -> {
                    try {
                        if (ringtone != null && ringtone!!.isPlaying) {
                            ringtone!!.stop()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ALARM_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
