//
//  LoginViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class ValidateEmailViewModel: ObservableObject {

    @Published var email = ""
   
    @Published var validateEmailError = ""
    @Published var isLoading = false
    @Published var validateSuccess = false
    @Published var isPasswordReset = true
    @Published var isAggrementAccept = false

    let networkManager = NetworkManager.shared

    func validate() async {

        validateEmailError = ""

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        // Internet check
        guard networkManager.hasInternet else {
           validateEmailError = "Please check your internet and try again."
            return
        }
        
        // Basic validation
        guard !trimmedEmail.isEmpty else {
            validateEmailError = "Please enter email."
            return
        }

        

        validateEmailError = ""
        isLoading = true

        do {
            let response = try await networkManager.ValidateEmail(email: trimmedEmail)

            isLoading = false
            
            if response.status {
                
                print("✅ Email Validate success")
                
                // Update values
               isPasswordReset = response.is_reset_password
               isAggrementAccept = response.is_aggrement_accept
                
//               isPasswordReset = false
//                 isAggrementAccept = false
                validateSuccess = true
                
               // Save user details
                UserDefaults.standard.set(response.email ?? email, forKey: "email")
                UserDefaults.standard.set(response.is_aggrement_accept, forKey: "is_aggrement_accept")

               
            } else {
                // Backend error message
                validateEmailError = response.message
            }

        } catch {
            isLoading = false
            print("❌ API ERROR:", error.localizedDescription)
            validateEmailError = error.localizedDescription // show real message instead of generic
        }

        
    }
    
    
    func reset() {
            email = ""
            validateEmailError = ""
            isLoading = false
            validateSuccess = false
            isPasswordReset = true
            isAggrementAccept = false
        }
}
