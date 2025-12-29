
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

    private init() {}

    // ✅ Just update doors
    func updateDoors(_ newDoors: [DoorModelUser]) {
        doors.removeAll()
        self.doors = newDoors
        print("🚪 DoorStorage updated with \(newDoors.count) doors")
    }

    func clearDoors() {
        doors.removeAll()
    }

    func getDoor(bySN sn: String) -> DoorModelUser? {
        doors.first(where: { $0.devSn == sn })
    }
}
