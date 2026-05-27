//
//  UploadProfileImgViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine



@MainActor
class DeleteAccountViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var isDeleteSuccess = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared

    
    func deleteAccount() async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        
        do {
            isLoading = true
            errorMessage = ""

            let response = try await networkManager.deleteAccount()

            if response.status {
              
                isDeleteSuccess = true
            }else{
                errorMessage =  response.message ?? "Something Went Wrong!"
            }
           
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Fetch profile error:", error.localizedDescription)
        }

        isLoading = false
    }
}
