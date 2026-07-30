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
    @Published private(set) var isRefreshingSilently = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false
    @Published var hasLoadedOnce = false
    @Published var sections: [NotificationSection] = []

    // MARK: - Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    let pageSize = 20

    // MARK: - Network
    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?
    
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
                sections = []
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
                  "| current stored section count:", sections.count)

            do {
                let response = try await networkManager.getNotificationList(
                    page: pageToFetch,
                    pageSize: pageSize
                )

                if response.status ?? true {
                    let newSections = response.data ?? []

                    print("📥 Received notification page:", pageToFetch,
                          "| sections received:", newSections.count)

                    if pageToFetch == 1 {
                        sections = []
                    }
                    appendSections(newSections)

                    let totalCount = response.total ?? totalNotificationCount
                    totalPages = max(1, Int(ceil(Double(totalCount) / Double(pageSize))))
                    currentPage = pageToFetch + 1
                    hasLoadedOnce = true

                    print("✅ Notification list updated",
                          "| total items now:", totalNotificationCount,
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

    /// Re-fetches page 1 from the server and swaps it in once it arrives, without ever clearing
    /// `sections` first — used after a single-item action (e.g. marking one notification read)
    /// so the list stays fully visible with no blank/flicker state while resyncing with the server.
    func refreshSilently() async {
        guard networkManager.hasInternet else { return }
        guard !isRefreshingSilently else { return }
        isRefreshingSilently = true
        defer { isRefreshingSilently = false }

        do {
            let response = try await networkManager.getNotificationList(page: 1, pageSize: pageSize)
            guard !Task.isCancelled else { return }

            if response.status ?? true {
                let newSections = response.data ?? []
                sections = newSections

                let totalCount = response.total ?? newSections.reduce(0) { $0 + ($1.notifications?.count ?? 0) }
                totalPages = max(1, Int(ceil(Double(totalCount) / Double(pageSize))))
                currentPage = 2
                hasLoadedOnce = true
            }
        } catch {
            // Keep the existing list as-is; the optimistic local update already reflects the read.
        }
    }

    /// Merges a freshly-fetched page of date-sections into `sections`, combining sections that
    /// share the same date instead of creating a duplicate header when pagination splits a
    /// date's notifications across two pages.
    private func appendSections(_ newSections: [NotificationSection]) {
        for section in newSections {
            if let index = sections.firstIndex(where: { $0.date == section.date }) {
                let combined = (sections[index].notifications ?? []) + (section.notifications ?? [])
                sections[index] = NotificationSection(date: section.date, notifications: combined)
            } else {
                sections.append(section)
            }
        }
    }

    var isEmpty: Bool {
        sections.allSatisfy { ($0.notifications ?? []).isEmpty }
    }

    var totalNotificationCount: Int {
        sections.reduce(0) { $0 + ($1.notifications?.count ?? 0) }
    }

    /// The id of the very last notification across all sections — used to trigger loading the
    /// next page once the user scrolls to the bottom of the list.
    var lastNotificationId: String? {
        for section in sections.reversed() {
            if let id = section.notifications?.last?.id {
                return id
            }
        }
        return nil
    }

    var hasUnread: Bool {
        sections.contains { section in
            (section.notifications ?? []).contains { !($0.isRead ?? false) }
        }
    }

    func markAllAsRead() {
        sections = sections.map { section in
            NotificationSection(date: section.date, notifications: section.notifications?.map { markRead($0) })
        }
    }

    func markAsRead(id: String?) {
        guard let id else { return }

        for sectionIndex in sections.indices {
            guard var items = sections[sectionIndex].notifications,
                  let itemIndex = items.firstIndex(where: { $0.id == id }) else { continue }

            items[itemIndex] = markRead(items[itemIndex])
            sections[sectionIndex] = NotificationSection(date: sections[sectionIndex].date, notifications: items)
            return
        }
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
