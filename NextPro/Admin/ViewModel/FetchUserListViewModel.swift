//
//  FetchUserListViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine

@MainActor
final class FetchUserListViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var issuccess = false
    @Published var hasLoadedOnce = false
    @Published var isFailedDueToNoInternet = false
    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?
    @Published var usersList: [User] = []
   

    func fetchUsersList() async {
        //  Cancel previous fetch if any
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            
            guard networkManager.hasInternet else {
               errorMessage = nil
                isFailedDueToNoInternet = true
                return
            }
            
            
            isFailedDueToNoInternet = false
            errorMessage = nil
            isLoading = true
            
            defer { isLoading = false }

            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
                errorMessage = "User ID missing!"
                return
            }

            do {
                let response = try await networkManager.fetchUserList(userId: userId)

                if response.status {
                    issuccess = true
                    usersList = response.data
                   
                } else {
                    errorMessage = "Something West Wrong!"
                }

            } catch is CancellationError {
               // Ignore Swift concurrency cancellation
               return

           } catch let error as NSError where error.code == NSURLErrorCancelled {
               // Ignore URLSession (-999) cancellation
               return

           } catch {
               errorMessage = error.localizedDescription
           }
        }

        await fetchTask?.value
    }

    
}
