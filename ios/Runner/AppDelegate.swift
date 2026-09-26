import UIKit
import Flutter
import UserNotifications
import CoreMotion

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var shortcutsChannel: FlutterMethodChannel?
  private var notificationsChannel: FlutterMethodChannel?
  private var preferencesChannel: FlutterMethodChannel?
  private var pedometerChannel: FlutterMethodChannel?
  private var initialAction: String?

  private let pedometer = CMPedometer()
  private let motionManager = CMMotionManager()
  private var lastStepCount = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger

    // Setup UNUserNotificationCenter
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

    // 1. Shortcuts Channel
    let sChannel = FlutterMethodChannel(name: "com.biothrix.app/shortcuts", binaryMessenger: messenger)
    shortcutsChannel = sChannel

    if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
      initialAction = shortcutItem.type
    }

    sChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getInitialAction" {
        result(self?.initialAction)
        self?.initialAction = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 2. Real System Notifications Channel
    let nChannel = FlutterMethodChannel(name: "com.biothrix.app/notifications", binaryMessenger: messenger)
    notificationsChannel = nChannel
    nChannel.setMethodCallHandler { (call, result) in
      if call.method == "showNotification" {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing title", details: nil))
          return
        }
        let body = args["body"] as? String ?? ""
        let id = args["id"] as? Int ?? Int(Date().timeIntervalSince1970)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: String(id), content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            result(FlutterError(code: "NOTIFICATION_ERROR", message: error.localizedDescription, details: nil))
          } else {
            result(true)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 3. Persistent Preferences Channel (UserDefaults)
    let pChannel = FlutterMethodChannel(name: "com.biothrix.app/preferences", binaryMessenger: messenger)
    preferencesChannel = pChannel
    pChannel.setMethodCallHandler { (call, result) in
      guard let args = call.arguments as? [String: Any],
            let key = args["key"] as? String else {
        result(FlutterError(code: "INVALID_KEY", message: "Key required", details: nil))
        return
      }

      let defaults = UserDefaults.standard
      switch call.method {
      case "getBool":
        let defVal = args["defaultValue"] as? Bool ?? false
        let val = defaults.object(forKey: key) != nil ? defaults.bool(forKey: key) : defVal
        result(val)
      case "setBool":
        if let val = args["value"] as? Bool {
          defaults.set(val, forKey: key)
          result(true)
        } else {
          result(false)
        }
      case "getString":
        let val = defaults.string(forKey: key) ?? (args["defaultValue"] as? String)
        result(val)
      case "setString":
        defaults.set(args["value"] as? String, forKey: key)
        result(true)
      case "getInt":
        let defVal = args["defaultValue"] as? Int ?? 0
        let val = defaults.object(forKey: key) != nil ? defaults.integer(forKey: key) : defVal
        result(val)
      case "setInt":
        if let val = args["value"] as? Int {
          defaults.set(val, forKey: key)
          result(true)
        } else {
          result(false)
        }
      case "remove":
        defaults.removeObject(forKey: key)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // 4. Onboard Device Hardware Pedometer Channel (CoreMotion)
    let pedChannel = FlutterMethodChannel(name: "com.biothrix.app/pedometer", binaryMessenger: messenger)
    pedometerChannel = pedChannel
    pedChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      switch call.method {
      case "isStepCountingAvailable":
        let available = CMPedometer.isStepCountingAvailable() || self.motionManager.isAccelerometerAvailable
        result(available)
      case "startStepTracking":
        self.lastStepCount = 0
        if CMPedometer.isStepCountingAvailable() {
          self.pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            let totalSteps = data.numberOfSteps.intValue
            let delta = totalSteps - self.lastStepCount
            if delta > 0 {
              self.lastStepCount = totalSteps
              DispatchQueue.main.async {
                self.pedometerChannel?.invokeMethod("onStepDetected", delta)
              }
            }
          }
          result(true)
        } else if self.motionManager.isAccelerometerAvailable {
          var lastMag: Double = 0
          var lastTimestamp = Date().timeIntervalSince1970
          self.motionManager.accelerometerUpdateInterval = 0.05
          self.motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            let x = data.acceleration.x * 9.81
            let y = data.acceleration.y * 9.81
            let z = data.acceleration.z * 9.81
            let mag = sqrt(x * x + y * y + z * z)
            let now = Date().timeIntervalSince1970
            if mag > 11.6 && lastMag <= 11.6 && (now - lastTimestamp) > 0.28 {
              lastTimestamp = now
              self?.pedometerChannel?.invokeMethod("onStepDetected", 1)
            }
            lastMag = mag
          }
          result(true)
        } else {
          result(false)
        }
      case "stopStepTracking":
        if CMPedometer.isStepCountingAvailable() {
          self.pedometer.stopUpdates()
        }
        self.motionManager.stopAccelerometerUpdates()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge, .list])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  override func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    shortcutsChannel?.invokeMethod("onShortcutAction", arguments: shortcutItem.type)
    completionHandler(true)
  }
}
