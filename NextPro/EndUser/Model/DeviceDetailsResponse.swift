//
//  UserDoorAccessResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation

struct DeviceDetailsResponse: Codable {
    let backendUserId: String
    let deviceUserId: Int
    let organizationName: String
    let userFullName: String
    let cardNumber: String
    let cardExpiryDate: String
    let facilities: [Facility]

    enum CodingKeys: String, CodingKey {
        case backendUserId = "backend_user_id"
        case deviceUserId = "device_user_id"
        case organizationName = "organization_name"
        case userFullName = "user_full_name"
        case cardNumber = "card_number"
        case cardExpiryDate = "card_expiry_date"
        case facilities
    }
}


struct Facility: Codable {
    let facilityId: String
    let facilityName: String
    let controllers: [Controller]
    let standaloneDoors: [StandaloneDoor]?

    enum CodingKeys: String, CodingKey {
        case facilityId = "facility_id"
        case facilityName = "facility_name"
        case controllers
        case standaloneDoors = "standalone_doors"
    }
}


struct Controller: Codable {
    let controllerId: String
    let controllerName: String
    let controllerSerial: String
    let controllerMac: String
    let controllerKey: String
    let controllerModel: String
    let controllerCommType: String
    let controllerType: Int?
    let maxDoorsSupported: Int
    let doors: [Door]

    enum CodingKeys: String, CodingKey {
        case controllerId = "controller_id"
        case controllerName = "controller_name"
        case controllerSerial = "controller_serial"
        case controllerMac = "controller_mac"
        case controllerKey = "controller_key"
        case controllerModel = "controller_model"
        case controllerCommType = "controller_comm_type"
        case controllerType = "controller_type"
        case maxDoorsSupported = "max_doors_supported"
        case doors
    }
}


struct Door: Codable {
    let doorId: String
    let doorName: String
    let doorNumber: Int
    let doorModel: String
    let doorSerial: String
    let doorMac: String
    let doorKey: String
    let devType: Int
    let openType: Int
    let doorCommType: String
    let isStandalone: Bool?

    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorNumber = "door_number"
        case doorModel = "door_model"
        case doorSerial = "door_serial"
        case doorMac = "door_mac"
        case doorKey = "door_key"
        case devType = "dev_type"
        case openType = "open_type"
        case doorCommType = "door_comm_type"
        case isStandalone = "is_standalone"
    }
}


struct StandaloneDoor: Codable {
    let doorId: String
    let doorName: String
    let doorNumber: Int
    let doorModel: String
    let doorSerial: String
    let doorMac: String
    let doorKey: String
    let controllerCommType: String
    let controllerBased: Bool
    let devType: Int
    let openType: Int

    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorNumber = "door_number"
        case doorModel = "door_model"
        case doorSerial = "door_serial"
        case doorMac = "door_mac"
        case doorKey = "door_key"
        case controllerCommType = "controller_comm_type"
        case controllerBased = "controller_based"
        case devType = "dev_type"
        case openType = "open_type"
    }
}
