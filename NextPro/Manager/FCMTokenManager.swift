//
//  FCMTokenManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation

/// Centralizes the full FCM device-token lifecycle: receiving/storing tokens from Firebase,
/// registering them with the backend once the user is authenticated, and unregistering the
/// device on logout. All state mutation happens on the main actor, so token updates and
/// register/unregister calls are inherently serialized (thread-safe) and never run concurrently
/// with themselves.
@MainActor
final class FCMTokenManager {

    static let shared = FCMTokenManager()

    private init() {}

    private enum Keys {
        static let fcmToken = "fcm_token"
        static let lastRegisteredToken = "fcm_token_last_registered"
        static let pendingRegistration = "fcm_token_pending_registration"
        static let deviceTokenId = "fcm_device_token_id"
    }

    private let registerVM = RegisterFCMTokenViewModel()
    private let unregisterVM = UnRegisterFCMTokenViewModel()

    // Guards so only one registration / unregistration request is ever in flight.
    private var registerTask: Task<Void, Never>?
    private var unregisterTask: Task<Bool, Never>?

    private var isAuthenticated: Bool {
        guard UserDefaults.standard.bool(forKey: "is_logged_in") else { return false }
        guard let token = KeychainManager.shared.get("access_token"), !token.isEmpty else { return false }
        return true
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Token updates (called from AppDelegate)

    /// Called whenever Firebase hands us a (new or unchanged) FCM token.
    /// Only stores + marks pending on an actual change. Never calls the API directly —
    /// registration only ever happens from `registerIfNeeded()` after a successful login.
    func handleNewToken(_ token: String) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            print("⚠️ FCM token empty — ignoring")
            return
        }

        let previousToken = UserDefaults.standard.string(forKey: Keys.fcmToken)
        guard trimmed != previousToken else {
            print("🔔 FCM token unchanged — skipping")
            return
        }

