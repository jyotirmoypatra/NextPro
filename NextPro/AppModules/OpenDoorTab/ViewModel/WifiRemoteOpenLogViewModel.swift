//
//  WifiRemoteOpenLogViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/08/26.
//

import Foundation
import Combine


@MainActor
class WifiRemoteOpenLogViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var success: Bool = false
    private let networkManager = NetworkManager.shared

    func setWifiLog(controllerSerial: String,relayDoorNo:Int,userId:Int,cardNo:String,time:String) async {
        
        guard networkManager.hasInternet else {
            errorMessage = "No internet connection."
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await networkManager.wifiRemoteOpenLog(controllerSerial: controllerSerial, relayDoorNo: relayDoorNo, userId: userId, cardNo: cardNo,time: time)
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
