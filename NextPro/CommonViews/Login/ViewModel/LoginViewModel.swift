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

    let network = NetworkManager.shared

    func login() async {

        loginError = ""

        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        if trimmedEmail.isEmpty || trimmedPassword.isEmpty {
            loginError = "Please enter both email and password."
            return
        }

        if !network.hasInternet {
            loginError = "No internet connection."
            return
        }

        print("📡 Calling Login API…")
        isLoading = true

        do {
            let response = try await network.login(email: trimmedEmail, password: trimmedPassword)

            if response.status {
                print("✅ Login success")
                userType = response.userType ?? ""
                loginSuccess = true
            } else {
                loginError = response.message
            }

        } catch {
            print("❌ API ERROR:", error.localizedDescription)
            loginError = "Something went wrong. Try again."
        }

        isLoading = false
    }
}
