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

        print("\(url)")
        print("\(body)")
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

//    func ValidateEmail(email: String) async throws -> ValidateEmailResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.validateEmail)
//        print("URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "email": email
//        ]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug print
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Validate Email Response:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // If server returns non-200 → throw useful error
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode normally
//            let decoded = try JSONDecoder().decode(ValidateEmailResponseModel.self, from: data)
//
//            // Backend returns 200 but status = false → manual error
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error   // Our custom error
//        } catch {
//            // Other errors like no internet, timeout, etc.
//            throw APIError.network(error.localizedDescription)
//        }
//    }
    
    
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

//    func AggremntAccept(userEmail: String,isAccepted: Bool) async throws -> AggremntResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.aggremntAccept)
//        print("URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "email": userEmail,
//            "is_aggrement_accepted": isAccepted
//        ] as [String : Any]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug print
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Validate Email Response:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // If server returns non-200 → throw useful error
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode normally
//            let decoded = try JSONDecoder().decode(AggremntResponseModel.self, from: data)
//
//            // Backend returns 200 but status = false → manual error
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error   // Our custom error
//        } catch {
//            // Other errors like no internet, timeout, etc.
//            throw APIError.network(error.localizedDescription)
//        }
//    }
    
    
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
//    func login(email: String, password: String) async throws -> LoginResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.login)
//        print("URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "username": email,
//            "password": password
//        ]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug print
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Login Response:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // If server returns non-200 → throw useful error
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode normally
//            let decoded = try JSONDecoder().decode(LoginResponseModel.self, from: data)
//
//            // Backend returns 200 but status = false → manual error
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error   // Our custom error
//        } catch {
//            // Other errors like no internet, timeout, etc.
//            throw APIError.network(error.localizedDescription)
//        }
//    }


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

    
//    func updatePassword(newPassword: String,
//                        confirmPassword: String,
//                        userName: String) async throws -> UpdatePasswordResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.updatePassword)
//        print("URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params: [String: Any] = [
//            "username" : userName,
//            "new_password": newPassword,
//            "confirm_password": confirmPassword
//        ]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug Response
//            if let json = String(data: data, encoding: .utf8) {
//                print("📥 Update Password Response:\n\(json)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 HTTP Codes (400, 404, 500...)
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(UpdatePasswordResponseModel.self, from: data)
//
//            // Backend returns success = false even with 200
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }

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
//    func deviceDetails(userID: String) async throws -> DeviceDetailsResponse {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.deviceDetails)
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        print("URL: \(urlString)")
//        
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//                  !accessToken.isEmpty else {
//                throw APIError.unAuthorized
//            }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params: [String: Any] = [
//            "user_id" : userID,
//        ]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        //Bearer token header
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug Response
//            if let json = String(data: data, encoding: .utf8) {
//                print("📥 Device Details Response:\n\(json)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 HTTP Codes (400, 404, 500...)
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(DeviceDetailsResponse.self, from: data)
//
//            // Backend returns success = false even with 200
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message ?? "Something went wrong!")
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error
//        } catch {
//            print("❌ ERROR REASON:", error)
//               print("❌ LOCALIZED DESCRIPTION:", error.localizedDescription)
//            throw APIError.network(error.localizedDescription)
//        }
//    }

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

//    func requestForgetPassword(email: String) async throws -> ForgetPasswordResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordRequest)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "email": email
//        ]
//        print("📤 Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Forget Password Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 responses
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode always
//            let decoded = try JSONDecoder().decode(ForgetPasswordResponseModel.self, from: data)
//
//            // Backend sometimes gives 200 with status=false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let err as APIError {
//            throw err
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }

    
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
//    func requestVerifyOtp(email: String, otp: String) async throws -> ForgetPasswordOtpVerifyresponse {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordOtpVerify)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "email": email,
//            "code": otp
//        ]
//
//        print("📤 Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Verify OTP Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 responses
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(ForgetPasswordOtpVerifyresponse.self, from: data)
//
//            // Backend sometimes returns 200 with status=false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let apiErr as APIError {
//            throw apiErr
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }

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
//    func UserProfileDetails(id: String) async throws -> UserProfileResponse {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.getUserProfileData)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//        
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//                  !accessToken.isEmpty else {
//                throw APIError.unAuthorized
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params = [
//            "id": id
//        ]
//
//        print("📤 Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Profile Details Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle all HTTP errors 400 / 404 / 500 properly
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(UserProfileResponse.self, from: data)
//
//            // Backend returns 200 with "status": false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let apiError as APIError {
//            throw apiError
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }

    func UserProfileDetails(id: String) async throws -> UserProfileResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.getUserProfileData))!
        print("UserProfile details Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "id": id
            ],
            requiresAuth: true,
            responseType: UserProfileResponse.self,
            retry: true
        )
    }

    
    // MARK: - profile img upload
