//
//  DeleteUserViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine


@MainActor
class DeleteUserViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false
    private let networkManager = NetworkManager.shared
    
    func deleteUser(id:String) async {


        guard networkManager.hasInternet else {
           errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }
        
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "User ID is missing"
            return
        }
    
        isFailedDueToNoInternet = false
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.deleteUser(userId: id)
            if response.status {
                isSuccess = true
            }else{
                errorMessage =  "Something Went Wrong!"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
