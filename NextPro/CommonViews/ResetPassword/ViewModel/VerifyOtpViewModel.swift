//
//  VerifyOtpViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//

import Foundation
import Combine

import Foundation
import Combine

@MainActor
class VerifyOtpViewModel: ObservableObject {
    @Published var digit1 = ""
    @Published var digit2 = ""
    @Published var digit3 = ""
    @Published var digit4 = ""
    @Published var digit5 = ""
    @Published var digit6 = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var success = false

    
    private let network = NetworkManager.shared

    

    var otpCode: String {
        digit1 + digit2 + digit3 + digit4 + digit5 + digit6
    }

    
    func verifyOtp(emailId:String) async {
        
        print("email:\(emailId)")
        print("email:\(otpCode)")
        
        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        guard otpCode.count == 6 else {
            errorMessage = "Please enter a valid 6-digit code."
            return
        }
        
       

        isLoading = true
        errorMessage = ""
        
        print("email:\(emailId)")
        print("email:\(otpCode)")
        
        do {
            let response = try await network.requestVerifyOtp(email: emailId, otp: otpCode)
            print("✅ OTP Verified Successfully: \(response.message)")
            success = true
        } catch {
            print("❌ Error verifying OTP: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func reset() {
            digit1 = ""
            digit2 = ""
            digit3 = ""
            digit4 = ""
            digit5 = ""
            digit6 = ""
            isLoading = false
            errorMessage = ""
            success = false
        }
}
