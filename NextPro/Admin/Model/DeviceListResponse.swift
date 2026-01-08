//
//  DeviceListResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//
import Foundation

struct AssignDeviceListResponse: Codable {
    let status: Bool
    let message: String
    let devices: [AssignDevice]?
}

struct AssignDevice: Codable, Identifiable  {

    let serial: String
    let mac: String
    let key: String
    let modelName: String
    let isConfigured: Bool?
    let openType: Int?
    let devType: Int?
    let status: String?
    var id: String { serial  }

    enum CodingKeys: String, CodingKey {
        case serial
        case mac
        case key
        case modelName = "model_name"
        case isConfigured = "is_configured"
        case openType = "open_type"
        case devType = "dev_type"
        case status
    }
}
