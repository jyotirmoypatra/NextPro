//
//  SingleNotificationReadViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation
import Combine

@MainActor
final class SingleNotificationReadViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isFailedDueToNoInternet = false

    private let networkManager = NetworkManager.shared

    @discardableResult
    func markAsRead(notificationId: String) async -> Bool {
        guard networkManager.hasInternet else {
            errorMessage = nil
            isFailedDueToNoInternet = true
            return false
        }
        isFailedDueToNoInternet = false

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.MarkSingleNotificationRead(notificationId: notificationId)

            if response.status ?? true {
                successMessage = response.message
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
