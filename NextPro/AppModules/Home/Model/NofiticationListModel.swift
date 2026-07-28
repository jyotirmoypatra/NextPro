//
//  NofiticationListModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import Foundation

// MARK: - Root Response
struct NotificationResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [NotificationSection]?
    let total: Int?
    let page: Int?
    let pageSize: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
        case total
        case page
        case pageSize = "page_size"
    }
}

// MARK: - Notification Section
struct NotificationSection: Codable {
    let date: String?
    let notifications: [NotificationItem]?
}

// MARK: - Notification Item
struct NotificationItem: Codable, Identifiable {
    let id: String?
    let type: String?
    let entityType: String?
    let entityID: String?
    let label: String?
    let tag: String?
    let additionalInfo: AdditionalInfo?
    let title: String?
    let description: String?
    let isRead: Bool?
    let readAt: String?
    let fromUser: FromUser?
    let createdAt: String?
    let timeElapsed: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case entityType = "entity_type"
        case entityID = "entity_id"
        case label
        case tag
        case additionalInfo = "additional_info"
        case title
        case description
        case isRead = "is_read"
        case readAt = "read_at"
        case fromUser = "from_user"
        case createdAt = "created_at"
        case timeElapsed = "time_elapsed"
    }
}

// MARK: - Additional Info
struct AdditionalInfo: Codable {
    let totalItems: Int?
    let completedItems: Int?
    let failedItems: Int?

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case completedItems = "completed_items"
        case failedItems = "failed_items"
    }
}

// MARK: - From User
struct FromUser: Codable {
    let id: String?
    let fullName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
    }
}
