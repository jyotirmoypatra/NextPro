//
//  SuccessConfigViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/01/26.
//


import Foundation
import Combine


@MainActor
class SuccessConfigViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var success = false
    private let networkManager = NetworkManager.shared

    
    func successConfig(isSuccess: Bool,deviceSerial: String) async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        isLoading = true
        errorMessage = nil
        

        do {
            let response = try await networkManager.successDeviceConfig(isSuccess: isSuccess,deviceSerial:deviceSerial)
            print("✅ Device Config Successfully: \(response.message)")
            success = true
        } catch {
            print("❌ Error device config: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
   
}
