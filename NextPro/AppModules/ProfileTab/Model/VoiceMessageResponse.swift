//
//  VoiceMessageTemplatesResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/09/26.
//


import Foundation

// MARK: - Root Response

struct VoiceMessageTemplatesResponse: Codable {
    let status: Bool
    let message: String
    let data: VoiceMessageTemplatesData
}

// MARK: - Data

struct VoiceMessageTemplatesData: Codable {
    let isActiveVoice: Bool
    let accessGranted: [VoiceMessageTemplate]
    let accessDenied: [VoiceMessageTemplate]
    let accessUnauthorized: [VoiceMessageTemplate]
    let welcome: [VoiceMessageTemplate]
    let pattern: [VoiceMessagePattern]

    enum CodingKeys: String, CodingKey {
        case isActiveVoice = "is_active_voice"
        case accessGranted = "access_granted"
        case accessDenied = "access_denied"
        case accessUnauthorized = "access_unauthorized"
        case welcome
        case pattern
    }
}

// MARK: - Voice Message Template

struct VoiceMessageTemplate: Codable, Identifiable {
    let id: String
    let message: String
    let isActive: Bool
    let isPreset: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case isActive = "is_active"
        case isPreset = "is_preset"
    }
}

// MARK: - Voice Message Pattern

struct VoiceMessagePattern: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case isActive = "is_active"
    }
}