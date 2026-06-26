//
//  GetUserDetailsViewModel.swift.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine


@MainActor
class GetUserDetailsViewModel: ObservableObject {

    @Published var userid = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false
    private let networkManager = NetworkManager.shared
    @Published var userData :  GetUserData?
    
    func getUserDetails() async {
        userData = nil

        guard networkManager.hasInternet else {
           errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }
        
        guard !userid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "User ID is missing"
            return
        }
    
        isFailedDueToNoInternet = false
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.getUserDetails(userId: userid)
            if response.status {
                userData = response.data
                print("👉 ViewModel:", response.data.id, response.data.full_name)
            }else{
                errorMessage =  "Something Went Wrong!"
            }
        } catch {
            userData = nil
            errorMessage = error.localizedDescription
            print("❌ Decode/API Error:", error)
        }
    }

}
