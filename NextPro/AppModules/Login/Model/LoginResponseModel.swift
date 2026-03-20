//
//  LoginResponseModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct LoginResponseModel: Decodable {
    let status: Bool
    let message: String?
    let user_id: String?
    let facility_id: String?
    let username: String?
    let full_name: String?
    let user_type: String?
    let user_role: String?
    
    let user_role_detail: UserRoleDetail?
    let device_access_details: DeviceAccessDetails?
    
    let permission: Permissions? 
    
    let is_reset_password: Bool?
    let is_aggrement_accept: Bool?
    let is_admin: Bool?
    
    let refresh: String?
    let access: String?
}

struct DeviceAccessDetails: Decodable {
    let is_digital: Bool?
    let is_remote: Bool?
    let is_ble: Bool?
    let is_wifi: Bool?
}


struct UserRoleDetail: Decodable {
    let id: String?
    let role_name: String?
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


struct ValidateEmailResponseModel: Decodable {
    let status: Bool
    let message: String
    let user_id: String?
    let facility_user_id: String?
    let email: String?
    let is_reset_password: Bool
    let is_aggrement_accept: Bool
 
}


struct AggremntResponseModel: Codable {
    let status: Bool
    let message: String
}
