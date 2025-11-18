//
//  CreateNewPasswordViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import SwiftUI
import Combine

class CreateNewPasswordViewModel: ObservableObject {

    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var updateSuccess = false
    @Published var userType = ""

    func updatePassword() async {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill all fields"
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await NetworkManager.shared.updatePassword(
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )

            DispatchQueue.main.async {
                self.isLoading = false

                if response.status {
                    self.userType = response.userType ?? ""
                    self.updateSuccess = true
                } else {
                    self.errorMessage = response.message
                }
            }

        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
