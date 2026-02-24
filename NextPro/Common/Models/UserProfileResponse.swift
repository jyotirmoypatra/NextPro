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
    let full_name: String?
    let phone_number: String?
    let email: String?
    let status: String?
    let organization: String?
    let created_at: String?
    let updated_at: String?
    let image_url: String?
    let is_digital: Bool?
    let is_admin: Bool?
    let is_remote: Bool?
    let is_wifi: Bool?
    let is_ble: Bool?
    let permissions: Permissions?
}

struct Permissions: Decodable {
    let sub_admin: PermissionAction?
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
