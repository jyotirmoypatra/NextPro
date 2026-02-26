//
//  GenerateUniqueNfcViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class GenerateUniqueNfcViewModel: ObservableObject {

    @Published var errorMessage: String?
    @Published var nfcCardId: Int?
    @Published var isLoading = false
    @Published var Successflag = false
    @Published var isFailedDueToNoInternet = false
    let networkManager = NetworkManager.shared

    func generateNfcId() async {

        guard networkManager.hasInternet else {
           errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }
        
        isFailedDueToNoInternet = false
        errorMessage = nil
        isLoading = true
        
        defer { isLoading = false }

        do {
           let response = try await networkManager.generateUniqueNfcId()

            isLoading = false
            
            if response.status {
                Successflag = true
                nfcCardId = response.nfc_number
            } else {
               errorMessage = "Something Went Wrong!"
            }

        } catch {
            isLoading = false
            print("❌ API ERROR:", error.localizedDescription)
            errorMessage = error.localizedDescription // show real message instead of generic
        }

        
    }
}
