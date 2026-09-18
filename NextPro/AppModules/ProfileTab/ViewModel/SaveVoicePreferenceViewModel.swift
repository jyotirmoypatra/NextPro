//
//  SaveVoicePreferenceViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/09/26.
//

import Foundation
import Combine



@MainActor
class SaveVoicePreferenceViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""
    private let networkManager = NetworkManager.shared
    @Published var addSuccess = false
    
    func saveFullVoiceSetting(isActiveVoice: Bool,accessGrantedId:String ,accessDeniedDId:String,accessUnauthorizedId:String,welcomeId:String,patternId:String) async {
       

        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }
       
        guard !accessGrantedId.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        
        guard !accessDeniedDId.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        guard !accessUnauthorizedId.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        guard !welcomeId.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        guard !patternId.isEmpty else {
            errorMessage = "message Should not empty!"
            return
        }
        
        
        
        do {
            isLoading = true
            errorMessage = ""
            addSuccess = false

            let response = try await networkManager.saveVoiceMessageSetting(isActiveVoice: isActiveVoice, accessGrantedId: accessGrantedId, accessDeniedDId: accessDeniedDId, accessUnauthorizedId: accessUnauthorizedId, welcomeId: welcomeId, patternId: patternId)
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

