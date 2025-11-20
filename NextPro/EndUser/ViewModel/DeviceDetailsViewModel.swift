//
//  DeviceDetailsViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine

@MainActor
class DeviceDetailsViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var deviceDetails: DeviceDetailsResponse?
    @Published var errorMessage = ""

    private let network = NetworkManager.shared

    func fetchDeviceDetails() async {
        errorMessage = ""
        isLoading = true

        guard let token = KeychainManager.shared.get("access_token") else {
            errorMessage = "Missing access token."
            isLoading = false
            return
        }

        do {
            let response = try await network.deviceDetails(accessToken: token)
            print("✅ Device Details Success")
            self.deviceDetails = response
            
            //save to userdefaults
            saveDetailsLocally(response)

        } catch {
            print("❌ Device Details Error:", error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    // MARK: - Save To UserDefaults
        private func saveDetailsLocally(_ response: DeviceDetailsResponse) {
            if let encoded = try? JSONEncoder().encode(response) {
                UserDefaults.standard.set(encoded, forKey: "device_details")
            }
        }
    
    func loadSavedDetails() {
            if let data = UserDefaults.standard.data(forKey: "device_details"),
               let decoded = try? JSONDecoder().decode(DeviceDetailsResponse.self, from: data) {
                self.deviceDetails = decoded
                print("📦 Loaded Saved Device Details")
            }
        }
    
}

