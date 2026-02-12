////
////  FetchUserListViewModel.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 07/01/26.
////
//
//import Foundation
//import Combine
//

import Foundation
import Combine

@MainActor
final class FetchUserListViewModel: ObservableObject {


    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var issuccess = false
    @Published var isFailedDueToNoInternet = false
    @Published var hasLoadedOnce = false


    @Published var usersList: [User] = []

    // MARK: - Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    let pageSize = 7


    @Published var searchText: String = ""
    private var lastSearchQuery = ""

    // MARK: - Network
    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .dropFirst() //
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
//            .sink { [weak self] _ in
//                Task {
//                    await self?.fetchUsersList(reset: true)
//                }
//            }
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                
                // Prevent API call if value didn't actually change
                guard trimmed != self.lastSearchQuery else { return }
                
                self.lastSearchQuery = trimmed
                
                Task {
                    await self.fetchUsersList(reset: true)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - MAIN FETCH
    /// Fetches user list with server-side pagination.
    /// - Parameter reset: If true, clears list, resets to page 1, and fetches first page (used for initial load, search, pull-to-refresh, return from AddUserView).
    func fetchUsersList(reset: Bool = false) async {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            guard networkManager.hasInternet else {
                errorMessage = nil
                isFailedDueToNoInternet = true
                return
            }
            isFailedDueToNoInternet = false

            if reset {
                usersList = []
                currentPage = 1
                totalPages = 1
                print("🔄 Pagination reset → loading from page 1")
            }

            // Do not fetch beyond last page
           
            guard currentPage <= totalPages else {
                print("⛔ No more pages to load. currentPage:", currentPage, "totalPages:", totalPages)
                return }

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

            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
                errorMessage = "User ID missing!"
                return
            }

            let searchQuery = searchText.trimmingCharacters(in: .whitespaces)
            
            print("📤 Requesting page:", pageToFetch,
                  "| search:", searchQuery,
                  "| current stored count:", usersList.count)

            do {
                let response = try await networkManager.fetchUserList(
                    userId: userId,
                    page: pageToFetch,
                    pageSize: pageSize,
                    search: searchQuery
                )

                if response.status {
                    print("📥 Received page:", pageToFetch,
                          "| items received:", response.data.count,
                          "| total pages:", response.pagination.totalPages)
                    if pageToFetch == 1 {
                        usersList = response.data
                    } else {
                        usersList.append(contentsOf: response.data)
                    }
                    totalPages = response.pagination.totalPages
                    currentPage = pageToFetch + 1
                    issuccess = true
                    hasLoadedOnce = true
                    
                    print("✅ List updated",
                          "| total items now:", usersList.count,
                          "| next page will be:", currentPage)
                } else {
                    errorMessage = "Something went wrong!"
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

    /// Call when returning from AddUserView: reset pagination and reload from page 1, keeping current search.
    func refreshAfterAddOrEditUser() async {
        await fetchUsersList(reset: true)
    }
}
