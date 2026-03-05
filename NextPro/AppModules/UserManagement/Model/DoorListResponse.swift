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
    let floor: String?
    let building: Building?
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
        case floor
        case building
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


struct Building: Codable, Equatable {
    let id: String
    let facility: String?
    let organization: String
    let buildingName: String
    let buildingCode: String
    let noOfFloor: Int?
    let contactPerson: String?
    let phoneNumber: String?
    let address: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case facility
        case organization
        case buildingName = "building_name"
        case buildingCode = "building_code"
        case noOfFloor = "no_of_floor"
        case contactPerson = "contact_person"
        case phoneNumber = "phone_number"
        case address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
