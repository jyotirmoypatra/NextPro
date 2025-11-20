//
//  APIConfig.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct APIConfig {
    
    // MARK: - Base URL
    static let baseURL = "https://devapi.nextprotechnologies.com"
    
    // MARK: - Endpoints
    struct Endpoints {
        static let login = "/api/facility-user/login/"
        static let updatePassword = "/api/facility-user/reset-password/"
        static let deviceDetails = "/api/facility-user/device/detail/"
    }
    
    
    
    
    static func url(_ endpoint: String) -> String {
        return baseURL + endpoint
    }
}
