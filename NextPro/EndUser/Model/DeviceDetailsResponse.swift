//
//  UserDoorAccessResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation

struct DeviceDetailsResponse: Codable {
    let userId: String
    let facilityName: String
    let userFullName: String
    let buildingName: String
    let cardNumber: String
    
    let controllers: [Controller]
    let standaloneDoors: [StandaloneDoor]
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case facilityName = "facility_name"
        case userFullName = "user_full_name"
        case buildingName = "building_name"
        case cardNumber = "card_number"
        case controllers
        case standaloneDoors = "standalone_doors"
    }
}

// MARK: - Controller
struct Controller: Codable {
    let controllerId: String
    let controllerName: String
    let controllerSerialNumber: String
    let controllerMac: String
    let controllerKey: String
    let controllerModel: String
    let devType: Int
    let openType: Int
    let controllerType: String
    let maxDoorsSupported: Int
    
    let doors: [Door]
    
    enum CodingKeys: String, CodingKey {
        case controllerId = "controller_id"
        case controllerName = "controller_name"
        case controllerSerialNumber = "controller_serial_number"
        case controllerMac = "controller_mac"
        case controllerKey = "controller_key"
        case controllerModel = "controller_model"
        case devType = "dev_type"
        case openType = "open_type"
        case controllerType = "controller_type"
        case maxDoorsSupported = "max_doors_supported"
        case doors
    }
}

// MARK: - Door (Controller Based)
struct Door: Codable {
    let doorId: String
    let doorName: String
    let doorNumber: Int
    let doorModel: String
    let doorSerialNumber: String
    let doorMac: String
    let doorKey: String
    let isStandalone: Bool
    
    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorNumber = "door_number"
        case doorModel = "door_model"
        case doorSerialNumber = "door_serial_number"
        case doorMac = "door_mac"
        case doorKey = "door_key"
        case isStandalone = "is_standalone"
    }
}


// MARK: - Standalone Door (Single Level)
struct StandaloneDoor: Codable {
    let doorId: String
    let doorName: String
    let doorModel: String
    let doorSerialNumber: String
    let doorMac: String
    let doorKey: String
    let controllerBased: Bool
    let doorNumber: Int
    let devType: Int
    let openType: Int
    
    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorModel = "door_model"
        case doorSerialNumber = "door_serial_number"
        case doorMac = "door_mac"
        case doorKey = "door_key"
        case controllerBased = "controller_based"
        case doorNumber = "door_number"
        case devType = "dev_type"
        case openType = "open_type"
    }
}
