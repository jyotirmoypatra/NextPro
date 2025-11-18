//
//  CreateNewPasswordViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import SwiftUI
import Combine

@MainActor
class CreateNewPasswordViewModel: ObservableObject {

    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var updateSuccess = false
    let network = NetworkManager.shared

    func updatePassword(username: String) async {
        
        errorMessage = ""
        
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill all fields"
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        // Internet check
        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        
        isLoading = true
        

        do {
            let response = try await NetworkManager.shared.updatePassword(
                newPassword: newPassword,
                confirmPassword: confirmPassword,
                userName: username
            )

            isLoading = false

            if response.status {
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
