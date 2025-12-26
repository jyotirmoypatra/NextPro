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
            "status": true,
            "user_id": "d6b5e158-f48c-40bf-bbc0-4de054069fbc",
            "device_user_id": 1766409371469,
            "organization_name": "Lockheed Martin",
            "user_full_name": "Jyotirmoy Patra",
            "physical_card_number": "2988462596",
            "digital_card_number": "2988462596",
            "card_expiry_date": "2026-01-10T21:26",
            "controllers": [
                {
                    "controller_id": "94f5dbd6-c8b7-4002-a593-1d2f3c137320",
                    "controller_name": "Main Gate Controller",
                    "controller_serial": "4282184653",
                    "controller_mac": "a0:76:4e:5a:ae:a2",
                    "controller_key": "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
                    "controller_model": "BC220",
                    "controller_comm_type": null,
                    "max_doors_supported": 1,
                    "doors": [
                        {
                            "door_id": "e58973dc-18d0-4302-a12f-e8f3f8766c19",
                            "door_name": "Gym Entrance 1",
                            "door_number": null,
                            "door_model": "RD-106",
                            "door_serial": "4287123590",
                            "door_mac": "58:cf:79:1a:c4:86",
                            "door_key": "d8829cf1e861620e2d42b2f4af4fd4db000000000000000000000000000000001000",
                            "dev_type": 14,
                            "open_type": 2,
                            "door_comm_type": null,
                            "is_standalone": false
                        }
                    ]
                }
            ],
            "standalone_all_in_one": [
                {
                    "door_id": "838b0ec8-32ad-4d49-824b-5a67ef87b7f0",
                    "door_name": "Door One",
                    "door_number": 1,
                    "door_model": "DC-106",
                    "door_serial": "SN006",
                    "door_mac": "AUTO-37f86e95b277",
                    "door_key": "7878877",
                    "controller_comm_type": null,
                    "controller_based": false,
                    "dev_type": 14,
                    "open_type": 2
                }
            ],
            "standalone_controller": [
                {
                    "controller_id": "94f5dbd6-c8b7-4002-a593-1d2f3c137320",
                    "controller_name": "RD-106",
                    "controller_serial": "SN016",
                    "controller_mac": "AUTO-a1f1d0eca648",
                    "controller_key": "34567",
                    "controller_model": "RD-106",
                    "controller_comm_type": null,
                    "controller_type": "Controller",
                    "max_doors_supported": 1,
                    "doors": [
                        {
                            "door_id": "94435688-a677-4202-866a-d75ccca52d9d",
                            "door_name": "Door 1",
                            "door_number": null
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
            updateAndSubscribeAllDevices()

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
            
            updateAndSubscribeAllDevices()

            
            return true
        }
        
        // Clear serials if no local data
        allControllerSerials = []
        
        return false
    }
    
    
    
    private func updateAndSubscribeAllDevices() {
        guard let details = deviceDetails else { return }

        var subscribedSerials = Set<String>() // prevent duplicates

        // 🔹 1️⃣ Normal Controllers
        details.controllers?.forEach { controller in
            if let serial = controller.controllerSerial,
               !subscribedSerials.contains(serial) {

                subscribedSerials.insert(serial)
                mqttManager.subscribeToDevice(serial, model: controller.controllerModel ?? "")

                print("📡 Subscribed Controller:",
                      serial,
                      "Model:",
                      controller.controllerModel ?? "Unknown")
            }
        }

        // 🔹 2️⃣ Standalone Controllers
        details.standaloneController?.forEach { controller in
            if let serial = controller.controllerSerial,
               !subscribedSerials.contains(serial) {

                subscribedSerials.insert(serial)
                mqttManager.subscribeToDevice(serial, model: controller.controllerModel ?? "")

                print("📡 Subscribed Standalone Controller:",
                      serial,
                      "Model:",
                      controller.controllerModel ?? "Unknown")
            }
        }

        // 🔹 3️⃣ All-in-One Standalone Doors
        details.standaloneAllInOne?.forEach { door in
            if let serial = door.doorSerial,
               !subscribedSerials.contains(serial) {

                subscribedSerials.insert(serial)
                mqttManager.subscribeToDevice(serial, model: door.doorModel ?? "")

                print("🚪 Subscribed All-in-One Door:",
                      serial,
                      "Model:",
                      door.doorModel ?? "Unknown")
            }
        }

        // 🔹 Store for reference/debug (optional)
        allControllerSerials = Array(subscribedSerials)
        
        let bleDoors = buildAllDoorsForBLE()
        DoorStorageManager.shared.updateDoors(bleDoors)


        print("✅ Total Subscribed Devices:", allControllerSerials.count)
        print("✅ All door:", bleDoors)
    }

    
    
    private func buildAllDoorsForBLE() -> [DoorModelUser] {
        guard let details = deviceDetails else { return [] }

        var doors: [DoorModelUser] = []

        let cardNo = details.digitalCardNumber ?? details.physicalCardNumber ?? ""

        // 🔹 1️⃣ Controller → Doors
        details.controllers?.forEach { controller in
            controller.doors?.forEach { door in
                guard
                    let sn = door.doorSerial,
                    let mac = door.doorMac,
                    let key = door.doorKey
                else { return }

                doors.append(
                    DoorModelUser(
                        name: door.doorName ?? "Door",
                        devSn: sn,
                        devMac: mac,
                        devType: Int32(door.devType ?? 14),
                        doorID: Int32(door.doorNumber ?? 1),
                        eKey: key,
                        cardno: cardNo
                    )
                )
            }
        }

        // 🔹 2️⃣ Standalone All-in-One Doors
        details.standaloneAllInOne?.forEach { door in
            guard
                let sn = door.doorSerial,
                let mac = door.doorMac,
                let key = door.doorKey
            else { return }

            doors.append(
                DoorModelUser(
                    name: door.doorName ?? "Standalone Door",
                    devSn: sn,
                    devMac: mac,
                    devType: Int32(door.devType ?? 14),
                    doorID: Int32(door.doorNumber ?? 1),
                    eKey: key,
                    cardno: cardNo
                )
            )
        }


        return doors
    }

    
}
