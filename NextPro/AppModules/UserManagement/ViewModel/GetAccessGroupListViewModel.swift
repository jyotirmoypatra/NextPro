//
//  GetAccessGroupListViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine


@MainActor
class GetAccessGroupListViewModel: ObservableObject {

    @Published var accessGroupList: [AccessGroupItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false
    private let networkManager = NetworkManager.shared
    
    func getAccessGroupList() async {


        guard networkManager.hasInternet else {
           errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }
        
        isFailedDueToNoInternet = false
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.getAccessGroupList()
            if response.status {
                accessGroupList = response.data
            }else{
                errorMessage =  "Something Went Wrong!"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
