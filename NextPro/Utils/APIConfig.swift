//
//  APIConfig.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//


import Foundation

struct APIConfig {
    
    enum Environment {
           case development
           case staging
           case production
    }

  // Change only this line when switching environments
   static let environment: Environment = .development
    
    static var baseURL: String {
        switch environment {
        case .development:
            return "https://devapi.nextprotechnologies.com" // Change to your dev API

        case .staging:
            return "https://stageapi.nextprotechnologies.com" // Change to your stage API

        case .production:
            return "https://api.nextprotechnologies.com" // Change to your production API
        }
    }
    
    // MARK: - Endpoints
    struct Endpoints {
        static let login = "/api/facility-user/login/"
        static let updatePassword = "/api/facility-user/reset-password/"
        static let deviceDetails = "/api/facility/user/device-access/"
        static let forgetPasswordRequest = "/api/facility-user/forgot-password/request/"
        static let forgetPasswordOtpVerify = "/api/facility-user/forgot-password/verify/"
        //static let getUserProfileData = "/api/facility-user/user-detail/"
        static let getUserProfileData = "/api/authentication/details/"
        static let uploadProfilePic = "/api/facility-user/upload-image/"
        //static let editUserProfile = "/api/facility-user/user/update/"
        static let editUserProfile = "/api/authentication/update/"
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
        
        
        static let registerFCMToken = "/api/notifications/device-tokens/"
        static let unRegisterFCMToken = "/api/notifications/device-tokens/{token_id}/"
        static let getNotificationList = "/api/notifications/mine/"
        static let readAllNotification = "/api/notifications/mine/read-all/"
        static let unreadNotificationCount = "/api/notifications/mine/unread-count/"
        static let readNotification = "/api/notifications/mine/{notification_id}/read/"
        
        static let setControllerDoorUnlockTime = "/api/"
    }
    
    static func url(_ endpoint: String) -> String {
        return baseURL + endpoint
    }

    // MARK: - Legal Doc Url
    struct Web {

        static var privacy: String {
            switch APIConfig.environment {
            case .development:
                return "https://dev.nextprotechnologies.com/privacy-policy"

            case .staging:
                return "https://stage.nextprotechnologies.com/privacy-policy"

            case .production:
                return "https://nextprotechnologies.com/privacy-policy"
            }
        }

        static var terms: String {
            switch APIConfig.environment {
            case .development:
                return "https://dev.nextprotechnologies.com/terms-and-conditions"

            case .staging:
                return "https://stage.nextprotechnologies.com/terms-and-conditions"

            case .production:
                return "https://nextprotechnologies.com/terms-and-conditions"
            }
        }
    }
    
    
}
