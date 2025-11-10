//
//  DoorModel.swift
//  NextPro
//
//  Simple hardcoded door list
//

import Foundation
import Combine

struct DoorModel: Identifiable {
    let id: UUID
    let name: String
    let devSn: String
    let devMac: String
    let devType: Int32
    let eKey: String
    let cardno: String
    var isSelected: Bool
    
    init(
        name: String,
        devSn: String,
        devMac: String,
        devType: Int32 = 2,
        eKey: String,
        cardno: String,
        isSelected: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.devSn = devSn
        self.devMac = devMac
        self.devType = devType
        self.eKey = eKey
        self.cardno = cardno
        self.isSelected = isSelected
    }
}

// MARK: - Simple Door List
class DoorStorageManager: ObservableObject {
    static let shared = DoorStorageManager()
    
    @Published var doors: [DoorModel] = []
    
    private init() {
        // Auto-populate from DeviceConfig
        loadDoorsFromDeviceConfig()
    }
    
    // MARK: - Load Doors from DeviceConfig
    private func loadDoorsFromDeviceConfig() {
        let deviceConfigManager = DeviceConfigManager.shared
        let devices = deviceConfigManager.getAllDevices()
        
        print("📋 Loading \(devices.count) doors from DeviceConfig...")
        
        doors = devices.enumerated().map { index, device in
            DoorModel(
                name: device.name,
                devSn: device.devSn,
                devMac: device.devMac,
                devType: 2, // Default device type (1=access reader, 2=integrated, etc.)
                eKey: device.eKey,
                cardno: "1557198962", // Default card number - can be updated per door if needed
                isSelected: index == 0  // First door selected by default
            )
        }
        
        print("✅ Loaded \(doors.count) doors from DeviceConfig")
        for (index, door) in doors.enumerated() {
            print("   Door \(index + 1): \(door.name) (SN: \(door.devSn))")
        }
    }
    
    func selectDoor(_ door: DoorModel) {
        for index in doors.indices {
            doors[index].isSelected = (doors[index].id == door.id)
        }
    }
    
    func getSelectedDoor() -> DoorModel? {
        return doors.first(where: { $0.isSelected })
    }
}

