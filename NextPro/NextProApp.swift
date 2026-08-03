//
//  NextProApp.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    // MARK: - Debug logging helper

    private func appStateDescription(_ state: UIApplication.State) -> String {
        switch state {
        case .active: return "foreground (active)"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
    }

    private func prettyJSON(_ userInfo: [AnyHashable: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(userInfo),
              let data = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted]),
              let json = String(data: data, encoding: .utf8) else {
            return "\(userInfo)"
        }
        return json
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        // Set delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Notification Permission: \(granted)")
        }

        // Register with APNs
        application.registerForRemoteNotifications()

        // Fetch FCM Token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error fetching FCM token: \(error)")
            } else if let token = token {
                print("🔥 FCM Token:")
                print(token)

                Task { @MainActor in
                    FCMTokenManager.shared.handleNewToken(token)
                    FCMTokenManager.shared.registerIfNeeded()
                }
            }
        }

        return true
    }

    // APNs Token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        print("📱 [AppDelegate] didRegisterForRemoteNotificationsWithDeviceToken called — app state: \(appStateDescription(application.applicationState))")

        Messaging.messaging().apnsToken = deviceToken

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNs Token:")
        print(token)
    }

    // APNs registration failure (debug log only — no existing handling to preserve)
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ [AppDelegate] didFailToRegisterForRemoteNotificationsWithError called — app state: \(appStateDescription(application.applicationState))")
        print("❌ APNs registration error: \(error.localizedDescription)")
    }

    // Silent / background remote notification (debug log only — completionHandler(.noData) preserves existing no-op behavior)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📩 [AppDelegate] didReceiveRemoteNotification called — app state: \(appStateDescription(application.applicationState))")
        print("📩 userInfo:\n\(prettyJSON(userInfo))")

        Task { @MainActor in
            let didFetch = await NotificationCountViewModel.shared.refreshUnreadCountAwaiting()
            NotificationNavigationManager.shared.notifyNotificationsDidArrive()
            completionHandler(didFetch ? .newData : .noData)
        }
    }

    // Called whenever the FCM token is created or refreshed.
    // Only stores the token + marks it pending — never registers it directly here.
    // Registration only ever happens after a successful login (see FCMTokenManager.registerIfNeeded()),
    // so a token refreshed mid-session is registered on the *next* login, not immediately.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔥 [MessagingDelegate] didReceiveRegistrationToken called — app state: \(appStateDescription(UIApplication.shared.applicationState))")

        guard let token = fcmToken else {
            print("🔥 [MessagingDelegate] didReceiveRegistrationToken called with a nil token")
            return
        }

        print("🔥 New FCM Token:")
        print(token)

        Task { @MainActor in
            FCMTokenManager.shared.handleNewToken(token)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate (debug log only — no existing implementation to preserve)

    // Called when a notification arrives while the app is in the foreground.
    // Present banner/sound/badge even in foreground instead of suppressing it.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 [UNUserNotificationCenterDelegate] willPresent called — app state: \(appStateDescription(UIApplication.shared.applicationState))")
        print("🔔 userInfo:\n\(prettyJSON(notification.request.content.userInfo))")

        completionHandler([.banner, .list, .sound, .badge])
    }

    // Called when the user taps a notification (or takes an action on it).
    // Routes to the Notifications screen via NotificationNavigationManager.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👉 [UNUserNotificationCenterDelegate] didReceive called — user tapped notification — app state: \(appStateDescription(UIApplication.shared.applicationState))")
        print("👉 userInfo:\n\(prettyJSON(response.notification.request.content.userInfo))")
        print("👉 actionIdentifier: \(response.actionIdentifier)")

        Task { @MainActor in
            NotificationNavigationManager.shared.triggerNotificationsScreen()
        }

        completionHandler()
    }
}

@main
struct NextProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("is_logged_in") private var isLoggedIn = false

    init() {
        UIRefreshControl.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        if isLoggedIn {
                            print("☀️ App active — start server time")
                            ServerTimeService.shared.start(forceImmediate: true)
                        } else {
                            print("☀️ App active — user logged out, stop server time")
                            ServerTimeService.shared.stop()
                            NetworkManager.shared.resetSessionExpirationState()
                        }

                    case .background:
                        print("🌙 App background — stop server time")
                        ServerTimeService.shared.stop()

                    case .inactive:
                        break

                    @unknown default:
                        break
                    }
                }
        }
    }
}
