//
//  NetworkManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//

import Foundation
import Network
import Combine


class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = false
    @Published var hasInternet: Bool = false
    @Published var didCheckInternet: Bool = false
    
    @Published var showSessionExpiredAlert = false

    private init() {
        startMonitoring()
    }

    protocol BaseResponse {
        var status: Bool { get }
        var message: String { get }
    }

    
    enum APIError: LocalizedError {
        case invalidURL
        case unAuthorized
        case invalidResponse
        case serverError(code: Int, message: String)
        case backend(message: String)
        case network(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .unAuthorized:
                return "Authorization failed. Please try again."
            case .invalidResponse:
                return "Invalid server response."
            case .serverError(let code, let message):
                return "Error \(code): \(message)"
            case .backend(let message):
                return message
            case .network(let message):
                return message
            }
        }
    }

    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied

                if path.status == .satisfied {
                    self?.checkInternet()
                } else {
                    self?.hasInternet = false
                    self?.didCheckInternet = true     
                }
            }
        }
        
        monitor.start(queue: queue)
    }

    func checkInternet() {
        guard let url = URL(string: "https://www.google.com/generate_204") else { return }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                if let http = response as? HTTPURLResponse, http.statusCode == 204 {
                    print("✅ Internet working")
                    self.hasInternet = true
                } else {
                    print("⚠️NO Internet")
                    self.hasInternet = false
                }

                self.didCheckInternet = true
            }
        }.resume()
    }
    
    func extractErrorMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json["message"] as? String
        }
        return nil
    }
    
    // MARK: - Generic Authorized Request Executor
    private func performRequest<T: Decodable>(
        url: URL,
        method: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        responseType: T.Type,
        retry: Bool = false
    ) async throws -> T {

        print("🌐 URL:", url.absoluteString)
        print("📡 Method:", method)
        if let body {
            if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Body:\n\(jsonString)")
            }
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        if requiresAuth {
            guard let token = KeychainManager.shared.get("access_token"),
                  !token.isEmpty else {
                throw APIError.unAuthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let json = String(data: data, encoding: .utf8) {
            print("📥 Response:\n\(json)")
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

       

        
        // 🔴 Access token expired
           if http.statusCode == 401, retry {
               print("🔁 Access token expired. Refreshing...")

               let refreshResponse = try await refressToken()

               if let newAccess = refreshResponse.access {
                   KeychainManager.shared.save(newAccess, forKey: "access_token")
               }

               if let newRefresh = refreshResponse.refresh {
                   KeychainManager.shared.save(newRefresh, forKey: "refresh_token")
               }

               // 🔁 Retry original request once
               return try await performRequest(
                   url: url,
                   method: method,
                   body: body,
                   requiresAuth: requiresAuth,
                   responseType: responseType,
                   retry: false
               )
           }
        
        // authentication failed after one rety and logout
        if http.statusCode == 401, !retry , requiresAuth{

                print("🚪 Session expired after retry. Showing alert...")

                DispatchQueue.main.async {
                    if !NetworkManager.shared.showSessionExpiredAlert {
                        NetworkManager.shared.showSessionExpiredAlert = true
                    }
                }

                throw APIError.unAuthorized
        }
        
        guard (200...299).contains(http.statusCode) else {
            let message = extractErrorMessage(from: data) ?? "Something went wrong."
            throw APIError.serverError(code: http.statusCode, message: message)
        }
        
        let decoded = try JSONDecoder().decode(T.self, from: data)

        // Handle backend `status == false`
        if let base = decoded as? BaseResponse, base.status == false {
            throw APIError.backend(message: base.message)
        }

        return decoded
    }


    
    //All API list
    
    // MARK: - Validate Email API

    func ValidateEmail(email: String) async throws -> ValidateEmailResponseModel {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.validateEmail))!
        print("validate Email Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "email": email
            ],
            responseType: ValidateEmailResponseModel.self
        )
    }

    
    
    // MARK: - Accept Aggremnt  API

    func AggremntAccept(
        userEmail: String,
        isAccepted: Bool
    ) async throws -> AggremntResponseModel {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.aggremntAccept))!
        print("Aggrement Api called----------------")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "email": userEmail,
                "is_aggrement_accepted": isAccepted
            ],
            responseType: AggremntResponseModel.self
        )
    }

    
    
    // MARK: - LOGIN API

    func login(email: String, password: String) async throws -> LoginResponseModel {
        let url = URL(string: APIConfig.url(APIConfig.Endpoints.login))!
        print("login Api called----------------")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "username": email,
                "password": password
            ],
            responseType: LoginResponseModel.self
        )
    }

    

    // MARK: - Update Password API

    func updatePassword(
        newPassword: String,
        confirmPassword: String,
        userName: String
    ) async throws -> UpdatePasswordResponseModel {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.updatePassword))!
        print("Update password Api called----------------")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "username": userName,
                "new_password": newPassword,
                "confirm_password": confirmPassword
            ],
            responseType: UpdatePasswordResponseModel.self
        )
    }

    
    
       // MARK: - Device Details API
    func deviceDetails(userID: String) async throws -> DeviceDetailsResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.deviceDetails))!
        print("DeviceDe Api called----------------")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userID
            ],
            requiresAuth: true,
            responseType: DeviceDetailsResponse.self,
            retry: true
        )
    }



    // MARK: - Forget password  API
    
    func requestForgetPassword(email: String) async throws -> ForgetPasswordResponseModel {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.forgetPasswordRequest))!
        print("Req Forget Password otp Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "email": email
            ],
            responseType: ForgetPasswordResponseModel.self
        )
    }

    
    
    
    // // MARK: - verify otp

    func requestVerifyOtp(
        email: String,
        otp: String
    ) async throws -> ForgetPasswordOtpVerifyresponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.forgetPasswordOtpVerify))!
        print("Verify otp Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "email": email,
                "code": otp
            ],
            responseType: ForgetPasswordOtpVerifyresponse.self
        )
    }

    
    // MARK: - User PRofile Details
    func UserProfileDetails(id: String) async throws -> UserProfileResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.getUserProfileData))!
        print("UserProfile details Api called----")
        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: UserProfileResponse.self,
            retry: true
        )
    }

    
    // MARK: - profile img upload
    func UploadProfileImage(
        userId: String,
        base64: String
    ) async throws -> UploadProfileImgResponseModel {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.uploadProfilePic))!
        print("Upload photo Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userId,
                "image": base64
            ],
            requiresAuth: true,
            responseType: UploadProfileImgResponseModel.self,
            retry: true
        )
    }

    
    // MARK: - Edit profile
    func EditUserProfileDetails(
        fullName: String,
        phone: String,
        userId: String
    ) async throws -> UserEditProfileResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.editUserProfile))!
        print("Edit profile Api called----")
        return try await performRequest(
            url: url,
            method: "PUT",
            body: [
                "user_id": userId,
                "full_name": fullName,
                "phone_number": phone
            ],
            requiresAuth: true,
            responseType: UserEditProfileResponse.self,
            retry: true
        )
    }

    
    // MARK: - AssignDevice list admin
    
   func AssignDeviceList(
        userID: String,
        page: Int = 1,
        pageSize: Int = 10
    ) async throws -> AssignDeviceListResponse {

        var components = URLComponents(
            string: APIConfig.url(APIConfig.Endpoints.adminConfigureDeviceList)
        )!

        components.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        print("Admin Device list Api called----")
        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: AssignDeviceListResponse.self,
            retry: true
        )
    }



    // MARK: - Device Config Success api
    func successDeviceConfig(
        userId: String,
        isSuccess: Bool,
        deviceSerial: String,
        ssid: String,
        password: String,
        latitude : String,
        longitude : String,
        current_address : String
    ) async throws -> successDeviceConfigResposne {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.successWifiConfig))!
        print("SuccessConfig wifi Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userId,
                "device_serial": deviceSerial,
                "wifi_ssid_name": ssid,
                "wifi_password": password,
                "is_configured": isSuccess,
                "latitude" : latitude,
                "longitude" : longitude,
                "current_address" : current_address
            ],
            requiresAuth: true,
            responseType: successDeviceConfigResposne.self,
            retry: true
        )
    }
    
    // MARK: - Server Time api
    func serverTime() async throws -> ServerTimeResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.serverDateTime))!
        print("Server Time Api called----------------")
        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: ServerTimeResponse.self,
            retry: true
        )
    }

    // MARK: - Fetch User List api
    func fetchUserList(userId: String, page: Int, pageSize: Int , search: String) async throws -> UsersListResponse {
        let url = URL(string: APIConfig.url(APIConfig.Endpoints.fetchUsersList))!
        print("fetchUserList Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userId,
                "source" : "app" ,
                "page" : page ,
                "page_size" : pageSize,
                "search" :  search
            ],
            requiresAuth: true,
            responseType: UsersListResponse.self,
            retry: true
        )
    }
    
    // MARK: - Add New User api
    func addNewUser(body: AddUserRequest,isEditUser:Bool) async throws -> AddUserResponse {

        let url = URL(string: APIConfig.url(isEditUser ? APIConfig.Endpoints.updateUser : APIConfig.Endpoints.addNewUser))!
        print("Add update user Api called")
        return try await performRequest(
            url: url,
            method: isEditUser ? "PUT" : "POST",
            body: try body.toDictionary(),
            requiresAuth: true,
            responseType: AddUserResponse.self,
            retry: true
        )
    }
    // MARK: - Refresh Token  api
    func refressToken() async throws -> RefreshTokenResponse {

        guard let refreshToken = KeychainManager.shared.get("refresh_token"),
              !refreshToken.isEmpty else {
            throw APIError.unAuthorized
        }

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.refreshToken))!
        print("🔄 Refresh token Api called")

        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "refresh": refreshToken
            ],
            responseType: RefreshTokenResponse.self
        )
    }
    
    // MARK: - NFC Card Generate api
    func generateUniqueNfcId() async throws -> UniqueCardResponse {
        let url = URL(string: APIConfig.url(APIConfig.Endpoints.uniqueNfcCardGenerate))!
        print("🔄 Unique Card Nfc Api called")

        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: UniqueCardResponse.self,
            retry: true
        )
    }
    
    // MARK: - Get All Door List api
    func getAllDoorList() async throws -> DoorListResponse {


        let url = URL(string: APIConfig.url(APIConfig.Endpoints.allDoorList))!
        print("Get All Door Api called")

        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: DoorListResponse.self,
            retry: true
        )
    }
    
    // MARK: - Get Access Group List api
    func getAccessGroupList() async throws -> AccessGroupListResponse {


        let url = URL(string: APIConfig.url(APIConfig.Endpoints.getAccessGroupList))!
        print("Get Access group list Api called")

        return try await performRequest(
            url: url,
            method: "GET",
            requiresAuth: true,
            responseType: AccessGroupListResponse.self,
            retry: true
        )
    }
    
    // MARK: - Get User details  api
    func getUserDetails(userId: String) async throws -> GetUserFullResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.getUserDetails))!
        print("getUserDetails  Api called")

        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "id": userId
            ],
            requiresAuth: true,
            responseType: GetUserFullResponse.self,
            retry: true
        )
    }
    
    // MARK: - Delete User   api
    func deleteUser(userId: String) async throws -> DeleteUserResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.deleteUser))!
        print("Delete User  Api called")

        return try await performRequest(
            url: url,
            method: "DELETE",
            body: [
                "id": userId
            ],
            requiresAuth: true,
            responseType: DeleteUserResponse.self,
            retry: true
        )
    }


}

struct RefreshTokenResponse: Codable {
    let access: String?
    let refresh: String?
}
