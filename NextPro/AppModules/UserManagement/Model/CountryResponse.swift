//
//  CountryResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 02/11/26.
//


import Foundation

struct CountryResponse: Codable {
    let status: Bool
    let message: String
    let data: [Country]
}

struct Country: Codable, Identifiable, Hashable {
    var id: String { code }

    let code: String
    let name: String
    let dialCode: String

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case dialCode = "dial_code"
    }
}
