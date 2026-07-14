//
//  APIConfig.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct APIConfig {
    
static let isProduction = true
    
static let baseURL = "https://devapi.nextprotechnologies.com"
//static let baseURL = "https://stageapi.nextprotechnologies.com"
    
    // MARK: - Endpoints
    struct Endpoints {
        static let login = "/api/facility-user/login/"
        static let updatePassword = "/api/facility-user/reset-password/"
        static let deviceDetails = "/api/facility/user/device-access/"
        static let forgetPasswordRequest = "/api/facility-user/forgot-password/request/"
        static let forgetPasswordOtpVerify = "/api/facility-user/forgot-password/verify/"
        static let getUserProfileData = "/api/facility-user/user-detail/"
        static let uploadProfilePic = "/api/facility-user/upload-image/"
        static let editUserProfile = "/api/facility-user/user/update/"
        static let validateEmail = "/api/facility-user/validate-email/"
        static let aggremntAccept = "/api/facility-user/update-agreement/"
        static let adminAssignDeviceList = "/api/facility/user/configure-device-list/"
        static let adminConfigureDeviceList = "/api/wifi-configuration/"
        static let successWifiConfig = "/api/wifi-configuration/"
        static let serverDateTime = "/api/authentication/server-datetime/"
        static let refreshToken = "/api/authentication/token/refresh/"
        static let fetchUsersList = "/api/facility-manager/filter-list/"
        static let addNewUser = "/api/facility-manager/add/"
        static let updateUser = "/api/facility-manager/update/"
        static let uniqueNfcCardGenerate = "/api/doors/generate-unique-nfc/"
        static let allDoorList = "/api/doors/all-door-list/"
        static let getUserDetails = "/api/facility-manager/detail/"
        static let getAccessGroupList = "/api/access-group/list/"
        static let deleteUser = "/api/facility-manager/delete/"
        static let deleteAccount = "/api/facility-user/account/delete/"
    }
    
    struct Web {
        static let privacy = "https://dev.nextprotechnologies.com/privacy-policy"
        static let terms = "https://dev.nextprotechnologies.com/terms-and-conditions"
    }
    
    
    
    static func url(_ endpoint: String) -> String {
        return baseURL + endpoint
    }
}
