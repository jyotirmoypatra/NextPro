//
//  FCMTokenManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation
import FirebaseMessaging

/// Centralizes the FCM device-token lifecycle: receiving tokens from Firebase, registering
/// them with the backend once authenticated, and unregistering + regenerating on logout.
/// All state mutation happens on the main actor.
@MainActor
final class FCMTokenManager {

    static let shared = FCMTokenManager()

    private init() {}

    private enum Keys {
        static let fcmToken = "fcm_token"
        static let lastRegisteredToken = "fcm_token_last_registered"
        static let deviceTokenId = "fcm_device_token_id"
    }

    private let registerVM = RegisterFCMTokenViewModel()
    private let unregisterVM = UnRegisterFCMTokenViewModel()

    // Guards so only one registration request is ever in flight.
    private var registerTask: Task<Void, Never>?

    private var isAuthenticated: Bool {
        guard UserDefaults.standard.bool(forKey: "is_logged_in") else { return false }
        guard let token = KeychainManager.shared.get("access_token"), !token.isEmpty else { return false }
        return true
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Token updates (called from AppDelegate)

    /// Called whenever Firebase hands us a token — just stores it. Whether it actually needs
    /// registering is decided by `registerIfNeeded()` comparing it against the last registered
    /// token: same token → skip, different token → register.
    func handleNewToken(_ token: String) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            print("⚠️ FCM token empty — ignoring")
            return
        }
        UserDefaults.standard.set(trimmed, forKey: Keys.fcmToken)
    }

    // MARK: - Registration (call after a successful login / on app launch while already logged in)

    /// Registers the current FCM token with the backend if it's different from the last token
    /// that was successfully registered. Safe to call on every launch/login.
    func registerIfNeeded() {
        guard isAuthenticated else {
            print("🔔 Not authenticated — skipping FCM registration")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: Keys.fcmToken), !token.isEmpty else {
            print("🔔 No FCM token yet — will register once Firebase provides one")
            return
        }

        let lastRegistered = UserDefaults.standard.string(forKey: Keys.lastRegisteredToken)
        guard token != lastRegistered else {
            print("🔔 FCM token unchanged — skipping registration")
            return
        }

        guard registerTask == nil else {
            print("🔔 FCM registration already in progress — skipping duplicate call")
            return
        }

        registerTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.registerTask = nil }

            let data = await self.registerVM.register(
                fcmToken: token,
                platform: "ios",
                appVersion: self.appVersion
            )

            if let data {
                UserDefaults.standard.set(token, forKey: Keys.lastRegisteredToken)
                if let id = data.id {
                    UserDefaults.standard.set(id, forKey: Keys.deviceTokenId)
                }
                print("✅ FCM token registered — device token id:", data.id ?? -1)
            } else {
                print("❌ FCM token registration failed — will retry once the token differs or on next login")
            }
        }
    }

    // MARK: - Logout

    enum StrictLogoutResult {
        case success
        /// Unregister failed — session was left untouched, caller should show `message` and keep the user logged in.
        case failed(message: String)
    }

    /// User-initiated "Logout": unregister must succeed (or there's nothing to unregister)
    /// before the session is cleared. On failure, nothing is touched.
    func logoutStrict() async -> StrictLogoutResult {
        if let deviceTokenId = UserDefaults.standard.object(forKey: Keys.deviceTokenId) as? Int {
            let succeeded = await unregisterVM.unregister(tokenId: deviceTokenId)
            guard succeeded else {
                let message = unregisterVM.errorMessage ?? "Failed to unregister device. Please try again."
                return .failed(message: message)
            }
        }

        await deleteFCMToken()
        clearLocalSessionData()
        await generateNewFCMToken()

        return .success
    }

    /// Forced logout paths that must never be blocked (session expiry, account deletion —
    /// the session is dead either way). Best-effort unregister, then always clears the session.
    func performLogout() async {
        if let deviceTokenId = UserDefaults.standard.object(forKey: Keys.deviceTokenId) as? Int {
            _ = await unregisterVM.unregister(tokenId: deviceTokenId)
        }

        await deleteFCMToken()
        clearLocalSessionData()
        await generateNewFCMToken()
    }

    private func clearLocalSessionData() {
        // Disconnect MQTT and clear its in-memory state (subscriptions, client instance)
        // *before* wiping credentials — nothing should keep receiving door events for a
        // session that's about to no longer exist.
        MQTTManager.shared.disconnect()

        KeychainManager.shared.clearUserDefaultsAndKeychainData()
        UserDefaults.standard.set(false, forKey: "is_logged_in")

        // Clear the unread count (and, via its didSet, the app icon badge) now that the
        // session is actually gone — a stale badge shouldn't survive logout.
        NotificationCountViewModel.shared.unreadCount = 0
    }

    /// Deletes the current FCM token from Firebase. Called before the local wipe, using the
    /// still-live Firebase Messaging instance.
    private func deleteFCMToken() async {
        await withCheckedContinuation { continuation in
            Messaging.messaging().deleteToken { error in
                if let error {
                    print("⚠️ Failed to delete FCM token: \(error.localizedDescription)")
                } else {
                    print("🗑️ FCM token deleted")
                }
                continuation.resume()
            }
        }
    }

    /// Requests a fresh FCM token from Firebase and stores it. Called *after* the local wipe
    /// so the new token isn't erased by `clearUserDefaultsAndKeychainData()` — it's what the
    /// next login registers via `registerIfNeeded()` (it will differ from `lastRegisteredToken`,
    /// which was just wiped too, so it registers unconditionally).
    private func generateNewFCMToken() async {
        let newToken: String? = await withCheckedContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error {
                    print("❌ Failed to fetch new FCM token: \(error.localizedDescription)")
                }
                continuation.resume(returning: token)
            }
        }

        if let newToken {
            handleNewToken(newToken)
        }
    }
}
