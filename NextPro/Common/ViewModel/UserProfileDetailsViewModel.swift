//
//  DeviceDetailsViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine



@MainActor
class UserProfileDetailsViewModel: ObservableObject {

    @Published var fullName = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var image_url = ""
    @Published var accountStatus = ""
    @Published var organization = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isSuccess = false
    private let networkManager = NetworkManager.shared
    @Published var isFailedDueToNoInternet = false

    
    func fetchUserProfile() async {
        
        guard networkManager.hasInternet else {
           errorMessage = ""
            isFailedDueToNoInternet = true
            return
        }
        
        isFailedDueToNoInternet = false
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            errorMessage = "User ID missing!"
            return
        }

       
        
        
        do {
            isLoading = true
            errorMessage = ""
            isFailedDueToNoInternet = false
            let response = try await networkManager.UserProfileDetails(id: userId)
            
            if response.status{
                
                isSuccess = true
                // Assign response to UI (no UserDefaults save)
                fullName = response.data.full_name ?? ""
                phoneNumber = response.data.phone_number ?? ""
                email = response.data.email ?? ""
                accountStatus = response.data.status ?? ""
                organization = response.data.organization ?? ""
                image_url = response.data.image_url ?? ""
                
                 let  is_admin = response.data.is_admin ?? false
                UserDefaults.standard.set(is_admin, forKey: "is_admin")
                
                // Digital access Tab
                let hasDigitalAccess = response.data.is_digital
                UserDefaults.standard.set(hasDigitalAccess, forKey: "digital_access")

                // Remote access tab
                let hasRemoteAccess = response.data.is_remote
                UserDefaults.standard.set(hasRemoteAccess, forKey: "remote_access")
                
                // Remote  wifi access
                let hasRemoteWifiAccess = response.data.is_wifi
                UserDefaults.standard.set(hasRemoteWifiAccess, forKey: "remote_wifi")
                // Remote access tab
                let hasRemoteBleAccess = response.data.is_ble
                UserDefaults.standard.set(hasRemoteBleAccess, forKey: "remote_ble")
                
            }else{
                errorMessage = response.message ?? "Something Went Wrong"
            }

        } catch {
            
            errorMessage = error.localizedDescription
            print("❌ Fetch profile error:", error.localizedDescription)
        }

        isLoading = false
    }
}
