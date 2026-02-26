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
    
    @Published var canReadUserManagement = false
    @Published var canWriteUserManagement = false
    
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
//                let oldValue = UserDefaults.standard.bool(forKey: "is_admin")
//
//                if oldValue != is_admin {
//                    UserDefaults.standard.set(is_admin, forKey: "is_admin")
//
//                    NotificationCenter.default.post(name: .roleChanged, object: nil)
//                }
                
                UserDefaults.standard.set(is_admin, forKey: "is_admin")
                
                // Digital access Tab
                let hasDigitalAccess = response.data.user_role_detail?.is_digital
                UserDefaults.standard.set(hasDigitalAccess, forKey: "digital_access")

                // Remote access tab
                let hasRemoteAccess = response.data.user_role_detail?.is_remote
                UserDefaults.standard.set(hasRemoteAccess, forKey: "remote_access")
                
                // Remote  wifi access
                let hasRemoteWifiAccess = response.data.user_role_detail?.is_wifi
                UserDefaults.standard.set(hasRemoteWifiAccess, forKey: "remote_wifi")
                // Remote access tab
                let hasRemoteBleAccess = response.data.user_role_detail?.is_ble
                UserDefaults.standard.set(hasRemoteBleAccess, forKey: "remote_ble")
                
                // PERMISSION PARSING
                let facilityUserPermission = response.data.permissions?.facility_user

                let read = facilityUserPermission?.read ?? false
                let write = facilityUserPermission?.write ?? false

                canReadUserManagement = read
                canWriteUserManagement = write

                // save for global use
                UserDefaults.standard.set(read, forKey: "user_management_read")
                UserDefaults.standard.set(write, forKey: "user_management_write")
                
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
