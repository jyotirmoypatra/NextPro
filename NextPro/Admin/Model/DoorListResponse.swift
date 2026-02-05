//
//  DoorListResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 05/02/26.
//


// MARK: - DoorListResponse
struct DoorListResponse: Codable {
    let status: Bool
    let message: String
    let data: [SingleDoor]
}


// MARK: - DoorModel
struct SingleDoor: Codable, Identifiable, Equatable {
    let id: String
    let doorName: String
    let location: String?
    let status: String
    let device: String
    let organization: String
    let facility: String?
    let building: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case doorName = "door_name"
        case location
        case status
        case device
        case organization
        case facility
        case building
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
