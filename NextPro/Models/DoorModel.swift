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
    
    @Published var doors: [DoorModel] = [
        // Add your doors here - update with real values
        DoorModel(
            name: "Main Door",
            devSn: "4280125893",
            devMac: "58:cf:79:1a:8d:0e",
            eKey: "3ca884ca4f8d16e28199c11df14cfbcf000000000000000000000000000000001000",
            cardno: "1557198962",
            isSelected: true  // First door selected by default
        ),
        DoorModel(
            name: "DOOR 2",
            devSn: "4282184653",
            devMac: "a0:76:4e:5a:ae:a2",
            eKey: "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
            cardno: "1557198962",
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

