//
//  NotificationCountViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation
import Combine

@MainActor
final class NotificationCountViewModel: ObservableObject {

    @Published var unreadCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?

    private var isAuthenticated: Bool {
        guard UserDefaults.standard.bool(forKey: "is_logged_in") else { return false }
        guard let token = KeychainManager.shared.get("access_token"), !token.isEmpty else { return false }
        return true
    }
    func refreshUnreadCount() {
        guard isAuthenticated else {
            unreadCount = 0
            return
        }

        fetchTask?.cancel()
        fetchTask = Task { @MainActor [weak self] in
            await self?.fetchUnreadCount()
        }
    }

    private func fetchUnreadCount() async {
        guard networkManager.hasInternet else { return }
        guard isAuthenticated else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.getUnreadNotificationCount()

            if response.status ?? true {
                unreadCount = response.data?.unreadCount ?? 0
                errorMessage = nil
            } else {
                errorMessage = response.message ?? "Something went wrong!"
            }
        } catch is CancellationError {
            return
        } catch let error as NSError where error.code == NSURLErrorCancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
