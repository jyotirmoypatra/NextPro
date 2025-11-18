//
//  LoginViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine

//@MainActor
//class LoginViewModel: ObservableObject {
//    
//    @Published var email = ""
//    @Published var password = ""
//
//    @Published var loginError = ""
//    @Published var isLoading = false
//    @Published var loginSuccess = false
//    @Published var userType = ""
//    @Published var userName = ""
//
//    let network = NetworkManager.shared
//
//    func login() async {
//
//        loginError = ""
//
//        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
//        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
//
//        if trimmedEmail.isEmpty || trimmedPassword.isEmpty {
//            loginError = "Please enter both email and password."
//            return
//        }
//
//        if !network.hasInternet {
//            loginError = "No internet connection."
//            return
//        }
//
//        print("📡 Calling Login API…")
//        isLoading = true
//
//        do {
//            let response = try await network.login(email: trimmedEmail, password: trimmedPassword)
//
//            if response.status {
//                print("✅ Login success")
//                userType = response.user_type ?? ""
//                userName = response.username ?? ""
//                loginSuccess = true
//                
//                
//              // Save tokens to keychain
//               if let access = response.access {
//                   KeychainManager.shared.save(access, forKey: "access_token")
//               }
//
//               if let refresh = response.refresh {
//                   KeychainManager.shared.save(refresh, forKey: "refresh_token")
//               }
//                
//                UserDefaults.standard.set(response.user_id, forKey: "user_id")
//                UserDefaults.standard.set(response.username, forKey: "username")
//                UserDefaults.standard.set(response.user_type ?? "", forKey: "user_type")
//                
//                
//            } else {
//                loginError = response.message
//            }
//
//        } catch {
//            print("❌ API ERROR:", error.localizedDescription)
//            loginError = "Something went wrong. Try again."
//        }
//
//        isLoading = false
//    }
//}


@MainActor
class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""

    @Published var loginError = ""
    @Published var isLoading = false
    @Published var loginSuccess = false
    @Published var userType = ""
    @Published var userName = ""

    let network = NetworkManager.shared

    func login() async {

        loginError = ""

        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        // Basic validation
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            loginError = "Please enter both email and password."
            return
        }

        // Internet check
        guard network.hasInternet else {
            loginError = "No internet connection."
            return
        }

        isLoading = true

        do {
            let response = try await network.login(email: trimmedEmail, password: trimmedPassword)

            DispatchQueue.main.async {
                self.isLoading = false
                if response.status {
                    
                    print("✅ Login success")
                    
                    // Update values
                    self.userType = response.user_type ?? ""
                    self.userName = response.username ?? ""
                    self.loginSuccess = true
                    
                    // Save tokens
                    if let access = response.access {
                        KeychainManager.shared.save(access, forKey: "access_token")
                    }
                    
                    if let refresh = response.refresh {
                        KeychainManager.shared.save(refresh, forKey: "refresh_token")
                    }
                    
                    // Save user details
                    UserDefaults.standard.set(response.user_id ?? "", forKey: "user_id")
                    UserDefaults.standard.set(response.username ?? "", forKey: "username")
                    UserDefaults.standard.set(response.user_type ?? "", forKey: "user_type")
                    
                } else {
                    // Backend error message
                    self.loginError = response.message
                }
            }

        } catch {
            DispatchQueue.main.async {
                print("❌ API ERROR:", error.localizedDescription)
                self.loginError = error.localizedDescription // show real message instead of generic
            }
        }

        
    }
}
