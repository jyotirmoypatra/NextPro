//
//  DeviceDetailsViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine



@MainActor
class UserProfileEditViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared
    @Published var editSuccess = false
    let network = NetworkManager.shared
    
    func editProfile(fullName:String, phoneNo:String) async {
       

        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        
        guard !fullName.isEmpty else {
            errorMessage = "FullName Should not empty!"
            return
        }
        
        guard !phoneNo.isEmpty else {
            errorMessage = "Phone number Should not empty!"
            return
        }
        
        do {
            isLoading = true
            errorMessage = ""

            let response = try await networkManager.EditUserProfileDetails(fullName: fullName, phone: phoneNo)
            if response.status {
                // Assign response to UI (no UserDefaults save)
                editSuccess = true
            }else{
                errorMessage =  response.message
            }

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Fetch profile error:", error.localizedDescription)
        }

        isLoading = false
    }
}