        UserDefaults.standard.set(trimmed, forKey: Keys.fcmToken)
        UserDefaults.standard.set(true, forKey: Keys.pendingRegistration)
        print("🔔 FCM token changed — marked pending registration")
    }

    // MARK: - Registration (call after a successful login / on app launch while already logged in)

    /// Registers the current FCM token with the backend if the user is authenticated and the
    /// token is pending registration (new, or changed since the last successful registration).
    /// Safe to call on every launch/login — it no-ops when there is nothing to do, so it never
    /// produces duplicate registrations.
    func registerIfNeeded() {
        guard isAuthenticated else {
            print("🔔 Not authenticated — skipping FCM registration")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: Keys.fcmToken), !token.isEmpty else {
            print("🔔 No FCM token yet — will register once Firebase provides one")
            return
        }

        let isPending = UserDefaults.standard.bool(forKey: Keys.pendingRegistration)
        let lastRegistered = UserDefaults.standard.string(forKey: Keys.lastRegisteredToken)
        guard isPending || token != lastRegistered else {
            print("🔔 FCM token already registered — skipping")
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
                UserDefaults.standard.set(false, forKey: Keys.pendingRegistration)
                if let id = data.id {
                    UserDefaults.standard.set(id, forKey: Keys.deviceTokenId)
                }
                print("✅ FCM token registered — device token id:", data.id ?? -1)
            } else {
                // Keep it pending so the next successful login retries — never lose the token.
                UserDefaults.standard.set(true, forKey: Keys.pendingRegistration)
                print("❌ FCM token registration failed — will retry on next login")
            }
        }
    }

    // MARK: - Logout

    enum StrictLogoutResult {
        case success
        /// Unregister failed — session was left untouched, caller should show `message` and keep the user logged in.
        case failed(message: String)
    }

    /// Use for the user-initiated "Logout" action: unregistering the device token must succeed
    /// (or there must be nothing to unregister) before the session is actually cleared. On
    /// failure, nothing is touched — the user stays logged in and can retry.
    func logoutStrict() async -> StrictLogoutResult {
        let deviceTokenId = UserDefaults.standard.object(forKey: Keys.deviceTokenId) as? Int

        guard let deviceTokenId else {
            // Nothing to unregister — safe to log out.
            clearLocalSessionData()
            return .success
        }

        let succeeded = await unregister(deviceTokenId: deviceTokenId)

        guard succeeded else {
            let message = unregisterVM.errorMessage ?? "Failed to unregister device. Please try again."
            return .failed(message: message)
        }

        // Device was unregistered server-side — clear local bookkeeping and mark pending so the
        // next login re-registers this token (a fresh FCM token won't have this problem).
        UserDefaults.standard.removeObject(forKey: Keys.deviceTokenId)
        UserDefaults.standard.removeObject(forKey: Keys.lastRegisteredToken)
        UserDefaults.standard.set(true, forKey: Keys.pendingRegistration)

        clearLocalSessionData()
        return .success
    }

    /// Use for logout paths that must never be blocked (forced session-expiry logout, or after a
    /// successful account deletion — the session is already dead either way). Best-effort:
    /// attempts to unregister the current device token first (while the access token is still
    /// valid), then always performs the local logout data clear regardless of the outcome.
    func performLogout() async {
        let savedLastRegistered = UserDefaults.standard.string(forKey: Keys.lastRegisteredToken)
        let savedDeviceTokenId = UserDefaults.standard.object(forKey: Keys.deviceTokenId) as? Int
        let savedPending = UserDefaults.standard.bool(forKey: Keys.pendingRegistration)

        let unregisterSucceeded = await unregister(deviceTokenId: savedDeviceTokenId)

        if unregisterSucceeded {
            UserDefaults.standard.removeObject(forKey: Keys.deviceTokenId)
            UserDefaults.standard.removeObject(forKey: Keys.lastRegisteredToken)
            UserDefaults.standard.set(true, forKey: Keys.pendingRegistration)
        }

        clearLocalSessionData()

        if !unregisterSucceeded {
            // Unregister didn't happen or failed — restore prior bookkeeping so nothing is lost
            // and it can be retried on the next login.
            if let savedLastRegistered {
                UserDefaults.standard.set(savedLastRegistered, forKey: Keys.lastRegisteredToken)
            }
            if let savedDeviceTokenId {
                UserDefaults.standard.set(savedDeviceTokenId, forKey: Keys.deviceTokenId)
            }
            UserDefaults.standard.set(savedPending, forKey: Keys.pendingRegistration)
        }
    }

    /// Runs the existing shared logout data clear, preserving the raw FCM token across it
    /// (Firebase owns that token's lifecycle, not us) and whatever FCM bookkeeping the caller
    /// already committed to `UserDefaults` just before calling this.
    private func clearLocalSessionData() {
        let savedToken = UserDefaults.standard.string(forKey: Keys.fcmToken)
        let savedLastRegistered = UserDefaults.standard.string(forKey: Keys.lastRegisteredToken)
        let savedDeviceTokenId = UserDefaults.standard.object(forKey: Keys.deviceTokenId) as? Int
        let savedPending = UserDefaults.standard.bool(forKey: Keys.pendingRegistration)

        KeychainManager.shared.clearUserDefaultsAndKeychainData()
        UserDefaults.standard.set(false, forKey: "is_logged_in")

        // Clear the unread count (and, via its didSet, the app icon badge) now that
        // the session is actually gone — a stale badge shouldn't survive logout.
        NotificationCountViewModel.shared.unreadCount = 0

        // Restore what the shared clear just wiped.
        if let savedToken, !savedToken.isEmpty {
            UserDefaults.standard.set(savedToken, forKey: Keys.fcmToken)
        }
        if let savedLastRegistered {
            UserDefaults.standard.set(savedLastRegistered, forKey: Keys.lastRegisteredToken)
        }
        if let savedDeviceTokenId {
            UserDefaults.standard.set(savedDeviceTokenId, forKey: Keys.deviceTokenId)
        }
        UserDefaults.standard.set(savedPending, forKey: Keys.pendingRegistration)
    }

    /// Best-effort unregister of `deviceTokenId`. Never throws — failures are handled gracefully
    /// so logout is never blocked. Returns `true` only on a confirmed successful response.
    @discardableResult
    private func unregister(deviceTokenId: Int?) async -> Bool {
        guard let deviceTokenId else {
            print("🔔 No registered device token id — nothing to unregister")
            return false
        }

        // Only one unregister request in flight at a time — piggyback on it if one's already running.
        if let existing = unregisterTask {
            return await existing.value
        }

        let task = Task { @MainActor [weak self] () -> Bool in
            guard let self else { return false }

            let succeeded = await self.unregisterVM.unregister(tokenId: deviceTokenId)

            if succeeded {
                print("✅ FCM device token unregistered")
            } else {
                print("⚠️ FCM unregister failed:", self.unregisterVM.errorMessage ?? "unknown error", "— keeping local state for retry")
            }

            return succeeded
        }

        unregisterTask = task
        let result = await task.value
        unregisterTask = nil
        return result
    }
}
