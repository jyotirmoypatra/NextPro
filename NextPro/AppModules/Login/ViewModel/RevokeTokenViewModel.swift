//
//  RevokeTokenViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 10/11/26.
//

import Foundation
import Combine

@MainActor
final class RevokeTokenViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let networkManager = NetworkManager.shared

    func revoke(refreshToken: String) async -> Bool {
        guard !refreshToken.isEmpty else {
            errorMessage = "Refresh token is missing."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await networkManager.revokeToken(
                refreshToken: refreshToken,
                deviceToken: UserDefaults.standard.string(forKey: "fcm_token")
            )
            guard response.status == true else {
                errorMessage = response.message ?? "Unable to remove this account."
                return false
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
