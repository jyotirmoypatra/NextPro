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
    let isActiveVoiceGranted: Bool
    let isActiveVoiceDenied: Bool
    let isActiveVoiceUnauthorized: Bool
    let isActiveVoiceWelcome: Bool
    let accessGranted: [VoiceMessageOption]
    let accessDenied: [VoiceMessageOption]
    let accessUnauthorized: [VoiceMessageOption]
    let welcome: [VoiceMessageOption]

    enum CodingKeys: String, CodingKey {
        case isActiveVoiceGranted = "is_voice_active_granted"
        case isActiveVoiceDenied = "is_voice_active_denied"
        case isActiveVoiceUnauthorized = "is_voice_active_unauthorized"
        case isActiveVoiceWelcome = "is_voice_active_welcome"
        case accessGranted = "access_granted"
        case accessDenied = "access_denied"
        case accessUnauthorized = "access_unauthorized"
        case welcome
    }
}

