//
//  UnreadNotificationCountResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//


import Foundation

struct UnreadNotificationCountResponse: Codable {
    let status: Bool?
    let message: String?
    let data: UnreadCountData?
}

struct UnreadCountData: Codable {
    let unreadCount: Int?

    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
    }
}
