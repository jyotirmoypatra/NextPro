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
    let pageSize = 10


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
    func fetchUsersList(reset: Bool = false) async {

        fetchTask?.cancel()

        fetchTask = Task { @MainActor in

         
            guard networkManager.hasInternet else {
                errorMessage = nil
                isFailedDueToNoInternet = true
                return
            }

            isFailedDueToNoInternet = false

            

            // Manual reset (pull to refresh)
//            if reset {
//                currentPage = 1
//                totalPages = 1
//                
//                // clear only when first load OR pull refresh
//                if searchText.isEmpty {
//                    usersList = []
//                }
//            }
            
            if reset {
                currentPage = 1
                totalPages = 1
                
                // Clear list ONLY on first load (not when refreshing or coming back)
                if !hasLoadedOnce {
                    usersList = []
                }
            }

            //Stop if no more pages
            guard currentPage <= totalPages else { return }

            // Prevent duplicate calls
            if isLoading || isLoadingMore { return }

            if currentPage == 1 {
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

            do {
                print("Fetch page:", currentPage, "search:", searchText)

                let response = try await networkManager.fetchUserList(
                    userId: userId,
                    page: currentPage,
                    pageSize: pageSize,
                    search: searchText.trimmingCharacters(in: .whitespaces)
                )

                if response.status {

                    if currentPage == 1 {
                        usersList = response.data
                    } else {
                        usersList.append(contentsOf: response.data)
                    }

                    totalPages = response.pagination.totalPages
                    currentPage += 1
                    issuccess = true
                    hasLoadedOnce = true

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
}
