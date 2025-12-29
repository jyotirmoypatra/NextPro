//
//  LoginViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""

    @Published var loginError = ""
    @Published var isLoading = false
    @Published var loginSuccess = false
    @Published var userType = ""
    @Published var userName = ""
    @Published var isPasswordReset = true

    let network = NetworkManager.shared
    let fullPasswordPolicyMessage = """
    Password must meet the following requirements:
    • Minimum 8 characters
    • At least 1 uppercase letter (A–Z)
    • At least 1 lowercase letter (a–z)
    • At least 1 number (0–9)
    • At least 1 special character (!@#$%^&*)
    """

    func login() async {

        loginError = ""

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        
        
        // Internet check
        guard network.hasInternet else {
            loginError = "No internet connection."
            return
        }

        // Basic validation
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            loginError = "Please enter both email and password."
            return
        }

        // POLICY CHECK
        guard isPasswordValid(trimmedPassword) else {
            loginError = fullPasswordPolicyMessage
            return
        }
        
        
        
        

        isLoading = true

        do {
            let response = try await network.login(email: trimmedEmail, password: trimmedPassword)

            isLoading = false
            
            if response.status {
                
                print("✅ Login success")
                
                // Update values
                userType = response.user_type ?? ""
                userName = response.username ?? ""
                isPasswordReset = response.is_reset_password ?? true
                loginSuccess = true
                
                // Save tokens
                if let access = response.access {
                    KeychainManager.shared.save(access, forKey: "access_token")
                }
                
                if let refresh = response.refresh {
                    KeychainManager.shared.save(refresh, forKey: "refresh_token")
                }
                
                // Save user details
                UserDefaults.standard.set(response.user_id ?? "", forKey: "user_id")
                UserDefaults.standard.set(response.facility_id ?? "", forKey: "facility_id")
                UserDefaults.standard.set(response.username ?? "", forKey: "username")
                UserDefaults.standard.set(response.user_type ?? "", forKey: "user_type")
                UserDefaults.standard.set(response.is_reset_password ?? true, forKey: "isPssswordReset")
                UserDefaults.standard.set(true, forKey: "isUserInitialSetupCompleted")
               
                //digital key access
//                UserDefaults.standard.set(response.access_modes?.digitalKeyAccess ?? true, forKey: "digital_key_access")
//               
//                //remote access
//                let hasRemoteAccess = (response.access_modes?.remoteAccess?.remoteBLE ?? true) || (response.access_modes?.remoteAccess?.remoteWiFi ?? true)
//                UserDefaults.standard.set(hasRemoteAccess, forKey: "remote_access")
//
//                
//                // BLE access
//                let hasRemoteBLEAccess = response.access_modes?.remoteAccess?.remoteBLE ?? true
//                UserDefaults.standard.set(hasRemoteBLEAccess, forKey: "remote_ble")
//
//                // Wi-Fi access
//                let hasRemoteWIFIAccess = response.access_modes?.remoteAccess?.remoteWiFi ?? true
//                UserDefaults.standard.set(hasRemoteWIFIAccess, forKey: "remote_wifi")
                
                

                // BLE access
                let hasDigitalAccess = response.digital_access ?? false
                UserDefaults.standard.set(hasDigitalAccess, forKey: "digital_access")

                // Wi-Fi access
                let hasRemoteAccess = response.remote_access ?? false
                UserDefaults.standard.set(hasRemoteAccess, forKey: "remote_access")
                
               
            } else {
                // Backend error message
                loginError = response.message
            }

        } catch {
            isLoading = false
            print("❌ API ERROR:", error.localizedDescription)
            loginError = error.localizedDescription // show real message instead of generic
        }

        
    }
}
