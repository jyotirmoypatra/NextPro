//
//  CreateNewPasswordViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine

@MainActor
class CreateNewPasswordViewModel: ObservableObject {

    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var updateSuccess = false
    let networkManager = NetworkManager.shared
    
    let fullPasswordPolicyMessage = """
    Password must meet the following requirements:
    • Minimum 8 characters
    • At least 1 uppercase letter (A–Z)
    • At least 1 lowercase letter (a–z)
    • At least 1 number (0–9)
    • At least 1 special character (!@#$%^&*)
    """


    func updatePassword(username: String) async {
        
        
        // Internet check
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        // Empty fields
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please enter both password fields."
            return
        }

        // POLICY CHECK
        guard isPasswordValid(newPassword) else {
            errorMessage = fullPasswordPolicyMessage
            return
        }

        // Match check
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        
        
        
        
        
        
        

        errorMessage = ""
        
        
        isLoading = true
        

        do {
            let response = try await networkManager.updatePassword(
                newPassword: newPassword,
                confirmPassword: confirmPassword,
                userName: username
            )

            isLoading = false

            if response.status {
               // KeychainManager.shared.save(newPassword, forKey: "user_password")
                updateSuccess = true
            } else {
                errorMessage = response.message
            }

        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
        
    }
}
