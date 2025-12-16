//
//  DeviceDetailsViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine
import SwiftUI

//@MainActor
//class DeviceDetailsViewModel: ObservableObject {
//    
//    @Published var isLoading = false
//    @Published var deviceDetails: DeviceDetailsResponse?
//    @Published var errorMessage = ""
//
//    private let network = NetworkManager.shared
//
//    func fetchDeviceDetails() async {
//        errorMessage = ""
//        isLoading = true
//
//        guard let token = KeychainManager.shared.get("access_token") else {
//            errorMessage = "Missing access token."
//            isLoading = false
//            return
//        }
//
//        do {
//            let response = try await network.deviceDetails(accessToken: token)
//            print("✅ Device Details Success")
//            self.deviceDetails = response
//            
//            //save to userdefaults
//            saveDetailsLocally(response)
//
//        } catch {
//            print("❌ Device Details Error:", error.localizedDescription)
//            self.errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//    
//    // MARK: - Save To UserDefaults
//        private func saveDetailsLocally(_ response: DeviceDetailsResponse) {
//            if let encoded = try? JSONEncoder().encode(response) {
//                UserDefaults.standard.set(encoded, forKey: "device_details")
//            }
//        }
//    
//    func loadSavedDetails() {
//            if let data = UserDefaults.standard.data(forKey: "device_details"),
//               let decoded = try? JSONDecoder().decode(DeviceDetailsResponse.self, from: data) {
//                self.deviceDetails = decoded
//                print("📦 Loaded Saved Device Details")
//            }
//        }
//    
//}



@MainActor
class DeviceDetailsViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var deviceDetails: DeviceDetailsResponse?
    private let mqttManager = MQTTManager.shared
    @Published var errorMessage = ""
    @Published var allControllerSerials: [String] = []
    private let network = NetworkManager.shared
    
    func fetchDeviceDetailsIfNeeded() async {
        errorMessage = ""
        
        // 1️⃣ Check for saved local data first
        if loadSavedDetails() {
            print("📦 Loaded from local storage. No API call needed.")
            return
        }
        
        // 2️⃣ Only call API / load dummy JSON if no local data
        isLoading = true
        
        // Uncomment this if real API available
        /*
        guard let token = KeychainManager.shared.get("access_token") else {
            errorMessage = "Missing access token."
            isLoading = false
            return
        }

        do {
            let response = try await network.deviceDetails(accessToken: token)
            self.deviceDetails = response
            saveDetailsLocally(response)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        */
        
        // Dummy JSON (for now)
        let dummyJSON = """
        {
          "backend_user_id": "d6b5e158-f48c-40bf-bbc0-4de054069fbc",
          "device_user_id": 1234,
          "organization_name": "Iron Core Fitness Group",
          "user_full_name": "Jyotirmoy Patra",
          "card_number": "2988462596",
          "card_expiry_date": "2027-06-12",
          "facilities": [
            {
              "facility_id": "iron-1234567890",
              "facility_name": "Iron Hive Gym",
              "controllers": [
                {
                  "controller_id": "e58973dc-18d0-4302-a12f-e8f3f8766c19",
                  "controller_name": "Main Gym Controller",
                  "controller_serial": "4282184653",
                  "controller_mac": "a0:76:4e:5a:ae:a2F",
                  "controller_key": "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
                  "controller_model": "BC220",
                  "controller_comm_type": "BLE+WIFI",
                  "max_doors_supported": 1,
                  "doors": [
                    {
                      "door_id": "door-1-id",
                      "door_name": "Gym Mian Entrance",
                      "door_number": 1,
                      "door_model": "M230",
                      "door_serial": "4287123590",
                      "door_mac": "58:cf:79:1a:c4:86",
                      "door_key": "d8829cf1e861620e2d42b2f4af4fd4db000000000000000000000000000000001000",
                      "dev_type": 14,
                      "open_type": 2,
                      "door_comm_type": "BLE",
                      "is_standalone": false
                    }
                  ]
                }
              ],
              "standalone_doors": [
                {
                  "door_id": "solo-door-1",
                  "door_name": "Locker Room Door",
                  "door_number": 2,
                  "door_model": "M230",
                  "door_serial": "4282705968",
                  "door_mac": "58:cf:79:1a:89:ce",
                  "door_key": "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000",
                  "controller_comm_type": "BLE+WIFI",
                  "controller_based": false,
                  "dev_type": 14,
                  "open_type": 2
                }
              ]
            }
          ]
        }
        """
        
        do {
            let data = Data(dummyJSON.utf8)
            let decodedResponse = try JSONDecoder().decode(DeviceDetailsResponse.self, from: data)
            self.deviceDetails = decodedResponse
            saveDetailsLocally(decodedResponse)
            updateControllerSerials()
           // subscribeAllControllers()
            subscribeAllDevices()

            print("✅ Dummy Device Details Loaded")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Dummy Decode Error:", error)
        }
        
        isLoading = false
    }
    
    // MARK: - Save To UserDefaults
    private func saveDetailsLocally(_ response: DeviceDetailsResponse) {
        if let encoded = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(encoded, forKey: "device_details")
        }
    }
    
    // MARK: - Load Saved Details
    @discardableResult
    func loadSavedDetails() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "device_details"),
           let decoded = try? JSONDecoder().decode(DeviceDetailsResponse.self, from: data) {
            self.deviceDetails = decoded
            
            // ✅ Update controller serials immediately
            updateControllerSerials()
            
            // ✅ Subscribe automatically
          //  subscribeAllControllers()
            subscribeAllDevices()

            
            return true
        }
        
        // Clear serials if no local data
        allControllerSerials = []
        
        return false
    }

  
    
    private func updateControllerSerials() {
            guard let details = deviceDetails else {
                allControllerSerials = []
                return
            }
            allControllerSerials = details.facilities.flatMap { $0.controllers.map { $0.controllerSerial } }
    }
        
        // MARK: - Subscribe to all controllers
    private func subscribeAllControllers() {
        guard let details = deviceDetails else { return }
        
        for facility in details.facilities {
            for controller in facility.controllers {
                mqttManager.subscribeToDevice(controller.controllerSerial, model: controller.controllerModel)
                print("Subscribed to Controller:", controller.controllerSerial, "Model:", controller.controllerModel)
            }
        }
    }

    
    // MARK: - Subscribe to all devices (Controllers + Standalone Doors)
    private func subscribeAllDevices() {
        guard let details = deviceDetails else { return }

        for facility in details.facilities {

            // 🔹 1️⃣ Subscribe Controllers
            for controller in facility.controllers {
                mqttManager.subscribeToDevice(
                    controller.controllerSerial,
                    model: controller.controllerModel
                )
                
                print("📡 Subscribed Controller:",
                      controller.controllerSerial,
                      "Model:",
                      controller.controllerModel)
            }

            // 🔹 2️⃣ Subscribe Standalone Doors (if available)
            if let standaloneDoors = facility.standaloneDoors {
                for door in standaloneDoors {
                    mqttManager.subscribeToDevice(
                        door.doorSerial,
                        model: door.doorModel
                    )
                    
                    print("🚪 Subscribed Standalone Door:",
                          door.doorSerial,
                          "Model:",
                          door.doorModel)
                }
            }
        }
    }

    
}
