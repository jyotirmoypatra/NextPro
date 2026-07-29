//
//  MarkNotificationReadResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//


import Foundation

// MARK: - Mark All Notification Read Response
struct MarkNotificationReadResponse: Codable {
    let status: Bool?
    let message: String?
    let data: MarkNotificationReadData?
}

// MARK: - Data
struct MarkNotificationReadData: Codable {
    let updated: Int?
}


// MARK: - Mark Single Notification Read Response
struct MarkSingleNotificationReadResponse: Codable {
    let status: Bool?
    let message: String?
    //let data: MarkNotificationReadData?
}
