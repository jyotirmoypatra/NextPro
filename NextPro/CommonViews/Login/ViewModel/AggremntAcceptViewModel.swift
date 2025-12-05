//
//  LoginViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class AggremntAcceptViewModel: ObservableObject {

    @Published var ErrorMessage = ""
    @Published var isLoading = false
    @Published var isAggrementAccepted = false
    @Published var Successflag = false
  

    let network = NetworkManager.shared

    func accept() async {

        ErrorMessage = ""


        // Internet check
        guard network.hasInternet else {
            ErrorMessage = "Please check your internet and try again."
            return
        }
        
        guard let userEmail = UserDefaults.standard.string(forKey: "email") else {
            ErrorMessage = "Email missing!"
            return
        }

        

        ErrorMessage = ""
        isLoading = true

        do {
            let response = try await network.AggremntAccept(userEmail: userEmail, isAccepted: isAggrementAccepted)

            isLoading = false
            
            if response.status {
                
                print("✅ Aggremnt Accepted success")
         
                Successflag = true
                
               // Save user details
                UserDefaults.standard.set(response.status, forKey: "is_aggrement_accept")

               
            } else {
                // Backend error message
                ErrorMessage = response.message
            }

        } catch {
            isLoading = false
            print("❌ API ERROR:", error.localizedDescription)
            ErrorMessage = error.localizedDescription // show real message instead of generic
        }

        
    }
}
