//
//  LoginViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation
import Combine


@MainActor
class ServerTimeViewModel: ObservableObject {

    @Published var errorMessage: String?
    @Published var successFlag = false
    let networkManager = NetworkManager.shared

    func getTime() async {
        guard networkManager.hasInternet else {
            print("❌ No internet")
            return
        }

        do {
            let response = try await networkManager.serverTime()
            if response.status {
                successFlag = true
                print("🕒 Server Time:", response.datetime ?? "")
            }
        } catch {
            print("❌ Error:", error.localizedDescription)
        }
    }

}
