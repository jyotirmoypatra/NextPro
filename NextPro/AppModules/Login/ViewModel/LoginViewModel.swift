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
    @Published var is_admin = false
    @Published var userName = ""
    @Published var isPasswordReset = true

    let networkManager = NetworkManager.shared
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
        guard networkManager.hasInternet else {
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
            let response = try await networkManager.login(email: trimmedEmail, password: trimmedPassword)

            isLoading = false
            
            if response.status {
                
                print("✅ Login success")
                
                // Update values
                is_admin = response.is_admin ?? false
                //is_admin = true
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
                
                UserDefaults.standard.set(true, forKey: "is_logged_in")
                // Save user details
                UserDefaults.standard.set(response.user_id ?? "", forKey: "user_id")
                UserDefaults.standard.set(response.facility_id ?? "", forKey: "facility_id")
                UserDefaults.standard.set(response.username ?? "", forKey: "username")
                UserDefaults.standard.set(response.user_type ?? "", forKey: "user_type")
                UserDefaults.standard.set(response.is_admin ?? false, forKey: "is_admin")
                //UserDefaults.standard.set(true, forKey: "is_admin")
                UserDefaults.standard.set(response.is_reset_password ?? true, forKey: "isPssswordReset")
                UserDefaults.standard.set(true, forKey: "isUserInitialSetupCompleted")
               

                // Digital access Tab
                let hasDigitalAccess = response.device_access_details?.is_digital  ?? false
                UserDefaults.standard.set(hasDigitalAccess, forKey: "digital_access")

                // Remote access tab
                let hasRemoteAccess = response.device_access_details?.is_remote  ?? false
                UserDefaults.standard.set(hasRemoteAccess, forKey: "remote_access")
                
                // Remote  wifi access
                let hasRemoteWifiAccess = response.device_access_details?.is_wifi  ?? false
                UserDefaults.standard.set(hasRemoteWifiAccess, forKey: "remote_wifi")
                // Remote access tab
                let hasRemoteBleAccess = response.device_access_details?.is_ble  ?? false
                UserDefaults.standard.set(hasRemoteBleAccess, forKey: "remote_ble")
                
                
                //permissions user management
                let facilityUserPermission = response.permission?.facility_user
                let userRead = facilityUserPermission?.read ?? false
                let userWrite = facilityUserPermission?.write ?? false
                UserDefaults.standard.set(userRead, forKey: "user_management_read")
                UserDefaults.standard.set(userWrite, forKey: "user_management_write")
                
                //permissions device management
                let deviceManagement = response.permission?.device_mapping
                let deviceRead = deviceManagement?.read ?? false
                let deviceWrite = deviceManagement?.write ?? false
                UserDefaults.standard.set(deviceRead, forKey: "device_management_read")
                UserDefaults.standard.set(deviceWrite, forKey: "device_management_write")
                
                
               
            } else {
                // Backend error message
                loginError = response.message ?? "Something Went Wrong"
            }

        } catch {
            isLoading = false
            print("❌ API ERROR:", error.localizedDescription)
            loginError = error.localizedDescription // show real message instead of generic
        }

        
    }
}
