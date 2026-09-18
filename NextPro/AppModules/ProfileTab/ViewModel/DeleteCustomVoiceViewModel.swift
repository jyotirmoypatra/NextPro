//
//  DeleteCustomVoiceViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/09/26.
//
import Foundation
import Combine



@MainActor
class DeleteCustomVoiceViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared
    @Published var addSuccess = false
    
    func deleteMessage(messageID:String) async {
       

        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
       
        guard !messageID.isEmpty else {
            errorMessage = "messageID Should not empty!"
            return
        }
    
        
        
        do {
            isLoading = true
            errorMessage = ""
            addSuccess = false

            let response = try await networkManager.DeleteVoiceMessage(id: messageID)
            if response.status {
                // Assign response to UI (no UserDefaults save)
                addSuccess = true
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
