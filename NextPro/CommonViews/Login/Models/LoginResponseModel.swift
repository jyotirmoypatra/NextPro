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
   // let access_modes: AccessModes?
    let digital_access : Bool?
    let remote_access : Bool?
}


struct AccessModes: Decodable {
    let digitalKeyAccess: Bool?
    let remoteAccess: RemoteAccess?

    enum CodingKeys: String, CodingKey {
        case digitalKeyAccess = "digital_key_access"
        case remoteAccess = "remote_access"
    }
}


struct RemoteAccess: Decodable {
    let remoteBLE: Bool?
    let remoteWiFi: Bool?

    enum CodingKeys: String, CodingKey {
        case remoteBLE = "remote_ble"
        case remoteWiFi = "remote_wifi"
    }
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
