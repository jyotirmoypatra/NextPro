//
//  KeychainManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Security
import SwiftUI

class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {}

    func save(_ value: String, forKey key: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
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
        
        
        // Remove all stored keys for this app
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//            UserDefaults.standard.synchronize()
//        }
        
        //Remove all stored keys for this app except isUserInitialSetupCompleted
        if let bundleID = Bundle.main.bundleIdentifier {
            // Save the value you want to keep
            let isSetupCompleted = UserDefaults.standard.bool(forKey: "isUserInitialSetupCompleted")
            
            // Clear all UserDefaults
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            
            // Restore the value you want to keep
            UserDefaults.standard.set(isSetupCompleted, forKey: "isUserInitialSetupCompleted")
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


}
