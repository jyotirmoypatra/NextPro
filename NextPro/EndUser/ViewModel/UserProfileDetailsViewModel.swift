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
    @Published var accountStatus = ""
    @Published var organization = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared

    let network = NetworkManager.shared
    
    func fetchUserProfile() async {
        guard let userId = UserDefaults.standard.string(forKey: "facility_id") else {
            errorMessage = "User ID missing!"
            return
        }

        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        
        do {
            isLoading = true
            errorMessage = ""

            let response = try await networkManager.UserProfileDetails(id: userId)

            // Assign response to UI (no UserDefaults save)
            fullName = response.data.full_name
            phoneNumber = response.data.phone_number
            email = response.data.email
            accountStatus = response.data.status
            organization = response.data.organization

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Fetch profile error:", error.localizedDescription)
        }

        isLoading = false
    }
}
