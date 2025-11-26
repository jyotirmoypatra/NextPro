//
//  forgetPasswordRequestViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//

import Foundation
import Combine


@MainActor
class ForgetPasswordRequestViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var success: Bool = false
    let network = NetworkManager.shared
    private let networkManager = NetworkManager.shared

    func sendRequest() async {
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty."
            return
        }
        
        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await networkManager.requestForgetPassword(email: email)
            print("✅ Forget Password Success: \(response.message)")
            success = true
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
