//
//  DoorModel.swift
//  NextPro
//
//  Simple hardcoded door list
////
//
//import Foundation
//import Combine
//
//struct DoorModel: Identifiable {
//    let id: UUID
//    let name: String
//    let devSn: String
//    let devMac: String
//    let devType: Int32
//    let eKey: String
//    let cardno: String
//    var isSelected: Bool
//    
//    init(
//        name: String,
//        devSn: String,
//        devMac: String,
//        devType: Int32 = 2,
//        eKey: String,
//        cardno: String,
//        isSelected: Bool = false
//    ) {
//        self.id = UUID()
//        self.name = name
//        self.devSn = devSn
//        self.devMac = devMac
//        self.devType = devType
//        self.eKey = eKey
//        self.cardno = cardno
//        self.isSelected = isSelected
//    }
//}
//
//// MARK: - Simple Door List
//class DoorStorageManager: ObservableObject {
//    static let shared = DoorStorageManager()
//    
//    @Published var doors: [DoorModel] = []
//    
//    private init() {
//        // Auto-populate from DeviceConfig
//        loadDoorsFromDeviceConfig()
//    }
//    
//    // MARK: - Load Doors from DeviceConfig
//    private func loadDoorsFromDeviceConfig() {
//        let deviceConfigManager = DeviceConfigManager.shared
//        let devices = deviceConfigManager.getAllDevices()
//        
//        print("📋 Loading \(devices.count) doors from DeviceConfig...")
//        
//        doors = devices.enumerated().map { index, device in
//            DoorModel(
//                name: device.name,
//                devSn: device.devSn,
//                devMac: device.devMac,
//                devType: 2, // Default device type (1=access reader, 2=integrated, etc.)
//                eKey: device.eKey,
//                cardno: "1557198962", // Default card number - can be updated per door if needed
//                isSelected: index == 0  // First door selected by default
//            )
//        }
//        
//        print("✅ Loaded \(doors.count) doors from DeviceConfig")
//        for (index, door) in doors.enumerated() {
//            print("   Door \(index + 1): \(door.name) (SN: \(door.devSn))")
//        }
//    }
//    
//    func selectDoor(_ door: DoorModel) {
//        for index in doors.indices {
//            doors[index].isSelected = (doors[index].id == door.id)
//        }
//    }
//    
//    func getSelectedDoor() -> DoorModel? {
//        return doors.first(where: { $0.isSelected })
//    }
//}
//


//
//  DoorModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/11/25.
//

import Foundation
import Combine

// MARK: - Door Model (Unified)
struct DoorModelUser: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: String
    let devSn: String
    let devMac: String
    let devType: Int32
    let doorID: Int32
    let eKey: String
    let cardno: String
    
    init(
        id: UUID = UUID(),
        name: String,
        duration: String = "For 5 Second",
        devSn: String,
        devMac: String,
        devType: Int32 = 14,
        doorID: Int32 ,
        eKey: String,
        cardno: String
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.devSn = devSn
        self.devMac = devMac
        self.devType = devType
        self.doorID = doorID
        self.eKey = eKey
        self.cardno = cardno
    }
}

// MARK: - Door Storage Manager
@MainActor
class DoorStorageManager: ObservableObject {
    static let shared = DoorStorageManager()
    
    @Published var doors: [DoorModelUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private init() { }
    
    // MARK: - Load Doors (Simulated API)
    func loadDoors() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 🚀 Replace this with your real API call
            // Example:
            // let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.yourapp.com/doors")!)
            // let fetchedDoors = try JSONDecoder().decode([DoorModelUser].self, from: data)
            
            // Temporary static fallback (mock)
            let fetchedDoors: [DoorModelUser] = [
                DoorModelUser(
                    name: "Iron Hive Gym: Gate",
                    devSn: "4280125893",
                    devMac: "58:cf:79:1a:8d:0e",
                    doorID: 2,
                    eKey: "3ca884ca4f8d16e28199c11df14cfbcf000000000000000000000000000000001000",
                    cardno: "1557049426"
                ),
                DoorModelUser(
                    name: "M230(Access control reader)",
                    devSn: "4282894706",
                    devMac: "58:cf:79:1d:f7:e6",
                    doorID: 1,
                    eKey: "97b4c368894a17be950800a8022b7a21000000000000000000000000000000001000",
                    cardno: "1557049426"
                ),
                DoorModelUser(
                    name: "Iron Hive Gym: Door 3",
                    devSn: "4287123590",
                    devMac: "58:cf:79:1a:c4:86",
                    doorID: 3,
                    eKey: "d8829cf1e861620e2d42b2f4af4fd4db000000000000000000000000000000001000",
                    cardno: "2988462596"
                )
            ]
            
            self.doors = fetchedDoors
            print("✅ Loaded \(fetchedDoors.count) doors from API/Mock.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Failed to load doors: \(error)")
        }
    }
    
    func getDoor(bySN sn: String) -> DoorModelUser? {
        doors.first(where: { $0.devSn == sn })
    }
}
