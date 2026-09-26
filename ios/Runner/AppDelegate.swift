import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var shortcutsChannel: FlutterMethodChannel?
  private var initialAction: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.biothrix.app/shortcuts", binaryMessenger: controller.binaryMessenger)
    shortcutsChannel = channel

    if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
      initialAction = shortcutItem.type
    }

    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getInitialAction" {
        result(self?.initialAction)
        self?.initialAction = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
