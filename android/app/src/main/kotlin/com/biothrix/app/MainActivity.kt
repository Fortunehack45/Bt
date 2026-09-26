package com.biothrix.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), SensorEventListener {
    private val SHORTCUTS_CHANNEL = "com.biothrix.app/shortcuts"
    private val NOTIFICATIONS_CHANNEL = "com.biothrix.app/notifications"
    private val PREFERENCES_CHANNEL = "com.biothrix.app/preferences"
    private val PEDOMETER_CHANNEL = "com.biothrix.app/pedometer"
    private val NOTIFICATION_CHANNEL_ID = "wellnest_alerts"

    private var initialAction: String? = null
    private var methodChannel: MethodChannel? = null
    private var pedometerChannel: MethodChannel? = null

    // Hardware Sensor Properties
    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null
    private var isUsingStepDetector = false
    private var lastAccelMagnitude = 0.0f
    private var lastStepTimestamp = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ensure edge-to-edge window drawing behind navigation and status bars
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }

        createNotificationChannel()
        initHardwareSensors()

        // Handle app shortcut intent actions
        intent?.action?.let { action ->
            if (action.startsWith("com.biothrix.app.ACTION_")) {
                initialAction = action
            }
        }
    }

    private fun initHardwareSensors() {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        val detector = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (detector != null) {
            stepSensor = detector
            isUsingStepDetector = true
        } else {
            val counter = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
            if (counter != null) {
                stepSensor = counter
                isUsingStepDetector = false
            } else {
                accelerometerSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Wellnest Health Alerts"
            val descriptionText = "Real-time clinical vitals, hydration reminders and cycle insights"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
                setShowBadge(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.action?.let { action ->
            if (action.startsWith("com.biothrix.app.ACTION_")) {
                methodChannel?.invokeMethod("onShortcutAction", action)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1. Shortcuts Channel
        val sChannel = MethodChannel(messenger, SHORTCUTS_CHANNEL)
        methodChannel = sChannel
        sChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialAction" -> {
                    result.success(initialAction)
                    initialAction = null
                }
                else -> result.notImplemented()
            }
        }

        // 2. Real System Notifications Channel
        val nChannel = MethodChannel(messenger, NOTIFICATIONS_CHANNEL)
        nChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotification" -> {
                    val id = call.argument<Int>("id") ?: System.currentTimeMillis().toInt()
                    val title = call.argument<String>("title") ?: "Wellnest Alert"
                    val body = call.argument<String>("body") ?: ""

                    try {
                        val notificationIntent = Intent(context, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        } else {
                            PendingIntent.FLAG_UPDATE_CURRENT
                        }
                        val pendingIntent = PendingIntent.getActivity(context, id, notificationIntent, pendingFlags)

                        val builder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(title)
                            .setContentText(body)
                            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setDefaults(Notification.DEFAULT_ALL)
                            .setAutoCancel(true)
                            .setContentIntent(pendingIntent)

                        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager.notify(id, builder.build())
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("NOTIFICATION_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 3. Persistent Key-Value Preferences Channel (SharedPreferences)
        val pChannel = MethodChannel(messenger, PREFERENCES_CHANNEL)
        pChannel.setMethodCallHandler { call, result ->
            val prefs = context.getSharedPreferences("wellnest_prefs", Context.MODE_PRIVATE)
            val key = call.argument<String>("key")

            if (key == null) {
                result.error("INVALID_KEY", "Key cannot be null", null)
                return@setMethodCallHandler
            }

            when (call.method) {
                "getBool" -> {
                    val defVal = call.argument<Boolean>("defaultValue") ?: false
                    result.success(prefs.getBoolean(key, defVal))
                }
                "setBool" -> {
                    val value = call.argument<Boolean>("value") ?: false
                    prefs.edit().putBoolean(key, value).apply()
                    result.success(true)
                }
                "getString" -> {
                    val defVal = call.argument<String>("defaultValue")
                    result.success(prefs.getString(key, defVal))
                }
                "setString" -> {
                    val value = call.argument<String>("value")
                    prefs.edit().putString(key, value).apply()
                    result.success(true)
                }
                "getInt" -> {
                    val defVal = call.argument<Int>("defaultValue") ?: 0
                    result.success(prefs.getInt(key, defVal))
                }
                "setInt" -> {
                    val value = call.argument<Int>("value") ?: 0
                    prefs.edit().putInt(key, value).apply()
                    result.success(true)
                }
                "remove" -> {
                    prefs.edit().remove(key).apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 4. Onboard Device Hardware Pedometer Channel
        val pedChannel = MethodChannel(messenger, PEDOMETER_CHANNEL)
        pedometerChannel = pedChannel
        pedChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isStepCountingAvailable" -> {
                    val available = stepSensor != null || accelerometerSensor != null
                    result.success(available)
                }
                "startStepTracking" -> {
                    val sensorToListen = stepSensor ?: accelerometerSensor
                    if (sensorToListen != null && sensorManager != null) {
                        sensorManager?.registerListener(this, sensorToListen, SensorManager.SENSOR_DELAY_UI)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stopStepTracking" -> {
                    sensorManager?.unregisterListener(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        when (event.sensor.type) {
            Sensor.TYPE_STEP_DETECTOR -> {
                // Hardware step detector fires a 1.0 event per discrete step
                if (event.values.isNotEmpty() && event.values[0] > 0.0f) {
                    pedometerChannel?.invokeMethod("onStepDetected", 1)
                }
            }
            Sensor.TYPE_STEP_COUNTER -> {
                // Returns step count since device reboot
                pedometerChannel?.invokeMethod("onStepDetected", 1)
            }
            Sensor.TYPE_ACCELEROMETER -> {
                // Fallback high-fidelity dynamic peak detector for phones lacking dedicated step coprocessors
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val magnitude = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()
                val now = System.currentTimeMillis()

                // Walking motion produces acceleration peaks > 11.6 m/s^2 with >= 280ms human refractory period
                if (magnitude > 11.6f && lastAccelMagnitude <= 11.6f && (now - lastStepTimestamp) > 280L) {
                    lastStepTimestamp = now
                    pedometerChannel?.invokeMethod("onStepDetected", 1)
                }
                lastAccelMagnitude = magnitude
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        sensorManager?.unregisterListener(this)
        super.onDestroy()
    }
}
