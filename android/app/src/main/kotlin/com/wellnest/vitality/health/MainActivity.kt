package com.wellnest.vitality.health

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), SensorEventListener {
    companion object {
        @Volatile
        private var instance: MainActivity? = null

        fun dispatchStepDetectedToFlutter(count: Int) {
            instance?.runOnUiThread {
                instance?.pedometerChannel?.invokeMethod("onStepDetected", count)
            }
        }
    }

    private val SHORTCUTS_CHANNEL = "com.wellnest.vitality.health/shortcuts"
    private val NOTIFICATIONS_CHANNEL = "com.wellnest.vitality.health/notifications"
    private val PREFERENCES_CHANNEL = "com.wellnest.vitality.health/preferences"
    private val PEDOMETER_CHANNEL = "com.wellnest.vitality.health/pedometer"
    private val WEARABLES_CHANNEL = "com.wellnest.vitality.health/wearables"
    private val BIOMETRICS_CHANNEL = "com.wellnest.vitality.health/biometrics"
    private val BROWSER_CHANNEL = "com.wellnest.vitality.health/browser"
    private val NOTIFICATION_CHANNEL_ID = "wellnest_alerts"
    private val ACTIVITY_RECOGNITION_REQUEST_CODE = 1001
    private val BLUETOOTH_PERMISSION_REQUEST_CODE = 1002

    private var initialAction: String? = null
    private var initialDeepLinkUri: String? = null
    private var methodChannel: MethodChannel? = null
    private var pedometerChannel: MethodChannel? = null
    private var wearablesChannel: MethodChannel? = null
    private var biometricsChannel: MethodChannel? = null
    private var browserChannel: MethodChannel? = null
    private var isScanningBle = false
    private var bleScanCallback: ScanCallback? = null
    private var currentCancellationSignal: CancellationSignal? = null

    // Hardware Sensor Properties
    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null
    private var isUsingStepDetector = false
    private var lastStepCounterValue = -1.0f
    private var lastAccelMagnitude = 0.0f
    private var lastStepTimestamp = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
        // Ensure edge-to-edge window drawing behind navigation and status bars
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }

        createNotificationChannel()
        initHardwareSensors()

        // Android 14+ (API 34+) Hardware Screen Capture & Screenshot Detection
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                registerScreenCaptureCallback(mainExecutor) {
                    runOnUiThread {
                        biometricsChannel?.invokeMethod("onScreenshotDetected", null)
                    }
                }
            } catch (_: Throwable) {}
        }

        // Handle app shortcut intent actions
        intent?.action?.let { action ->
            if (action.startsWith("com.wellnest.vitality.health.ACTION_")) {
                initialAction = action
            }
        }

        // Handle OAuth / deep link intent data on launch
        intent?.data?.let { uri ->
            if (uri.scheme == "wellnest") {
                initialDeepLinkUri = uri.toString()
            }
        }
    }

    private fun initHardwareSensors() {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        val detector = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val counter = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        if (detector != null) {
            stepSensor = detector
            isUsingStepDetector = true
        } else if (counter != null) {
            stepSensor = counter
            isUsingStepDetector = false
        }
        // Always acquire accelerometer as fallback/instant sensor
        accelerometerSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
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
            if (action.startsWith("com.wellnest.vitality.health.ACTION_")) {
                methodChannel?.invokeMethod("onShortcutAction", action)
            }
        }
        intent.data?.let { uri ->
            if (uri.scheme == "wellnest") {
                browserChannel?.invokeMethod("onDeepLink", uri.toString())
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
                "getDouble" -> {
                    val defVal = (call.argument<Double>("defaultValue") ?: 0.0).toFloat()
                    result.success(prefs.getFloat(key, defVal).toDouble())
                }
                "setDouble" -> {
                    val value = (call.argument<Double>("value") ?: 0.0).toFloat()
                    prefs.edit().putFloat(key, value).apply()
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
                "requestPedometerPermission" -> {
                    val granted = checkAndRequestPedometerPermission()
                    result.success(granted)
                }
                "getPersistentStepCount" -> {
                    val p = getSharedPreferences(StepTrackingService.PREFS_NAME, Context.MODE_PRIVATE)
                    val steps = p.getInt(StepTrackingService.KEY_PERSISTENT_STEPS, 0)
                    result.success(steps)
                }
                "startStepTracking" -> {
                    lastStepCounterValue = -1.0f
                    val currentSteps = call.argument<Int>("currentSteps") ?: 0
                    if (currentSteps > 0) {
                        val p = getSharedPreferences(StepTrackingService.PREFS_NAME, Context.MODE_PRIVATE)
                        val existing = p.getInt(StepTrackingService.KEY_PERSISTENT_STEPS, 0)
                        if (currentSteps > existing) {
                            p.edit().putInt(StepTrackingService.KEY_PERSISTENT_STEPS, currentSteps).apply()
                        }
                    }
                    checkAndRequestPedometerPermission()
                    val registered = registerHardwareSensors()
                    try {
                        val sIntent = Intent(this, StepTrackingService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(sIntent)
                        } else {
                            startService(sIntent)
                        }
                    } catch (_: Exception) {}
                    result.success(registered)
                }
                "stopStepTracking" -> {
                    lastStepCounterValue = -1.0f
                    sensorManager?.unregisterListener(this)
                    try {
                        val sIntent = Intent(this, StepTrackingService::class.java).apply {
                            action = StepTrackingService.ACTION_STOP_TRACKING
                        }
                        startService(sIntent)
                    } catch (_: Exception) {}
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 5. Smart Watches, Smart Rings & BLE Peripherals Channel
        val wearChannel = MethodChannel(messenger, WEARABLES_CHANNEL)
        wearablesChannel = wearChannel
        wearChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasBluetoothPermission" -> {
                    result.success(hasBluetoothPermission())
                }
                "requestBluetoothPermission" -> {
                    val granted = checkAndRequestBluetoothPermission()
                    result.success(granted)
                }
                "getBondedWearables" -> {
                    val devices = getBondedWearableDevices()
                    result.success(devices)
                }
                "startBleScan" -> {
                    val started = startBleScan()
                    result.success(started)
                }
                "stopBleScan" -> {
                    stopBleScan()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 6. Biometrics & Device Security Channel (100% Local Hardware Authentication)
        val bioChannel = MethodChannel(messenger, BIOMETRICS_CHANNEL)
        biometricsChannel = bioChannel
        bioChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isBiometricsAvailable" -> {
                    val status = canAuthenticateBiometrics()
                    result.success(status)
                }
                "authenticate" -> {
                    val title = call.argument<String>("title") ?: "Unlock Wellnest"
                    val subtitle = call.argument<String>("subtitle") ?: "Confirm your biometric identity to access your wellness telemetry"
                    val negativeBtn = call.argument<String>("negativeButton") ?: "Use 6-Digit PIN"
                    authenticateWithBiometrics(title, subtitle, negativeBtn, result)
                }
                "cancelAuthentication" -> {
                    cancelBiometricAuthentication()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 7. Browser & Google OAuth Deep Link Channel
        val bChannel = MethodChannel(messenger, BROWSER_CHANNEL)
        browserChannel = bChannel
        bChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrEmpty()) {
                        result.error("INVALID_URL", "URL cannot be null or empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        context.startActivity(browserIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BROWSER_ERROR", e.message, null)
                    }
                }
                "getInitialUri" -> {
                    result.success(initialDeepLinkUri)
                    initialDeepLinkUri = null
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED &&
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun checkAndRequestBluetoothPermission(): Boolean {
        if (!hasBluetoothPermission() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            requestPermissions(
                arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT),
                BLUETOOTH_PERMISSION_REQUEST_CODE
            )
            return false
        }
        return true
    }

    private fun getBondedWearableDevices(): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        try {
            val bm = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            val adapter = bm?.adapter
            if (adapter != null && adapter.isEnabled) {
                for (dev in adapter.bondedDevices) {
                    val name = dev.name ?: "Bluetooth Peripheral"
                    val address = dev.address ?: "00:00:00:00:00:00"
                    val type = when {
                        name.contains("watch", true) || name.contains("fit", true) || name.contains("band", true) || name.contains("garmin", true) -> "smartWatch"
                        name.contains("ring", true) || name.contains("oura", true) -> "smartRing"
                        name.contains("cuff", true) || name.contains("bp", true) -> "bloodPressureCuff"
                        else -> "smartWatch"
                    }
                    val brand = when {
                        name.contains("oura", true) -> "oura"
                        name.contains("apple", true) -> "apple"
                        name.contains("galaxy", true) || name.contains("samsung", true) -> "samsung"
                        name.contains("garmin", true) -> "garmin"
                        name.contains("withings", true) -> "withings"
                        name.contains("ultrahuman", true) -> "ultrahuman"
                        name.contains("whoop", true) -> "whoop"
                        name.contains("fitbit", true) -> "fitbit"
                        else -> "generic"
                    }
                    list.add(mapOf(
                        "id" to "bonded-$address",
                        "name" to name,
                        "address" to address,
                        "type" to type,
                        "brand" to brand,
                        "isConnected" to true,
                        "batteryLevel" to 90
                    ))
                }
            }
        } catch (_: SecurityException) {} catch (_: Exception) {}
        return list
    }

    private fun startBleScan(): Boolean {
        if (!hasBluetoothPermission()) {
            checkAndRequestBluetoothPermission()
            return false
        }
        val bm = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        val adapter = bm?.adapter ?: return false
        if (!adapter.isEnabled) return false
        val scanner = adapter.bluetoothLeScanner ?: return false

        stopBleScan()
        isScanningBle = true
        val seenAddresses = mutableSetOf<String>()

        bleScanCallback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult?) {
                if (result == null) return
                val dev = result.device ?: return
                val address = dev.address ?: return
                if (seenAddresses.contains(address)) return
                seenAddresses.add(address)

                val name = try { dev.name } catch (_: SecurityException) { null } ?: result.scanRecord?.deviceName ?: "Smart BLE Peripheral"
                val type = when {
                    name.contains("watch", true) || name.contains("fit", true) || name.contains("band", true) || name.contains("garmin", true) -> "smartWatch"
                    name.contains("ring", true) || name.contains("oura", true) -> "smartRing"
                    name.contains("cuff", true) || name.contains("bp", true) -> "bloodPressureCuff"
                    else -> "smartWatch"
                }
                val brand = when {
                    name.contains("oura", true) -> "oura"
                    name.contains("apple", true) -> "apple"
                    name.contains("galaxy", true) || name.contains("samsung", true) -> "samsung"
                    name.contains("garmin", true) -> "garmin"
                    name.contains("withings", true) -> "withings"
                    name.contains("ultrahuman", true) -> "ultrahuman"
                    name.contains("whoop", true) -> "whoop"
                    name.contains("fitbit", true) -> "fitbit"
                    else -> "generic"
                }

                val payload = mapOf(
                    "id" to "ble-$address",
                    "name" to name,
                    "address" to address,
                    "type" to type,
                    "brand" to brand,
                    "rssi" to result.rssi,
                    "isConnected" to false,
                    "batteryLevel" to 85
                )
                runOnUiThread {
                    wearablesChannel?.invokeMethod("onDeviceDiscovered", payload)
                }
            }
        }

        try {
            scanner.startScan(bleScanCallback)
            Handler(Looper.getMainLooper()).postDelayed({
                stopBleScan()
            }, 10000L)
            return true
        } catch (_: SecurityException) {
            return false
        }
    }

    private fun stopBleScan() {
        if (!isScanningBle) return
        isScanningBle = false
        try {
            val bm = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            val scanner = bm?.adapter?.bluetoothLeScanner
            bleScanCallback?.let { scanner?.stopScan(it) }
        } catch (_: SecurityException) {} catch (_: Exception) {}
        bleScanCallback = null
    }

    private fun hasActivityRecognitionPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun checkAndRequestPedometerPermission(): Boolean {
        if (!hasActivityRecognitionPermission() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            requestPermissions(arrayOf(Manifest.permission.ACTIVITY_RECOGNITION), ACTIVITY_RECOGNITION_REQUEST_CODE)
            return false
        }
        return true
    }

    private fun registerHardwareSensors(): Boolean {
        val sm = sensorManager ?: return false
        sm.unregisterListener(this)
        var registered = false

        if (hasActivityRecognitionPermission() && stepSensor != null) {
            val ok = sm.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_GAME)
            if (ok) {
                registered = true
            }
        }

        // Always register accelerometer as dynamic fallback if stepSensor is null or permission pending
        if (!registered && accelerometerSensor != null) {
            val ok = sm.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_GAME)
            if (ok) {
                registered = true
            }
        }

        return registered
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == ACTIVITY_RECOGNITION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                registerHardwareSensors()
            }
        } else if (requestCode == BLUETOOTH_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startBleScan()
            }
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        when (event.sensor.type) {
            Sensor.TYPE_STEP_DETECTOR -> {
                // Hardware step detector fires a 1.0 event per discrete step
                if (event.values.isNotEmpty() && event.values[0] > 0.0f) {
                    runOnUiThread {
                        pedometerChannel?.invokeMethod("onStepDetected", 1)
                    }
                }
            }
            Sensor.TYPE_STEP_COUNTER -> {
                // Returns cumulative step count since device reboot; calculate real step delta
                if (event.values.isNotEmpty()) {
                    val currentTotal = event.values[0]
                    if (lastStepCounterValue < 0.0f) {
                        lastStepCounterValue = currentTotal
                    } else {
                        val delta = (currentTotal - lastStepCounterValue).toInt()
                        if (delta > 0) {
                            lastStepCounterValue = currentTotal
                            runOnUiThread {
                                pedometerChannel?.invokeMethod("onStepDetected", delta)
                            }
                        }
                    }
                }
            }
            Sensor.TYPE_ACCELEROMETER -> {
                // Fallback high-fidelity dynamic peak detector for phones lacking dedicated step coprocessors
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val magnitude = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()
                val now = System.currentTimeMillis()

                // Walking motion produces acceleration peaks > 11.0 m/s^2 with human cadence refractory period (260ms - 1800ms)
                if (magnitude > 11.0f && lastAccelMagnitude <= 11.0f && (now - lastStepTimestamp) in 260L..1800L) {
                    lastStepTimestamp = now
                    runOnUiThread {
                        pedometerChannel?.invokeMethod("onStepDetected", 1)
                    }
                } else if (lastStepTimestamp == 0L && magnitude > 11.0f) {
                    lastStepTimestamp = now
                    runOnUiThread {
                        pedometerChannel?.invokeMethod("onStepDetected", 1)
                    }
                }
                lastAccelMagnitude = magnitude
            }
        }
    }

    private fun canAuthenticateBiometrics(): Map<String, Any> {
        var hasHardware = false
        var isEnrolled = false

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val bm = getSystemService(Context.BIOMETRIC_SERVICE) as? android.hardware.biometrics.BiometricManager
                if (bm != null) {
                    val authenticators = android.hardware.biometrics.BiometricManager.Authenticators.BIOMETRIC_STRONG or
                            android.hardware.biometrics.BiometricManager.Authenticators.BIOMETRIC_WEAK
                    val canAuth = bm.canAuthenticate(authenticators)
                    hasHardware = canAuth != android.hardware.biometrics.BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE
                    isEnrolled = canAuth == android.hardware.biometrics.BiometricManager.BIOMETRIC_SUCCESS
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val bm = getSystemService(Context.BIOMETRIC_SERVICE) as? android.hardware.biometrics.BiometricManager
                if (bm != null) {
                    val canAuth = bm.canAuthenticate()
                    hasHardware = canAuth != android.hardware.biometrics.BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE
                    isEnrolled = canAuth == android.hardware.biometrics.BiometricManager.BIOMETRIC_SUCCESS
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val fp = getSystemService(Context.FINGERPRINT_SERVICE) as? android.hardware.fingerprint.FingerprintManager
                if (fp != null) {
                    hasHardware = fp.isHardwareDetected
                    isEnrolled = fp.hasEnrolledFingerprints()
                }
            }
        } catch (_: Throwable) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val fp = getSystemService(Context.FINGERPRINT_SERVICE) as? android.hardware.fingerprint.FingerprintManager
                    if (fp != null) {
                        hasHardware = fp.isHardwareDetected
                        isEnrolled = fp.hasEnrolledFingerprints()
                    }
                }
            } catch (_: Throwable) {}
        }

        return mapOf(
            "hasHardware" to hasHardware,
            "isEnrolled" to isEnrolled,
            "available" to (hasHardware && isEnrolled)
        )
    }

    private fun authenticateWithBiometrics(
        title: String,
        subtitle: String,
        negativeButton: String,
        result: MethodChannel.Result
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val hasReplied = java.util.concurrent.atomic.AtomicBoolean(false)
            try {
                cancelBiometricAuthentication()
                val signal = CancellationSignal()
                currentCancellationSignal = signal

                val prompt = android.hardware.biometrics.BiometricPrompt.Builder(this)
                    .setTitle(title)
                    .setSubtitle(subtitle)
                    .setNegativeButton(negativeButton, mainExecutor) { _, _ ->
                        if (hasReplied.compareAndSet(false, true)) {
                            result.success(mapOf("success" to false, "error" to "user_canceled"))
                        }
                    }
                    .build()

                prompt.authenticate(
                    signal,
                    mainExecutor,
                    object : android.hardware.biometrics.BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(authResult: android.hardware.biometrics.BiometricPrompt.AuthenticationResult?) {
                            super.onAuthenticationSucceeded(authResult)
                            currentCancellationSignal = null
                            if (hasReplied.compareAndSet(false, true)) {
                                result.success(mapOf("success" to true))
                            }
                        }

                        override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                            super.onAuthenticationError(errorCode, errString)
                            currentCancellationSignal = null
                            if (hasReplied.compareAndSet(false, true)) {
                                result.success(mapOf("success" to false, "error" to (errString?.toString() ?: "Authentication error $errorCode")))
                            }
                        }

                        override fun onAuthenticationFailed() {
                            super.onAuthenticationFailed()
                        }
                    }
                )
            } catch (t: Throwable) {
                if (hasReplied.compareAndSet(false, true)) {
                    result.success(mapOf("success" to false, "error" to (t.localizedMessage ?: "Biometric prompt exception")))
                }
            }
        } else {
            result.success(mapOf("success" to false, "error" to "unsupported_sdk_version"))
        }
    }

    private fun cancelBiometricAuthentication() {
        try {
            currentCancellationSignal?.cancel()
            currentCancellationSignal = null
        } catch (_: Exception) {}
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        if (instance == this) instance = null
        cancelBiometricAuthentication()
        stopBleScan()
        sensorManager?.unregisterListener(this)
        super.onDestroy()
    }
}
