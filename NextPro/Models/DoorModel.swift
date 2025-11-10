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
        devType: Int32 = 1,
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
    
    @Published var doors: [DoorModel] = [
        // Add your doors here - update with real values
        DoorModel(
            name: "Main Door",
            devSn: "4283847520",
            devMac: "d8:3b:da:36:53:62",
            eKey: "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000",
            cardno: "1557198962",
            isSelected: true  // First door selected by default
        ),
        DoorModel(
            name: "DOOR 2",
            devSn: "4282894706",
            devMac: "58:cf:79:1d:f7:e6",
            eKey: "97b4c368894a17be950800a8022b7a21000000000000000000000000000000001000",
            cardno: "1557198963",
            isSelected: false
        ),
      
    ]
    
    private init() {}
    
    func selectDoor(_ door: DoorModel) {
        for index in doors.indices {
            doors[index].isSelected = (doors[index].id == door.id)
        }
    }
    
    func getSelectedDoor() -> DoorModel? {
        return doors.first(where: { $0.isSelected })
    }
}

