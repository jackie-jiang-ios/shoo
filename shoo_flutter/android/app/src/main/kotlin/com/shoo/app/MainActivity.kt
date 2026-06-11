package com.shoo.app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.shoo.app/platform"
    private val WATCH_CHANNEL = "com.shoo.app/watch"
    private val BACKGROUND_CHANNEL = "com.shoo.app/background"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 主平台通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isUltrasonicSupported" -> result.success(true)
                    "playUltrasonic" -> {
                        // TODO: 实现超声波播放
                        result.success(false)
                    }
                    "stopUltrasonic" -> {
                        // TODO: 实现停止超声波
                        result.success(null)
                    }
                    "startBackgroundService" -> {
                        // TODO: 实现后台播放服务启动
                        result.success(false)
                    }
                    "stopBackgroundService" -> {
                        // TODO: 实现后台播放服务停止
                        result.success(null)
                    }
                    "getDeviceMaxVolume" -> result.success(1.0)
                    "setDeviceVolume" -> result.success(null)
                    "requestPermissions" -> result.success(true)
                    "checkPermissions" -> result.success(true)
                    else -> result.notImplemented()
                }
            }

        // 手表通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WATCH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isWatchConnected" -> result.success(false)
                    "sendCommand" -> result.success(false)
                    else -> result.notImplemented()
                }
            }

        // 后台播放通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startBackgroundPlayback" -> {
                        // TODO: 实现前台通知
                        result.success(false)
                    }
                    "updateNotification" -> result.success(null)
                    "stopBackgroundPlayback" -> result.success(null)
                    "isBackgroundPlaybackRunning" -> result.success(false)
                    else -> result.notImplemented()
                }
            }
    }
}
