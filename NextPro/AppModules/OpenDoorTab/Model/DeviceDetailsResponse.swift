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
        case controllers = "controllers"
        case standaloneAllInOne = "standalone_all_in_one"
        case standaloneController = "standalone_controller"
    }
}

struct AccessDoor: Codable {
    let doorId: String
    let doorName: String?

    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
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
    let latitude: Double?
    let longitude: Double?
    let currentAddress: String?
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
        case latitude
        case longitude
        case currentAddress = "current_address"
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
    let accessGroups: [AccessGroups]?

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
        case accessGroups = "access_groups"
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
    let latitude: Double?
    let longitude: Double?
    let currentAddress: String?
    let accessGroups: [AccessGroups]?

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
        case latitude
        case longitude
        case currentAddress = "current_address"
        case accessGroups = "access_groups"
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
    let latitude: Double?
    let longitude: Double?
    let currentAddress: String?
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
        case latitude
        case longitude
        case currentAddress = "current_address"
        case doors
    }
}



struct SensorlessDoor: Codable {
    
    let doorId: String
    let doorName: String?
    let doorNumber: Int?
    let accessGroups: [AccessGroups]?
    
    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
        case doorNumber = "door_number"
        case accessGroups = "access_groups"
        
    }
}


struct AccessGroups: Codable {
    let accessGroupId: String
    let accessGroupName: String?
    let tpgId: Int?
    let isInternal: Bool?
    let scheduleType: String?
    let startDate: String?
    let endDate: String?
    let timeSlots: [TimeSlot]?
    let weekDays: String?

    enum CodingKeys: String, CodingKey {
        case accessGroupId = "access_group_id"
        case accessGroupName = "access_group_name"
        case tpgId = "tpg_id"
        case isInternal = "is_internal"
        case scheduleType = "schedule_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case timeSlots = "time_slots"
        case weekDays = "week_days"
    }
}


struct ServerTimeResponse: Codable {
    
    let serverDateTime: String?
    let serverTimezone: String?
    let localTimezone: String?
    
    enum CodingKeys: String, CodingKey {
        case serverDateTime = "server_datetime"
        case serverTimezone = "server_timezone"
        case localTimezone = "local_timezone"
    }
}

