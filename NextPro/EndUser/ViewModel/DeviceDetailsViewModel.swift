//
//  DeviceDetailsViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine


@MainActor
class DeviceDetailsViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var issuccess = false
    @Published var deviceDetails: DeviceDetailsResponse?
    private let mqttManager = MQTTManager.shared
    @Published var errorMessage = ""
    @Published var allControllerSerials: [String] = []
    @Published var standaloneControllerList: [RemoteDoorItem] = []
    private let network = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?

//    func fetchDeviceDetailsIfNeeded(force: Bool = false) async {
//        // 🔴 Cancel previous fetch if any
//        fetchTask?.cancel()
//
//        fetchTask = Task { @MainActor in
//            errorMessage = ""
//
//            if !force, loadSavedDetails() {
//                print("📦 Loaded from cache")
//                return
//            }
//
//            isLoading = true
//            defer { isLoading = false }
//
//            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
//                errorMessage = "User ID missing!"
//                return
//            }
//
//            do {
//                let response = try await network.deviceDetails(userID: userId)
//                self.deviceDetails = response
//                saveDetailsLocally(response)
//                updateAndSubscribeAllDevices()
//            } catch {
//                self.errorMessage = error.localizedDescription
//            }
//        }
//
//        await fetchTask?.value
//    }
    
    func fetchDeviceDetailsIfNeeded() async {
        errorMessage = ""
        
        // 1️⃣ Check for saved local data first
        if loadSavedDetails() {
            print("📦 Loaded from local storage. No API call needed.")
            return
        }
        
        // 2️⃣ Only call API / load dummy JSON if no local data
        isLoading = true
        
        
        // Dummy JSON (for now)
        let dummyJSON = """
        {
          "status": true,
          "user_id": "d6b5e158-f48c-40bf-bbc0-4de054069fbc",
          "device_user_id": 7001,
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
                  "door_name": "Office Entrance",
                  "door_number": 1,
                  "door_model": "M230",
                  "door_serial": "4287123590",
                  "door_mac": "58:cf:79:1a:c4:86",
                  "door_key": "d8829cf1e861620e2d42b2f4af4fd4db000000000000000000000000000000001000",
                  "dev_type": 14,
                  "open_type": 2,
                  "door_comm_type": null,
                  "is_standalone": false
                }
              ]
            },
            {
              "controller_id": "hf7f7d6-c8b7-4002-a593-1d2f3c137320",
              "controller_name": "GAte Controller",
              "controller_serial": "4283847520",
              "controller_mac": "d8:3b:da:36:53:62",
              "controller_key": "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000",
              "controller_model": "TC434",
              "controller_comm_type": null,
              "max_doors_supported": 4,
              "doors": [
                {
                  "door_id": "rd497dc-18d0-dhd8-a12f-e8f3f8766c19",
                  "door_name": "Conferance Hall",
                  "door_number": 2,
                  "door_model": "M230",
                  "door_serial": "4282894706",
                  "door_mac": "58:cf:79:1d:f7:e6",
                  "door_key": "97b4c368894a17be950800a8022b7a21000000000000000000000000000000001000",
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
              "door_id": "82l4b0ec8-32ad-4d49-824b-5a67ef87b7f0",
              "door_name": "Store room all In One",
              "door_number": 1,
              "door_model": "M230",
              "door_serial": "4282705968",
              "door_mac": "58:cf:79:1a:89:ce",
              "door_key": "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000",
              "controller_comm_type": null,
              "controller_based": false,
              "dev_type": 14,
              "open_type": 2
            }
          ],
          "standalone_controller": [
            {
              "controller_id": "66dbd6-c4b7-4002-a593-1d2f3c137320",
              "controller_name": "Lockheed Martin : Main Gate",
              "controller_serial": "4282184653",
              "controller_mac": "a0:76:4e:5a:ae:a2",
              "controller_key": "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
              "controller_model": "BC220",
              "controller_comm_type": null,
              "controller_type": "Controller",
              "max_doors_supported": 1,
              "doors": [
                {
                  "door_id": "94435688-a677-4202-866a-d75ccca52d9d",
                  "door_name": "Sensorless Store Room",
                  "door_number": 1
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
            issuccess = true
            print("✅ Dummy Device Details Loaded")
        } catch {
            issuccess = false
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
            issuccess = true
            
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
        standaloneControllerList = remoteDoorList()


        print("✅ Total Subscribed Devices:", allControllerSerials.count)
        print("✅ All door:", bleDoors)
        print("✅ All standalond controller :", standaloneControllerList)
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

    
    
    func remoteDoorList() -> [RemoteDoorItem] {
        guard let details = deviceDetails else { return [] }

        var result: [RemoteDoorItem] = []

        // 🔹 1️⃣ Controllers → Doors
        details.controllers?.forEach { controller in
            guard let controllerSerial = controller.controllerSerial else { return }

            controller.doors?.forEach { door in
                let sensorDetails = DoorModelUser(
                            name: door.doorName ?? "",
                            devSn: door.doorSerial ?? "",
                            devMac: door.doorMac ?? "",
                            devType:Int32(door.devType ?? 14),
                            doorID: Int32(door.doorNumber ?? 1),
                            eKey: door.doorKey ?? "",
                            cardno: deviceDetails?.digitalCardNumber ?? ""
                        )
                
                result.append(
                    RemoteDoorItem(
                        doorName: door.doorName ?? "",
                        doorNumber: door.doorNumber ?? 1,
                        serial: controllerSerial,
                        doorType: "standard",
                        doorControllerType: controller.controllerModel,
                        sensorDetails: sensorDetails,
                        
                    )
                )
            }
        }

        // 🔹 2️⃣ Standalone All-in-One Doors
        details.standaloneAllInOne?.forEach { door in
            guard let doorSerial = door.doorSerial else { return }

            let sensorDetails = DoorModelUser(
                        name: door.doorName ?? "",
                        devSn: door.doorSerial ?? "",
                        devMac: door.doorMac ?? "",
                        devType:Int32(door.devType ?? 14),
                        doorID: Int32(door.doorNumber ?? 1),
                        eKey: door.doorKey ?? "",
                        cardno: deviceDetails?.digitalCardNumber ?? ""
                    )
            
            result.append(
                RemoteDoorItem(
                    doorName: door.doorName ?? "",
                    doorNumber: door.doorNumber ?? 1,
                    serial: doorSerial,
                    doorType: "all_in_one",
                    doorControllerType: door.doorModel,
                    sensorDetails: sensorDetails,
                )
            )
        }

        // 🔹 3️⃣ Standalone Controller → Doors
        details.standaloneController?.forEach { controller in
            guard let controllerSerial = controller.controllerSerial else { return }

            controller.doors?.forEach { door in
                
                let sensorDetails = DoorModelUser(
                            name: door.doorName ?? "",
                            devSn: controller.controllerSerial ?? "",
                            devMac: controller.controllerMac ?? "",
                            devType:Int32(14),
                            doorID: Int32(door.doorNumber ?? 1),
                            eKey: controller.controllerKey ?? "",
                            cardno: deviceDetails?.digitalCardNumber ?? ""
                        )
                
                result.append(
                    RemoteDoorItem(
                        doorName: door.doorName ?? "",
                        doorNumber: door.doorNumber ?? 1,
                        serial: controllerSerial,
                        doorType: "standalone_controller",
                        doorControllerType: controller.controllerModel,
                        sensorDetails: sensorDetails
                    )
                )
            }
        }

        return result
    }

    
    
    @MainActor
    func refreshDeviceDetails() async {
        errorMessage = ""
        isLoading = true

        // 🔄 Clear local cache
        UserDefaults.standard.removeObject(forKey: "device_details")
        deviceDetails = nil
        allControllerSerials = []

        // 🔁 Reload fresh data (dummy / API)
        await fetchDeviceDetailsIfNeeded()
    }

//    @MainActor
//    func refreshDeviceDetails() async {
//        // 🔄 Clear cache
//        UserDefaults.standard.removeObject(forKey: "device_details")
//        deviceDetails = nil
//        allControllerSerials = []
//
//        // 🔁 Force reload
//        await fetchDeviceDetailsIfNeeded(force: true)
//    }

    
    
    func getDoorName(sn: String?, doorId: Int?) -> String? {
        guard
            let details = deviceDetails,
            let sn = sn,
            let doorId = doorId
        else { return nil }

        // 1️⃣ Normal Controllers
        if let controller = details.controllers?
            .first(where: { $0.controllerSerial == sn }) {

            if let door = controller.doors?
                .first(where: { $0.doorNumber == doorId }) {
                return door.doorName
            }
        }

        // 2️⃣ Standalone All-in-One
        if let door = details.standaloneAllInOne?
            .first(where: {
                $0.doorSerial == sn && $0.doorNumber == doorId
            }) {
            return door.doorName
        }

        // 3️⃣ Standalone Controller
        if let controller = details.standaloneController?
            .first(where: { $0.controllerSerial == sn }) {

            if let door = controller.doors?
                .first(where: { $0.doorNumber == doorId }) {
                return door.doorName
            }
        }

        return nil
    }

    
}
