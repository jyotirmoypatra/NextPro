//
//  AddNewVoiceMessageViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/09/26.
//
import Foundation
import Combine



@MainActor
class AddNewVoiceMessageViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared
    @Published var addSuccess = false
    
    func addMessage(category:String, message:String) async {
       

        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
       
        guard !category.isEmpty else {
            errorMessage = "Category Should not empty!"
            return
        }
        
        guard !message.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        
        
        
        do {
            isLoading = true
            errorMessage = ""
            addSuccess = false

            let response = try await networkManager.AddNewVoiceMessage(category: category, message: message)
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
