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
    
   @Published var time_slots : [TimeSlot]?
    @Published var startDate: String?
    @Published var weekday: String?
    @Published var endDate : String?

    func fetchDeviceDetailsIfNeeded(force: Bool = false) async {
        // 🔴 Cancel previous fetch if any
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            errorMessage = ""

            if !force, loadSavedDetails() {
                print("📦 Loaded from cache")
                return
            }

            isLoading = true
            defer { isLoading = false }

            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
                errorMessage = "User ID missing!"
                return
            }

            do {
                let response = try await network.deviceDetails(userID: userId)
                self.deviceDetails = response
                startDate = response.accessGroups?.first?.startDate
                endDate = response.accessGroups?.first?.endDate
                time_slots = response.accessGroups?.first?.timeSlots
                weekday = response.accessGroups?.first?.weekDays
                
                issuccess=true
                saveDetailsLocally(response)
                updateAndSubscribeAllDevices()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }

        await fetchTask?.value
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
            startDate = self.deviceDetails?.accessGroups?.first?.startDate
            endDate = self.deviceDetails?.accessGroups?.first?.endDate
            time_slots = self.deviceDetails?.accessGroups?.first?.timeSlots
            weekday = self.deviceDetails?.accessGroups?.first?.weekDays
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

    
    
//    @MainActor
//    func refreshDeviceDetails() async {
//        errorMessage = ""
//        isLoading = true
//
//        // 🔄 Clear local cache
//        UserDefaults.standard.removeObject(forKey: "device_details")
//        deviceDetails = nil
//        allControllerSerials = []
//
//        // 🔁 Reload fresh data (dummy / API)
//        await fetchDeviceDetailsIfNeeded()
//    }

  //  for actual api call ->
    @MainActor
    func refreshDeviceDetails() async {
        // 🔄 Clear cache
        UserDefaults.standard.removeObject(forKey: "device_details")
        deviceDetails = nil
        allControllerSerials = []
        standaloneControllerList = []
        // 🔁 Force reload
        await fetchDeviceDetailsIfNeeded(force: true)
    }

    
    
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
