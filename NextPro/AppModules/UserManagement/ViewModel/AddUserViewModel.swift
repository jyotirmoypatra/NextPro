//
//  AddUserViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class AddUserViewModel: ObservableObject {

    
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var Successflag = false
    @Published var isFailedDueToNoInternet = false
    let networkManager = NetworkManager.shared
    
    func addUser(request: AddUserRequest,isEditUser : Bool) async {

        guard networkManager.hasInternet else {
            isFailedDueToNoInternet = true
            return
        }

        isFailedDueToNoInternet = false
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {

            let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                    let data = try encoder.encode(request)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📤 AddUser Request JSON:\n\(jsonString)")
                    }
            
            
            let response = try await networkManager.addNewUser(body: request, isEditUser:isEditUser)
            
            if response.status{
                Successflag = true
            }else{
                errorMessage = response.message 
            }
            
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
}
