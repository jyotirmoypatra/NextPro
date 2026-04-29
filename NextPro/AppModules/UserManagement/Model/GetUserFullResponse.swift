//
//  GetUserFullResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/02/26.
//


struct GetUserFullResponse: Codable {
    let status: Bool
    let data: GetUserData
}

struct GetUserData: Codable {
    
    let id: String
    let user_id: String
    let full_name: String
   let username: String?
    let email: String
    let user_type: String
    let phone_number: String?
    let status: String
    
    let is_digital: Bool
    let is_remote: Bool
    
    let nfc_type: String
    let nfc_physical: String?
    let nfc_digital: String?
    
    let access_groups: [String]
    let access_groups_detail: [AccessGroupDetail]
    
    let doors: [String]
    
    let is_shared_link: Bool
    let schedule_type: String
    let start_date: String?
    let end_date: String?
    let time_slots: [TimeSlot]
    let week_days: String?
    
    let creation_method: String
    let source: String
}


struct AccessGroupDetail: Codable {
    let access_group_id: String
    let access_group_name: String
    let doors: [AccessGroupDoor]
}

struct AccessGroupDoor: Codable {
    let door_id: String
    let door_name: String
}
