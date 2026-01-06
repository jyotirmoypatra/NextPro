
//
//  DoorStorageManager.swift
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
    let devSn: String
    let devMac: String
    let devType: Int32
    let doorID: Int32
    let eKey: String
    let cardno: String
    
    init(
        id: UUID = UUID(),
        name: String,
        devSn: String,
        devMac: String,
        devType: Int32 = 14,
        doorID: Int32 ,
        eKey: String,
        cardno: String
    ) {
        self.id = id
        self.name = name
        self.devSn = devSn
        self.devMac = devMac
        self.devType = devType
        self.doorID = doorID
        self.eKey = eKey
        self.cardno = cardno
    }
}

struct RemoteDoorItem: Identifiable {
    let id = UUID()
    let doorName: String
    let doorNumber: Int
    let serial: String   // controller_serial OR door_serial
    let doorType: String?
    let doorControllerType: String?
    let sensorDetails: DoorModelUser?
    var key: String {
            "\(serial)_\(doorNumber)"
        }
}


@MainActor
class DoorStorageManager: ObservableObject {
    static let shared = DoorStorageManager()

    @Published var doors: [DoorModelUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var hasDoor: Bool = false
    @Published var hasResolvedDoors: Bool = false
    @Published var doorCount: Int = 0


    private init() {}


    func getDoor(bySN sn: String) -> DoorModelUser? {
        doors.first(where: { $0.devSn == sn })
    }
    
    
    func updateDoors(_ newDoors: [DoorModelUser]) {
        doors.removeAll()
        self.doors = newDoors

        doorCount = newDoors.count
        hasDoor = !newDoors.isEmpty
        hasResolvedDoors = true

        print("🚪 DoorStorage updated with \(doorCount) doors")
        print("🚫 Has Door:", hasDoor)
    }
    
    func clearDoors() {
        doors.removeAll()
        doorCount = 0
        hasDoor = false
        hasResolvedDoors = false
    }


}