//    func UploadProfileImage(userId: String, base64: String) async throws -> UploadProfileImgResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.uploadProfilePic)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//        
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//                  !accessToken.isEmpty else {
//                throw APIError.unAuthorized
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params: [String: Any] = [
//            "user_id": userId,
//            "image": base64
//        ]
//
//        print("📤 Upload Image Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Upload Profile Image Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle all HTTP errors
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode success response
//            let decoded = try JSONDecoder().decode(UploadProfileImgResponseModel.self, from: data)
//
//            // Backend returns 200 with status=false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let apiError as APIError {
//            throw apiError
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }
    
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
//    func EditUserProfileDetails(fullName: String, phone: String ,userId: String) async throws -> UserEditProfileResponse {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.editUserProfile)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//                  !accessToken.isEmpty else {
//                throw APIError.unAuthorized
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//
//        let params: [String: Any] = [
//            "user_id" : userId,
//            "full_name": fullName,
//            "phone_number": phone
//        ]
//
//        print("📤 Edit Profile Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Upload Profile Image Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle all HTTP errors
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode success response
//            let decoded = try JSONDecoder().decode(UserEditProfileResponse.self, from: data)
//
//            // Backend returns 200 with status=false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let apiError as APIError {
//            throw apiError
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }
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
//    func AssignDeviceList(userID: String) async throws -> AssignDeviceListResponse {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.adminAssignDeviceList)
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        print("URL: \(urlString)")
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params: [String: Any] = [
//            "user_id" : userID,
//        ]
//
//        print("Request Params: \(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug Response
//            if let json = String(data: data, encoding: .utf8) {
//                print("📥 Device Details Response:\n\(json)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 HTTP Codes (400, 404, 500...)
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(AssignDeviceListResponse.self, from: data)
//
//            // Backend returns success = false even with 200
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message ?? "Something went wrong!")
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error
//        } catch {
//            print("❌ ERROR REASON:", error)
//               print("❌ LOCALIZED DESCRIPTION:", error.localizedDescription)
//            throw APIError.network(error.localizedDescription)
//        }
//    }
    
//    func AssignDeviceList(
//        userID: String,
//        page: Int = 1,
//        pageSize: Int = 10
//    ) async throws -> AssignDeviceListResponse {
//
//        let baseURL = APIConfig.url(APIConfig.Endpoints.adminAssignDeviceList)
//
//        guard var components = URLComponents(string: baseURL) else {
//            throw APIError.invalidURL
//        }
//
//        // ✅ Query parameters
//        components.queryItems = [
//            URLQueryItem(name: "user_id", value: userID),
//            URLQueryItem(name: "page", value: "\(page)"),
//            URLQueryItem(name: "page_size", value: "\(pageSize)")
//        ]
//
//        guard let url = components.url else {
//            throw APIError.invalidURL
//        }
//
//        print("🌐 GET URL:", url.absoluteString)
//
//        // ✅ Get token from Keychain
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//              !accessToken.isEmpty else {
//            throw APIError.unAuthorized
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        // ✅ Bearer token header
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            // Debug raw response
//            if let json = String(data: data, encoding: .utf8) {
//                print("📥 Assign Device List Response:\n\(json)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle HTTP errors
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            let decoded = try JSONDecoder().decode(AssignDeviceListResponse.self, from: data)
//
//            // Backend-level error
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let error as APIError {
//            throw error
//        } catch {
//            print("❌ ERROR:", error.localizedDescription)
//            throw APIError.network(error.localizedDescription)
//        }
//    }

//    func AssignDeviceList(userID: String) async throws -> AssignDeviceListResponse {
//
//        let url = URL(string: APIConfig.url(APIConfig.Endpoints.adminAssignDeviceList))!
//
//        return try await performRequest(
//            url: url,
//            method: "POST",
//            body: [
//                "user_id": userID
//            ],
//            responseType: AssignDeviceListResponse.self
//        )
//    }

    
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


    
//    func successDeviceConfig(userId:String,isSuccess: Bool, deviceSerial:String,ssid:String,password:String) async throws -> successDeviceConfigResposne {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.successWifiConfig)
//        print("🔗 URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw APIError.invalidURL
//        }
//
//        guard let accessToken = KeychainManager.shared.get("access_token"),
//                  !accessToken.isEmpty else {
//                throw APIError.unAuthorized
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let params:[String: Any] = [
//            "user_id" : userId,
//            "device_serial" :  deviceSerial,
//            "wifi_ssid_name" : ssid,
//            "wifi_password": password,
//            "is_configured": isSuccess,
//            
//        ]
//        print("📤 Params: \(params)")
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Success Wifi Config Response JSON:\n\(jsonString)")
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                throw APIError.invalidResponse
//            }
//
//            // Handle non-200 responses
//            guard (200...299).contains(http.statusCode) else {
//                let message = extractErrorMessage(from: data) ?? "Something went wrong."
//                throw APIError.serverError(code: http.statusCode, message: message)
//            }
//
//            // Decode always
//            let decoded = try JSONDecoder().decode(successDeviceConfigResposne.self, from: data)
//
//            // Backend sometimes gives 200 with status=false
//            if decoded.status == false {
//                throw APIError.backend(message: decoded.message)
//            }
//
//            return decoded
//
//        } catch let err as APIError {
//            throw err
//        } catch {
//            throw APIError.network(error.localizedDescription)
//        }
//    }

    func successDeviceConfig(
        userId: String,
        isSuccess: Bool,
        deviceSerial: String,
        ssid: String,
        password: String
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
                "is_configured": isSuccess
            ],
            requiresAuth: true,
            responseType: successDeviceConfigResposne.self,
            retry: true
        )
    }
    
    
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

    
    func fetchUserList(
        userId: String,
    ) async throws -> UsersResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.fetchUsersList))!
        print("SuccessConfig wifi Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userId,
                "source" : "app"
                
            ],
            requiresAuth: true,
            responseType: UsersResponse.self,
            retry: true
        )
    }
    
    func addNewUser(
        userId: String,
    ) async throws -> UsersResponse {

        let url = URL(string: APIConfig.url(APIConfig.Endpoints.addNewUser))!
        print("SuccessConfig wifi Api called----")
        return try await performRequest(
            url: url,
            method: "POST",
            body: [
                "user_id": userId,
                
            ],
            requiresAuth: true,
            responseType: UsersResponse.self,
            retry: true
        )
    }
    
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


}

struct RefreshTokenResponse: Codable {
    let access: String?
    let refresh: String?
}
