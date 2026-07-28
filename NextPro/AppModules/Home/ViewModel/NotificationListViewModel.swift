//
//  NotificationListViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation
import Combine

@MainActor
final class NotificationListViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false
    @Published var hasLoadedOnce = false

    @Published var notifications: [NotificationItem] = []

    // MARK: - Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    let pageSize = 10

    // MARK: - Network
    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?

    // MARK: - MAIN FETCH
    /// Fetches notification list with server-side pagination.
    /// - Parameter reset: If true, clears list, resets to page 1, and fetches first page (used for initial load and pull-to-refresh).
    func fetchNotificationList(reset: Bool = false) async {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            guard networkManager.hasInternet else {
                errorMessage = nil
                isFailedDueToNoInternet = true
                return
            }
            isFailedDueToNoInternet = false

            if reset {
                notifications = []
                currentPage = 1
                totalPages = 1
                print("🔄 Notification pagination reset → loading from page 1")
            }

            // Do not fetch beyond last page
            guard currentPage <= totalPages else {
                print("⛔ No more notification pages to load. currentPage:", currentPage, "totalPages:", totalPages)
                return
            }

            // Prevent duplicate calls for same or next page
            if isLoading || isLoadingMore { return }

            let pageToFetch = currentPage
            if pageToFetch == 1 {
                isLoading = true
            } else {
                isLoadingMore = true
            }

            defer {
                isLoading = false
                isLoadingMore = false
            }

            print("📤 Requesting notification page:", pageToFetch,
                  "| current stored count:", notifications.count)

            do {
                let response = try await networkManager.getNotificationList(
                    page: pageToFetch,
                    pageSize: pageSize
                )

                if response.status ?? true {
                    let items = (response.data ?? []).flatMap { $0.notifications ?? [] }

                    print("📥 Received notification page:", pageToFetch,
                          "| items received:", items.count)

                    if pageToFetch == 1 {
                        notifications = items
                    } else {
                        notifications.append(contentsOf: items)
                    }

                    let totalCount = response.total ?? notifications.count
                    totalPages = max(1, Int(ceil(Double(totalCount) / Double(pageSize))))
                    currentPage = pageToFetch + 1
                    hasLoadedOnce = true

                    print("✅ Notification list updated",
                          "| total items now:", notifications.count,
                          "| next page will be:", currentPage)
                } else {
                    errorMessage = response.message ?? "Something went wrong!"
                    hasLoadedOnce = true
                }
            } catch is CancellationError {
                return
            } catch let error as NSError where error.code == NSURLErrorCancelled {
                return
            } catch {
                errorMessage = error.localizedDescription
                hasLoadedOnce = true
            }
        }

        await fetchTask?.value
    }

    var hasUnread: Bool {
        notifications.contains(where: { !($0.isRead ?? false) })
    }

    func markAllAsRead() {
        notifications = notifications.map { markRead($0) }
    }

    func markAsRead(id: String?) {
        guard let id, let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index] = markRead(notifications[index])
    }

    private func markRead(_ item: NotificationItem) -> NotificationItem {
        NotificationItem(
            id: item.id,
            type: item.type,
            entityType: item.entityType,
            entityID: item.entityID,
            label: item.label,
            tag: item.tag,
            additionalInfo: item.additionalInfo,
            title: item.title,
            description: item.description,
            isRead: true,
            readAt: item.readAt,
            fromUser: item.fromUser,
            createdAt: item.createdAt,
            timeElapsed: item.timeElapsed
        )
    }
}
