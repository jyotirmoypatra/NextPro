//
//  UserDoorAccessResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation

struct DeviceDetailsResponse: Codable {
    let status: Bool
    let message: String?
    let userId: String?
    let deviceUserId: Int?
    let organizationName: String?
    let userFullName: String?
    let physicalCardNumber: String?
    let digitalCardNumber: String?
    let cardExpiryDate: String?
    let controllers: [Controller]?
    let standaloneAllInOne: [Standalone_All_In_One_Door]?
    let standaloneController: [StandaloneController]?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case userId = "user_id"
        case deviceUserId = "device_user_id"
        case organizationName = "organization_name"
        case userFullName = "user_full_name"
        case physicalCardNumber = "physical_card_number"
        case digitalCardNumber = "digital_card_number"
        case cardExpiryDate = "card_expiry_date"
        case controllers = "controllers"
        case standaloneAllInOne = "standalone_all_in_one"
        case standaloneController = "standalone_controller"
    }
}


struct Controller: Codable {
    let controllerId: String
    let controllerName: String?
    let controllerSerial: String?
    let controllerMac: String?
    let controllerKey: String?
    let controllerModel: String?
    let controllerCommType: String?
    let maxDoorsSupported: Int?
    let doors: [Door]?

    enum CodingKeys: String, CodingKey {
        case controllerId = "controller_id"
        case controllerName = "controller_name"
        case controllerSerial = "controller_serial"
        case controllerMac = "controller_mac"
        case controllerKey = "controller_key"
        case controllerModel = "controller_model"
        case controllerCommType = "controller_comm_type"
        case maxDoorsSupported = "max_doors_supported"
        case doors
    }
}


struct Door: Codable {
    let doorId: String
    let doorName: String?
    let doorNumber: Int?
    let doorModel: String?
    let doorSerial: String?
    let doorMac: String?
    let doorKey: String?
    let devType: Int?
    let openType: Int?
    let doorCommType: String?
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


struct Standalone_All_In_One_Door: Codable {
    let doorId: String
    let doorName: String?
    let doorNumber: Int?
    let doorModel: String?
    let doorSerial: String?
    let doorMac: String?
    let doorKey: String?
    let controllerCommType: String?
    let controllerBased: Bool?
    let devType: Int?
    let openType: Int?

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



struct StandaloneController: Codable {
    let controllerId: String
    let controllerName: String?
    let controllerSerial: String?
    let controllerMac: String?
    let controllerKey: String?
    let controllerModel: String?
    let controllerCommType: String?
    let controllerType : String?
    let maxDoorsSupported: Int?
    let doors: [SensorlessDoor]?

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



struct SensorlessDoor: Codable {
    
    let doorId: String
    let doorName: String?
    let doorNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorNumber = "door_number"
    }
}

struct ServerTimeResponse: Codable {
    
    let status: Bool
    let datetime: String?
}
