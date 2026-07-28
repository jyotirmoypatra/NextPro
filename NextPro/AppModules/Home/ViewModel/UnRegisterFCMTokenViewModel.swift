//
//  UnRegisterFCMTokenViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/07/26.
//

import Foundation
import Combine

@MainActor
final class UnRegisterFCMTokenViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkManager = NetworkManager.shared
    
    func unregister(tokenId: Int) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.unRegisterFCMToken(tokenId: tokenId)

            if response.status ?? true {
                errorMessage = nil
                return true
            } else {
                errorMessage = response.message ?? "Something went wrong!"
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
