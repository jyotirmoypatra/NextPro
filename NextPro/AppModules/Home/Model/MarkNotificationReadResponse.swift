//
//  MarkNotificationReadResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//


import Foundation

// MARK: - Mark Read Response
struct MarkNotificationReadResponse: Codable {
    let status: Bool?
    let message: String?
    let data: MarkNotificationReadData?
}

// MARK: - Data
struct MarkNotificationReadData: Codable {
    let updated: Int?
}