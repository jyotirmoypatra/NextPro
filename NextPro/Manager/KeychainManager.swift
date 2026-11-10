//
//  KeychainManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Security
import SwiftUI

struct StoredAccount: Codable, Identifiable {
    let id: String
    let email: String
    let userID: String
    let username: String
    let fullname: String?
    let imageURL: String?
    let accessToken: String
    let refreshToken: String
    // Encrypted MQTT configuration
    var ctxBlob: String? = nil
}

class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {}

    private let storedAccountsKey = "stored_accounts"
    private let removedAccountsKey = "removed_stored_accounts"

    
    func saveCurrentAccount(
        fullName: String? = nil,
        imageURL: String? = nil,
        ctxBlob: String? = nil
    ) {
        guard let email = UserDefaults.standard.string(forKey: "email"),
              !email.isEmpty else { return }

        let userID = UserDefaults.standard.string(forKey: "user_id") ?? ""

        guard !userID.isEmpty else { return }

        let removedAccounts = UserDefaults.standard.stringArray(forKey: removedAccountsKey) ?? []

        guard !removedAccounts.contains(userID) else { return }

        // Get existing account list
        var accounts = storedAccounts()

        // Preserve previously saved ctxBlob for this account
        let existingBlob = accounts.first {
            $0.userID == userID
        }?.ctxBlob

        let account = StoredAccount(
            id: userID,
            email: email,
            userID: userID,
            username: UserDefaults.standard.string(forKey: "username") ?? "",
            fullname: fullName ?? UserDefaults.standard.string(forKey: "fullname") ?? "",
            imageURL: imageURL ?? UserDefaults.standard.string(forKey: "image_url") ?? "",
            accessToken: get("access_token") ?? "",
            refreshToken: get("refresh_token") ?? "",
            ctxBlob: ctxBlob ?? existingBlob
        )

        accounts.removeAll {
            $0.id == account.id ||
            $0.userID == account.userID ||
            $0.email.caseInsensitiveCompare(account.email) == .orderedSame
        }

        accounts.append(account)

        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: storedAccountsKey)
        }
    }

    func updateCurrentAccountProfile(fullName: String, imageURL: String) {
        guard let email = UserDefaults.standard.string(forKey: "email"), !email.isEmpty else { return }

        var accounts = storedAccounts()
        guard let index = accounts.firstIndex(where: {
            $0.email.caseInsensitiveCompare(email) == .orderedSame
        }) else { return }

        let account = accounts[index]
        accounts[index] = StoredAccount(
            id: account.userID,
            email: account.email,
            userID: account.userID,
            username: account.username,
            fullname: fullName.isEmpty ? account.fullname : fullName,
            imageURL: imageURL,
            accessToken: account.accessToken,
            refreshToken: account.refreshToken,
            ctxBlob: account.ctxBlob
        )

        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: storedAccountsKey)
        }
    }
    
    func updateAccountTokens(
        userID: String,
        accessToken: String?,
        refreshToken: String?
    ) {
        guard !userID.isEmpty else { return }

        var accounts = storedAccounts()

        guard let index = accounts.firstIndex(where: {
            $0.userID == userID
        }) else {
            print("❌ Account not found for token update: \(userID)")
            return
        }

        let account = accounts[index]

        accounts[index] = StoredAccount(
            id: account.id,
            email: account.email,
            userID: account.userID,
            username: account.username,
            fullname: account.fullname,
            imageURL: account.imageURL,
            accessToken: (accessToken?.isEmpty == false)
                ? accessToken!
                : account.accessToken,
            refreshToken: (refreshToken?.isEmpty == false)
                ? refreshToken!
                : account.refreshToken,
            ctxBlob: account.ctxBlob
        )

        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: storedAccountsKey)
            print("✅ Tokens updated for account: \(userID)")
        }
    }
    
    func updateAccountAfterSwitch(
        userID: String,
        response: LoginResponseModel
    ) -> Bool {

        guard !userID.isEmpty,
              let accessToken = response.access,
              let refreshToken = response.refresh,
              let ctxBlob = response.ctx_blob else {
            print("❌ Missing account switch response data")
            return false
        }

        var accounts = storedAccounts()

        guard let index = accounts.firstIndex(where: {
            $0.userID == userID
        }) else {
            print("❌ Saved account not found")
            return false
        }

        let oldAccount = accounts[index]

        accounts[index] = StoredAccount(
            id: oldAccount.id,
            email: oldAccount.email,
            userID: oldAccount.userID,
            username: response.username ?? oldAccount.username,
            fullname: response.full_name ?? oldAccount.fullname,
            imageURL: oldAccount.imageURL,
            accessToken: accessToken,
            refreshToken: refreshToken,
            ctxBlob: ctxBlob
        )

        guard let data = try? JSONEncoder().encode(accounts) else {
            print("❌ Failed to encode updated accounts")
            return false
        }

        UserDefaults.standard.set(data, forKey: storedAccountsKey)

        print("✅ Account updated after switch")
        return true
    }
    
    func updateActiveAccountDetails(
        _ account: StoredAccount,
        response: LoginResponseModel
    ) {
        let defaults = UserDefaults.standard

        // Account details
        defaults.set(account.email, forKey: "email")
        defaults.set(response.user_id ?? account.userID, forKey: "user_id")
        defaults.set(response.facility_id ?? "", forKey: "facility_id")
        defaults.set(response.username ?? account.username, forKey: "username")
        defaults.set(response.full_name ?? account.fullname ?? "", forKey: "fullname")
        defaults.set(response.user_type ?? "", forKey: "user_type")

        // Account status
        defaults.set(response.is_admin ?? false, forKey: "is_admin")
        defaults.set(response.is_reset_password ?? true, forKey: "isPssswordReset")
        defaults.set(response.is_aggrement_accept ?? false, forKey: "is_logged_in")

        // Device access
        defaults.set(response.device_access_details?.is_digital ?? false, forKey: "digital_access")
        defaults.set(response.device_access_details?.is_remote ?? false, forKey: "remote_access")
        defaults.set(response.device_access_details?.is_wifi ?? false, forKey: "remote_wifi")
        defaults.set(response.device_access_details?.is_ble ?? false, forKey: "remote_ble")

        // User management permissions
        defaults.set(response.permission?.facility_user?.read ?? false, forKey: "user_management_read")
        defaults.set(response.permission?.facility_user?.write ?? false, forKey: "user_management_write")

        // Device management permissions
        defaults.set(response.permission?.wifi_configuration?.read ?? false, forKey: "device_management_read")
        defaults.set(response.permission?.wifi_configuration?.write ?? false, forKey: "device_management_write")

        defaults.set(true, forKey: "isUserInitialSetupCompleted")

        print("✅ Active account details updated")
    }

    func storedAccounts() -> [StoredAccount] {
        guard let data = UserDefaults.standard.data(forKey: storedAccountsKey),
              let accounts = try? JSONDecoder().decode([StoredAccount].self, from: data) else {
            return []
        }
        let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            if let jsonData = try? encoder.encode(accounts),
               let jsonString = String(data: jsonData, encoding: .utf8) {
              //  print("Stored Accounts:\n\(jsonString)")
            }
        return accounts
    }

    func removeStoredAccount(_ account: StoredAccount) {
        var accounts = storedAccounts()
        accounts.removeAll {
            $0.id == account.id || $0.userID == account.userID
        }

        var removedAccounts = UserDefaults.standard.stringArray(forKey: removedAccountsKey) ?? []
        if !removedAccounts.contains(account.userID) {
            removedAccounts.append(account.userID)
            UserDefaults.standard.set(removedAccounts, forKey: removedAccountsKey)
        }

        if accounts.isEmpty {
            UserDefaults.standard.removeObject(forKey: storedAccountsKey)
        } else if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: storedAccountsKey)
        }
    }

    func clearRemovedAccount(_ userID: String) {
        var removedAccounts = UserDefaults.standard.stringArray(forKey: removedAccountsKey) ?? []
        removedAccounts.removeAll { $0 == userID }
        UserDefaults.standard.set(removedAccounts, forKey: removedAccountsKey)
    }

