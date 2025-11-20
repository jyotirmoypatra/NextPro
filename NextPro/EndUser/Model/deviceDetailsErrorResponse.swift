//
//  TokenErrorResponse.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//


import Foundation
import Combine

struct deviceDetailsErrorResponse: Codable {
    let detail: String
    let code: String
    let messages: [TokenErrorMessage]
}

struct TokenErrorMessage: Codable {
    let tokenClass: String
    let tokenType: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case tokenClass = "token_class"
        case tokenType = "token_type"
        case message
    }
}

