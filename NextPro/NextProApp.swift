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

        Messaging.messaging().apnsToken = deviceToken

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNs Token:")
        print(token)
    }

    // Called whenever the FCM token is created or refreshed.
    // Only stores the token + marks it pending — never registers it directly here.
    // Registration only ever happens after a successful login (see FCMTokenManager.registerIfNeeded()),
    // so a token refreshed mid-session is registered on the *next* login, not immediately.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }

        print("🔥 New FCM Token:")
        print(token)

        Task { @MainActor in
            FCMTokenManager.shared.handleNewToken(token)
        }
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
