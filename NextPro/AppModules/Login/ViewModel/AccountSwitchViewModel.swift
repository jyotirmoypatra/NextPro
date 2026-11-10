//
//  AccountSwitchViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 10/11/26.
//

import Foundation
import Combine

@MainActor
class AccountSwitchViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var successFlag = false
    @Published var requiresLogin = false

    @Published var switchResponse: LoginResponseModel?

    private let networkManager = NetworkManager.shared

    func accountSwitch(refreshToken: String) async {

        errorMessage = ""
        successFlag = false
        requiresLogin = false
        switchResponse = nil

        guard !refreshToken.isEmpty else {
            errorMessage = "Refresh token is missing."
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await networkManager.switchAccount(
                refreshToken: refreshToken
            )

            guard response.status else {
                errorMessage = response.message ?? "Unable to switch account."
                return
            }

            switchResponse = response
            successFlag = true

        } catch {
            print("Account switch API error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            if let apiError = error as? NetworkManager.APIError,
               case .serverError(code: 401, message: _) = apiError {
                requiresLogin = true
            }
        }
    }
}
