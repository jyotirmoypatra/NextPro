//
//  UsersResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//
import Foundation

struct UsersResponse: Codable {
    let status: Bool
    let data: [User]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}

struct User: Codable, Identifiable {

    let id: String               // facility_user_id
    let userId: String
    let username: String?
    let fullName: String
    let phone: String?
    let userType: String
    let userTypeLabel: String
    let status: String
    let createdAt: String
    let nfcPhysical: String?
    let nfcDigital: String?
    let nfcStartDate: String?
    let nfcEndDate: String?
    let accessGroups: [AccessGroup]
    let buildingId: String?
    let buildingName: String?
    let creationMethod: String?

    enum CodingKeys: String, CodingKey {
        case id = "facility_user_id"
        case userId = "user_id"
        case username
        case fullName = "full_name"
        case phone
        case userType = "user_type"
        case userTypeLabel = "user_type_label"
        case status
        case createdAt = "created_at"
        case nfcPhysical = "nfc_physical"
        case nfcDigital = "nfc_digital"
        case nfcStartDate = "nfc_start_date"
        case nfcEndDate = "nfc_end_date"
        case accessGroups = "access_groups"
        case buildingId = "building_id"
        case buildingName = "building_name"
        case creationMethod = "creation_method"
    }
}

struct AccessGroup: Codable {
    let accessGroupId: String
    let accessGroupName: String
    let doors: [DoorDetails]

    enum CodingKeys: String, CodingKey {
        case accessGroupId = "access_group_id"
        case accessGroupName = "access_group_name"
        case doors
    }
}

struct DoorDetails: Codable {
    let doorId: String
    let doorName: String

    enum CodingKeys: String, CodingKey {
        case doorId = "door_id"
        case doorName = "door_name"
    }
}
