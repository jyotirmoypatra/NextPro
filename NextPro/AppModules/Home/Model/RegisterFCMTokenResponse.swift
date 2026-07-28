//
//  RegisterDeviceTokenResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//


import Foundation

struct RegisterDeviceTokenResponse: Codable {
    let status: Bool?
    let message: String?
    let data: DeviceTokenData?
}

struct DeviceTokenData: Codable {
    let id: Int?
    let platform: String?
    let appVersion: String?
    let isActive: Bool?
    let lastUsedAt: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case platform
        case appVersion = "app_version"
        case isActive = "is_active"
        case lastUsedAt = "last_used_at"
        case createdAt = "created_at"
    }
}