//
//  UserProfileData.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//

struct UserProfileResponse: Decodable {
    let status: Bool
    let message: String?
    let data: UserProfileData
}


struct UserProfileData: Decodable {
    let user_id: String?

    let full_name: String?
    let username: String?
    let email: String?
    let user_type: String?

    let phone_number: String?
    let status: String?

    let image_url: String?

    let user_role: String?
    let user_role_detail: UserRoleDetail?

    let permissions: Permissions?

    let device_access_details: DeviceAccessDetails?

    let nfc_type: String?
    let nfc_physical: String?
    let nfc_digital: String?

    let access_groups: [String]?
    let access_groups_detail: [AccessGroupDetail]?

    let doors: [String]?

    let schedule_type: String?
    let start_date: String?
    let end_date: String?

    let time_slots: [TimeSlot]?

    let week_days: String?
    let creation_method: String?
    let source: String?
    
    let is_shared_link: Bool?
    
    let voice_message: VoiceMessage?
}

struct VoiceMessage: Decodable {
    let is_active_voice: Bool?

    let access_granted: [VoiceMessageOption]?
    let access_denied: [VoiceMessageOption]?
    let access_unauthorized: [VoiceMessageOption]?
    let welcome: [VoiceMessageOption]?

    let pattern: [VoicePattern]?
}


struct VoiceMessageOption: Codable {
    let id: String?
    let message: String?
    let isActive: Bool?
    let isPreset: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case isActive = "is_active"
        case isPreset = "is_preset"
    }
}

struct VoicePattern: Codable {
    let id: String?
    let name: String?
    let type: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case isActive = "is_active"
    }
}


struct UserEditProfileResponse: Decodable {
    let status: Bool
    let message: String
}
