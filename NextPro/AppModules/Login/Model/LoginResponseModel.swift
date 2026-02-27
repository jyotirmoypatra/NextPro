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
    let permission: Permissions?
    let is_reset_password: Bool?
    let is_aggrement_accept: Bool?
    let is_admin: Bool?
    let refresh: String?
    let access: String?
    
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
