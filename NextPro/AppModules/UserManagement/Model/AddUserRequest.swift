//
//  AddUserRequest.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 10/02/26.
//

struct AddUserRequest: Codable {

    // MARK: - User Info
    let user_id: String?
    let id: String?
    let username: String?
    let password: String?
    let full_name: String
    let email: String
    let phone_number: String
    let user_type: String

    // MARK: - Access Mode
    let is_digital: Bool
    let is_remote: Bool

    // MARK: - NFC
    let nfc_type: String
    let nfc_physical: String?
    let nfc_digital: String?

    // MARK: - Door / Assignment
    let doors: [String]?
    
    let access_groups: [String]?

    // MARK: - Schedule
    let start_date: String?
    let end_date: String?
    let time_slots: [TimeSlot]?
    let week_days: String?   // empty or nil for one_time

    // MARK: - Meta
    let source: String?
    let is_mqtt_sync: Bool
    let is_shared_link: Bool
    let creation_method: String   // door_selection / access_group
    let schedule_type: String     // one_time / schedule
}


struct TimeSlot: Codable {
    let start_time: String
    let end_time: String
}



struct AddUserResponse: Codable {
    let status: Bool
    let message: String
}
