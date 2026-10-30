package com.senay.voice_notes

import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.senay.voice_notes/device",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidRuntime" -> result.success(
                    mapOf(
                        "abi" to android.os.Build.SUPPORTED_ABIS.firstOrNull().orEmpty(),
                        "is64Bit" to Process.is64Bit(),
                    ),
                )
                else -> result.notImplemented()
            }
        }
    }
}
