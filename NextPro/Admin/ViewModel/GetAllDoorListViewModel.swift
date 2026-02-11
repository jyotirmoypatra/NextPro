//
//  GetAllDoorListViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine

//@MainActor
//final class GetAllDoorListViewModel: ObservableObject {
//
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var issuccess = false
//    @Published var hasLoadedOnce = false
//    @Published var isFailedDueToNoInternet = false
//    private let networkManager = NetworkManager.shared
//    private var fetchTask: Task<Void, Never>?
//    @Published var doorList: [SingleDoor] = []
//   
//
//    func getDoorList() async {
//        //  Cancel previous fetch if any
//        fetchTask?.cancel()
//
//        fetchTask = Task { @MainActor in
//            
//            guard networkManager.hasInternet else {
//               errorMessage = nil
//                isFailedDueToNoInternet = true
//                return
//            }
//            
//            
//            isFailedDueToNoInternet = false
//            errorMessage = nil
//            isLoading = true
//            
//            defer { isLoading = false }
//
//            do {
//                let response = try await networkManager.getAllDoorList()
//
//                if response.status {
//                    issuccess = true
//                    doorList = response.data
//                   
//                } else {
//                    errorMessage = "Something West Wrong!"
//                }
//
//            } catch is CancellationError {
//               // Ignore Swift concurrency cancellation
//               return
//
//           } catch let error as NSError where error.code == NSURLErrorCancelled {
//               // Ignore URLSession (-999) cancellation
//               return
//
//           } catch {
//               errorMessage = error.localizedDescription
//           }
//        }
//
//        await fetchTask?.value
//    }
//
//    
//}

@MainActor
final class GetAllDoorListViewModel: ObservableObject {

    @Published var doorList: [SingleDoor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoadedOnce = false
    @Published var isFailedDueToNoInternet = false
    private let networkManager = NetworkManager.shared
    
    func getDoorList(force: Bool = false) async {

        if hasLoadedOnce && !force { return }

        guard networkManager.hasInternet else {
           errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.getAllDoorList()
            if response.status {
                doorList = response.data
                hasLoadedOnce = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    // Call ONLY when backend door add/delete happens
    func refreshDoors() async {
        hasLoadedOnce = false
        await getDoorList()
    }
}
