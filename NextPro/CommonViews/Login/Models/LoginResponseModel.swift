//
//  LoginResponseModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct LoginResponseModel: Decodable {
    let status: Bool
    let message: String
    let user_id: String?
    let facility_id: String?
    let is_reset_password: Bool?
    let username: String?
    let user_type: String?
    let refresh: String?
    let access: String?
    let is_digital : Bool?
    let is_remote : Bool?
    let is_wifi : Bool?
    let is_ble : Bool?
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
