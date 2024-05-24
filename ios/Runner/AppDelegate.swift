import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    application.registerForRemoteNotifications()
    registerForPushNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")
    Messaging.messaging().apnsToken = deviceToken
    return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any],
                                  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Handle it for firebase messaging analytics
    if ((notification["gcm.message_id"]) != nil) {
        Messaging.messaging().appDidReceiveMessage(notification)
    }
    return super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)
  }

  func registerForPushNotifications() {
    UNUserNotificationCenter.current()
    .requestAuthorization(
      options: [.alert, .sound, .badge]) { [weak self] granted, _ in
      print("Permission granted: \(granted)")
      guard granted else { return }
      self?.getNotificationSettings()
    }
  }

  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register: \(error)")
    return super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
