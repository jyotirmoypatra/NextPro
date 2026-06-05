//
//  AccessGroupListResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/02/26.
//


import Foundation

//struct AccessGroupListResponse: Codable {
//    let status: Bool
//    let data: [AccessGroupItem]
//}
//
//struct AccessGroupItem: Codable, Identifiable {
//    let id: String
//    let name: String
//    let description: String?
//    let doors: [String]
//}



struct AccessGroupListResponse: Codable {
    let status: Bool
    let data: [AccessGroupItem]
}

struct AccessGroupItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let doors: [DoorItem]
    let accessType: String
    let totalUsers: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case doors
        case accessType = "access_type"
        case totalUsers = "total_users"
    }
}

struct DoorItem: Codable, Identifiable {
    let id: String
    let doorName: String

    enum CodingKeys: String, CodingKey {
        case id
        case doorName = "door_name"
    }
}
