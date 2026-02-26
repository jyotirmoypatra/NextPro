//
//  DeleteUserResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 16/02/26.
//


struct DeleteUserResponse: Codable {
    let status: Bool
    let message: String
    let mqttCleanup: MQTTCleanup?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case mqttCleanup = "mqtt_cleanup"
    }
}

struct MQTTCleanup: Codable {
    let status: String?
    let devicesProcessed: Int?
    let onlineSerials: [String]?

    enum CodingKeys: String, CodingKey {
        case status
        case devicesProcessed = "devices_processed"
        case onlineSerials = "online_serials"
    }
}