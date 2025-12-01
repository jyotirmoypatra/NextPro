//
//  UploadProfileImgViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine



@MainActor
class UploadProfileImgViewModel: ObservableObject {

    @Published var userId = ""
    @Published var ImgBase64 = ""
    @Published var uploadSuccessMessage = ""
    @Published var isLoading = false
    @Published var uploadImgSuccess = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared

    let network = NetworkManager.shared
    
    func UploadImg() async {
        
        guard network.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            errorMessage = "User ID missing!"
            return
        }
        do {
            isLoading = true
            errorMessage = ""

            let response = try await networkManager.UploadProfileImage(userId: userId, base64: ImgBase64)

            if response.status {
                uploadImgSuccess = true
                uploadSuccessMessage = response.message
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
