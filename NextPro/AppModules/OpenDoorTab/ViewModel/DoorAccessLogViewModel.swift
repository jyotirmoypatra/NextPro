//
//  DoorAccessLogViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/08/26.
//

import Foundation
import Combine


@MainActor
class DoorAccessLogViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var success: Bool = false
    private let networkManager = NetworkManager.shared

    func setWifiLog(accessMode:String,controllerSerial: String,relayDoorNo:Int,userId:Int,cardNo:String,time:String,eventCode:Int) async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await networkManager.accessLog(accessMode: accessMode, controllerSerial: controllerSerial, relayDoorNo: relayDoorNo, userId: userId, cardNo: cardNo,time: time, eventCode: eventCode)
            if response.status {
                // API success
                success = true
                
            } else {
                // API returned status: false
                success = false
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
