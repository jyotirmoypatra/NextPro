//
//  APIConfig.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct APIConfig {
    
    // MARK: - Base URL
    static let baseURL = "https://yourapi.com/api/v1"
    
    // MARK: - Endpoints
    struct Endpoints {
        static let login = "/auth/login"

       
    }
    
    static func url(_ endpoint: String) -> String {
        return baseURL + endpoint
    }
}
