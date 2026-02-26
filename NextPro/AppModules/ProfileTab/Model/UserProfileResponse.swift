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
    let facility_user_id: String?

    let full_name: String?
    let username: String?
    let email: String?
    let user_type: String?
    let is_admin: Bool?

    let phone_number: String?
    let status: String?
    let organization: String?

    let created_at: String?
    let updated_at: String?

    let image_url: String?

    let user_role: String?
    let user_role_detail: UserRoleDetail?

    let permissions: Permissions?

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
}

struct UserRoleDetail: Decodable {
    let id: String?
    let role_name: String?

    let is_web: Bool?
    let is_mobile: Bool?

    let is_digital: Bool?
    let is_remote: Bool?
    let is_ble: Bool?
    let is_wifi: Bool?
}

struct Permissions: Decodable {
    let sub_admin: PermissionAction?
    let staff_role: PermissionAction?
    let access_group: PermissionAction?
    let facility_user: PermissionAction?
    let device_mapping: PermissionAction?
    let door_management: PermissionAction?
    let device_management: PermissionAction?
    let building_management: PermissionAction?
    let facility_management: PermissionAction?
}



struct PermissionAction: Decodable {
    let read: Bool?
    let write: Bool?
}






//UserEditProfileResponse

struct UserEditProfileResponse: Decodable {
    let status: Bool
    let message: String
}
