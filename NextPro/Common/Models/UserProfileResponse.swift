//
//  UserProfileData.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/11/25.
//


struct UserProfileData: Decodable {
    let full_name: String?
    let phone: String?
    let email: String?
    let status: String?
    let organization: String?
    let created_at: String?
    let updated_at: String?
    let image_url: String?
}

struct UserProfileResponse: Decodable {
    let status: Bool
    let message: String?
    let data: UserProfileData
}




//UserEditProfileResponse

struct UserEditProfileResponse: Decodable {
    let status: Bool
    let message: String
}
