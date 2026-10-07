package com.wellnest.vitality.health

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * High-reliability Persistent Background Step Tracking Foreground Service.
 * Survives when the user closes the app, swipes it out of the Recent Apps list,
 * or locks the screen, guaranteeing continuous physical footstep counting.
 */
class StepTrackingService : Service(), SensorEventListener {

    companion object {
        const val CHANNEL_ID = "wellnest_step_tracker_channel"
        const val NOTIFICATION_ID = 9001
        const val PREFS_NAME = "wellnest_prefs"
        const val KEY_PERSISTENT_STEPS = "wellnest_persistent_steps"
        const val KEY_LAST_HARDWARE_COUNTER = "wellnest_last_hardware_counter"
        const val KEY_STEP_DATE = "wellnest_step_date"
        const val ACTION_START_TRACKING = "com.wellnest.vitality.health.action.START_TRACKING"
        const val ACTION_STOP_TRACKING = "com.wellnest.vitality.health.action.STOP_TRACKING"

        @Volatile
        var isServiceRunning = false
            private set
    }

    private var sensorManager: SensorManager? = null
    private var stepCounterSensor: Sensor? = null
    private var stepDetectorSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null

    private var lastHardwareCounter = -1.0f
    private var lastAccelMagnitude = 9.81f
    private var lastStepTimestamp = 0L

    private lateinit var prefs: SharedPreferences

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager

        createNotificationChannel()
        val notification = buildOngoingNotification(getTodaySteps())
        startForeground(NOTIFICATION_ID, notification)

        initSensors()
        isServiceRunning = true
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Active Step Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps pedometer step counting active in the background when the app is closed"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            nm?.createNotificationChannel(channel)
        }
    }

    private fun buildOngoingNotification(currentSteps: Int): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val text = if (currentSteps > 0) {
            "$currentSteps steps tracked today • Live background pedometer active"
        } else {
            "Active pedometer tracking steps in background"
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Wellnest • Health Pedometer")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun initSensors() {
        val sm = sensorManager ?: return
        stepCounterSensor = sm.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        stepDetectorSensor = sm.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        accelerometerSensor = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        var registered = false
        if (stepCounterSensor != null) {
            val ok = sm.registerListener(this, stepCounterSensor, SensorManager.SENSOR_DELAY_NORMAL)
            if (ok) registered = true
        }
        if (stepDetectorSensor != null) {
            val ok = sm.registerListener(this, stepDetectorSensor, SensorManager.SENSOR_DELAY_NORMAL)
            if (ok) registered = true
        }
        if (!registered && accelerometerSensor != null) {
            sm.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_TRACKING) {
            stopSelf()
            return START_NOT_STICKY
        }

        // START_STICKY ensures Android recreates this service if killed by OS memory pressure
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        checkAndResetForNewDay()

        when (event.sensor.type) {
            Sensor.TYPE_STEP_COUNTER -> {
                val currentTotal = event.values[0]
                if (lastHardwareCounter < 0.0f) {
                    val savedHardware = prefs.getFloat(KEY_LAST_HARDWARE_COUNTER, -1.0f)
                    if (savedHardware > 0.0f && currentTotal >= savedHardware) {
                        val delta = (currentTotal - savedHardware).toInt()
                        if (delta > 0) {
                            addSteps(delta)
                        }
                    }
                    lastHardwareCounter = currentTotal
                    prefs.edit().putFloat(KEY_LAST_HARDWARE_COUNTER, currentTotal).apply()
                } else {
                    val delta = (currentTotal - lastHardwareCounter).toInt()
                    if (delta > 0) {
                        lastHardwareCounter = currentTotal
                        prefs.edit().putFloat(KEY_LAST_HARDWARE_COUNTER, currentTotal).apply()
                        addSteps(delta)
                    }
                }
            }
            Sensor.TYPE_STEP_DETECTOR -> {
                if (event.values.isNotEmpty() && event.values[0] > 0.0f) {
                    addSteps(1)
                }
            }
            Sensor.TYPE_ACCELEROMETER -> {
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val magnitude = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()
                val now = System.currentTimeMillis()

                if (magnitude > 11.0f && lastAccelMagnitude <= 11.0f && (now - lastStepTimestamp) in 260L..1800L) {
                    lastStepTimestamp = now
                    addSteps(1)
                } else if (lastStepTimestamp == 0L && magnitude > 11.0f) {
                    lastStepTimestamp = now
                    addSteps(1)
                }
                lastAccelMagnitude = magnitude
            }
        }
    }

    private fun addSteps(count: Int) {
        if (count <= 0) return
        val currentSteps = getTodaySteps() + count
        prefs.edit().putInt(KEY_PERSISTENT_STEPS, currentSteps).apply()

        // Update ongoing notification
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.notify(NOTIFICATION_ID, buildOngoingNotification(currentSteps))

        // Notify active Flutter instance if MainActivity is currently in memory
        MainActivity.dispatchStepDetectedToFlutter(count)
    }

    private fun getTodaySteps(): Int {
        checkAndResetForNewDay()
        return prefs.getInt(KEY_PERSISTENT_STEPS, 0)
    }

    private fun checkAndResetForNewDay() {
        val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val savedDate = prefs.getString(KEY_STEP_DATE, "")
        if (savedDate != todayStr) {
            prefs.edit()
                .putString(KEY_STEP_DATE, todayStr)
                .putInt(KEY_PERSISTENT_STEPS, 0)
                .apply()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onTaskRemoved(rootIntent: Intent?) {
        // When user swipes the app out of Recent Apps, keep the Foreground Service alive
        super.onTaskRemoved(rootIntent)
        val restartServiceIntent = Intent(applicationContext, StepTrackingService::class.java).apply {
            setPackage(packageName)
        }
        val restartServicePendingIntent = PendingIntent.getService(
            applicationContext,
            1,
            restartServiceIntent,
            PendingIntent.FLAG_ONE_SHOT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )
        val alarmService = getSystemService(Context.ALARM_SERVICE) as? android.app.AlarmManager
        alarmService?.set(
            android.app.AlarmManager.RTC,
            System.currentTimeMillis() + 1000,
            restartServicePendingIntent
        )
    }

    override fun onDestroy() {
        isServiceRunning = false
        sensorManager?.unregisterListener(this)
        super.onDestroy()
    }
}
