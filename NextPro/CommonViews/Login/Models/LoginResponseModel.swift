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
    let isResetPassword: Bool?
    let username: String?
    let user_type: String?
    let refresh: String?
    let access: String?
}
