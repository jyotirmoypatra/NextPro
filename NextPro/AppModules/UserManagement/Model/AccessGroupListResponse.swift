//
//  AccessGroupListResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/02/26.
//


import Foundation

struct AccessGroupListResponse: Codable {
    let status: Bool
    let data: [AccessGroupItem]
}

struct AccessGroupItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let doors: [String]
}