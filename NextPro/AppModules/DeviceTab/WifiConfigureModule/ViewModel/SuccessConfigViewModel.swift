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
    @Published var lat: String?
    @Published var long: String?
    @Published var address: String?
    private let networkManager = NetworkManager.shared

    
    func successConfig(isSuccess: Bool,deviceSerial: String,wifiSSid:String,wifiPass:String) async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            errorMessage = "User ID missing!"
            return
        }
        
        isLoading = true
        errorMessage = nil
        

        do {
            let response = try await networkManager.successDeviceConfig(userId: userId, isSuccess: isSuccess, deviceSerial: deviceSerial, ssid: wifiSSid, password: wifiPass, latitude: lat ?? "" , longitude: long ?? "",current_address: address ?? "" )
            print("✅ Device Config Successfully: \(response.message)")
            success = true
        } catch {
            print("❌ Error device config: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
   
}
