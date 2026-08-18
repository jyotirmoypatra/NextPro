//
//  SetControllerDoorUnlockTimeViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/08/26.
//

import Foundation
import Combine


@MainActor
class SetControllerDoorUnlockTimeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var success: Bool = false
    private let networkManager = NetworkManager.shared

    func setDuration(controllerSerial:String,duration:Int) async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await networkManager.setControllerDoorUnlockTime(controllerSerial:controllerSerial , duration: duration)
            if response.status {
                // API success
                success = true
                errorMessage = ""
                successMessage = response.message ?? "Door opening time updated successfully on cloud"
                
            } else {
                // API returned status: false
                success = false
                errorMessage = response.message ?? "Failed to update door opening time on cloud!"
                successMessage = ""
                
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