//    func activate(_ account: StoredAccount) {
//        save(account.accessToken, forKey: "access_token")
//        save(account.refreshToken, forKey: "refresh_token")
//        UserDefaults.standard.set(account.email, forKey: "email")
//        UserDefaults.standard.set(account.userID, forKey: "user_id")
//        UserDefaults.standard.set(account.username, forKey: "username")
//        UserDefaults.standard.set(true, forKey: "is_logged_in")
//    }
//    func activate(_ account: StoredAccount) {
//
//        // 1. Stop previous account's MQTT connection
//        MQTTManager.shared.disconnect()
//
//        // 2. Remove previous account's MQTT credentials
//        delete("mqtt_host")
//        delete("mqtt_port")
//        delete("device_port")
//        delete("mqtt_username")
//        delete("mqtt_password")
//
//        // 3. Activate selected account tokens
//        save(account.accessToken, forKey: "access_token")
//        save(account.refreshToken, forKey: "refresh_token")
//
//        UserDefaults.standard.set(account.email, forKey: "email")
//        UserDefaults.standard.set(account.userID, forKey: "user_id")
//        UserDefaults.standard.set(account.username, forKey: "username")
//        UserDefaults.standard.set(true, forKey: "is_logged_in")
//
//        // 4. Restore selected account's MQTT configuration
//        guard let ctxBlob = account.ctxBlob, !ctxBlob.isEmpty else {
//            print("❌ MQTT ctx_blob missing for this account. Re-login required.")
//            return
//        }
//
//        do {
//            let creds = try MQTTBlobDecoder.decrypt(
//                ctxBlob: ctxBlob,
//                accessToken: account.accessToken,
//                userId: account.userID
//            )
//
//            save(creds.host, forKey: "mqtt_host")
//            save(String(creds.app_port), forKey: "mqtt_port")
//            save(String(creds.device_port), forKey: "device_port")
//            save(creds.username, forKey: "mqtt_username")
//            save(creds.password, forKey: "mqtt_password")
//
//            print("✅ MQTT credentials restored for: \(account.email)")
//
//        } catch {
//            print("❌ MQTT credential restoration failed: \(error)")
//        }
//    }
    
    func activate(_ account: StoredAccount) -> Bool {

        guard let ctxBlob = account.ctxBlob,
              !ctxBlob.isEmpty else {
            print("❌ MQTT ctx_blob missing")
            return false
        }

        do {
            // Decrypt MQTT credentials first
            let creds = try MQTTBlobDecoder.decrypt(
                ctxBlob: ctxBlob,
                accessToken: account.accessToken,
                userId: account.userID
            )

            // Disconnect previous account
            MQTTManager.shared.disconnect()

            // Clear previous MQTT credentials
            delete("mqtt_host")
            delete("mqtt_port")
            delete("device_port")
            delete("mqtt_username")
            delete("mqtt_password")

            // Save new account tokens
            save(account.accessToken, forKey: "access_token")
            save(account.refreshToken, forKey: "refresh_token")

            // Activate account
            UserDefaults.standard.set(account.email, forKey: "email")
            UserDefaults.standard.set(account.userID, forKey: "user_id")
            UserDefaults.standard.set(account.username, forKey: "username")
            UserDefaults.standard.set(true, forKey: "is_logged_in")

            // Restore MQTT credentials
            save(creds.host, forKey: "mqtt_host")
            save(String(creds.app_port), forKey: "mqtt_port")
            save(String(creds.device_port), forKey: "device_port")
            save(creds.username, forKey: "mqtt_username")
            save(creds.password, forKey: "mqtt_password")

            print("✅ Account activated: \(account.email)")

            return true

        } catch {
            print("❌ MQTT decryption failed: \(error)")
            return false
        }
    }
    
    
    func getOrCreateDeviceID() -> String {
        let key = "device_id"

        if let existingID = get(key),
           UUID(uuidString: existingID) != nil {
            return existingID
        }

        let newDeviceID = UUID().uuidString.lowercased()
        save(newDeviceID, forKey: key)

        return newDeviceID
    }


    func save(_ value: String, forKey key: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        ]

        SecItemDelete(query as CFDictionary) // Remove existing
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        return nil
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
    
    func loadUsername() -> String?{
        return UserDefaults.standard.string(forKey: "username") ?? "Unknown User"
    }
    
    func clearUserDefaultsAndKeychainData() {
        
        KeychainManager.shared.delete("access_token")
        KeychainManager.shared.delete("refresh_token")
        KeychainManager.shared.delete("mqtt_host")
        KeychainManager.shared.delete("mqtt_port")
        KeychainManager.shared.delete("device_port")
        KeychainManager.shared.delete("mqtt_username")
        KeychainManager.shared.delete("mqtt_password")
        
        
        // Remove all stored keys for this app
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//            UserDefaults.standard.synchronize()
//        }
        
        //Remove all stored keys for this app except isUserInitialSetupCompleted
        if let bundleID = Bundle.main.bundleIdentifier {
            // Save the value you want to keep
            let isSetupCompleted = UserDefaults.standard.bool(forKey: "isUserInitialSetupCompleted")
            let savedAccounts = UserDefaults.standard.data(forKey: storedAccountsKey)
            let removedAccounts = UserDefaults.standard.stringArray(forKey: removedAccountsKey)
            
            // Clear all UserDefaults
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            
            // Restore the value you want to keep
            UserDefaults.standard.set(isSetupCompleted, forKey: "isUserInitialSetupCompleted")
            UserDefaults.standard.set(savedAccounts, forKey: storedAccountsKey)
            UserDefaults.standard.set(removedAccounts, forKey: removedAccountsKey)
        }

        
        print("🧹 UserDefaults cleared successfully.")
    }

    
    func resetToLogin() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView(skipSplash: true))
                window.makeKeyAndVisible()
            }
        }
    }

    func resetToHome(initialTab: Int = 0) {
        UserDefaults.standard.set(initialTab, forKey: "home_initial_tab")
        
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView(skipSplash: true))
                window.makeKeyAndVisible()
            }
        }
    }


}
