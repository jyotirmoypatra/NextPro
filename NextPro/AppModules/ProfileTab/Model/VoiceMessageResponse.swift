//
//  VoiceMessageResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/09/26.
//


import Foundation

// MARK: - Root Response

struct VoiceMessageResponse: Codable {
    let status: Bool
    let message: String
    let data: VoiceMessageTemplatesData
}

// MARK: - Data

struct VoiceMessageTemplatesData: Codable {
    let isActiveVoice: Bool
    let accessGranted: [VoiceMessageOption]
    let accessDenied: [VoiceMessageOption]
    let accessUnauthorized: [VoiceMessageOption]
    let welcome: [VoiceMessageOption]
    let pattern: [VoicePattern]

    enum CodingKeys: String, CodingKey {
        case isActiveVoice = "is_active_voice"
        case accessGranted = "access_granted"
        case accessDenied = "access_denied"
        case accessUnauthorized = "access_unauthorized"
        case welcome
        case pattern
    }
}

