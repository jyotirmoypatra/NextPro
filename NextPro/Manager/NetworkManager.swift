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

    
    
    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case serverError(code: Int, message: String)
        case backend(message: String)
        case network(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
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
    
    
    //All API list
    
    // MARK: - LOGIN API
//    func login(email: String, password: String) async throws -> LoginResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.login)
//        print("Url:\(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
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
//        print("request param:\(params)")
//        request.httpBody = try JSONSerialization.data(withJSONObject: params)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("📥Login Response JSON:\n\(jsonString)")
//        }
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw URLError(.badServerResponse)
//        }
//
//        // Decode always
//        let decoded = try JSONDecoder().decode(LoginResponseModel.self, from: data)
//
//        // Backend returns 200 even for invalid login, so catch failure here
//        if decoded.status == false {
//            throw NSError(domain: "LoginError", code: 401, userInfo: [
//                NSLocalizedDescriptionKey: decoded.message
//            ])
//        }
//
//        return decoded
//    }
    
    
    // MARK: - LOGIN API
    func login(email: String, password: String) async throws -> LoginResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.login)
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "username": email,
            "password": password
        ]

        print("Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Debug print
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Login Response:\n\(jsonString)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // If server returns non-200 → throw useful error
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode normally
            let decoded = try JSONDecoder().decode(LoginResponseModel.self, from: data)

            // Backend returns 200 but status = false → manual error
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let error as APIError {
            throw error   // Our custom error
        } catch {
            // Other errors like no internet, timeout, etc.
            throw APIError.network(error.localizedDescription)
        }
    }


    

    // MARK: - Update Password API
//    func updatePassword(newPassword: String, confirmPassword: String , userName: String) async throws -> UpdatePasswordResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.updatePassword)
//
//            print("Url:\(urlString)")
//            guard let url = URL(string: urlString) else {
//                throw URLError(.badURL)
//            }
//             
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let params: [String: Any] = [
//                "username" : userName,
//                "new_password": newPassword,
//                "confirm_password": confirmPassword
//            ]
//            
//            print("request param:\(params)")
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥UpdatePAssword Response JSON:\n\(jsonString)")
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode always
//            let decoded = try JSONDecoder().decode(UpdatePasswordResponseModel.self, from: data)
//
//            // Backend returns 200 even for invalid login, so catch failure here
//            if decoded.status == false {
//                throw NSError(domain: "UpdatePasswordError", code: 401, userInfo: [
//                    NSLocalizedDescriptionKey: decoded.message
//                ])
//            }
//
//            return decoded
//        }
    
    
    func updatePassword(newPassword: String,
                        confirmPassword: String,
                        userName: String) async throws -> UpdatePasswordResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.updatePassword)
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params: [String: Any] = [
            "username" : userName,
            "new_password": newPassword,
            "confirm_password": confirmPassword
        ]

        print("Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Debug Response
            if let json = String(data: data, encoding: .utf8) {
                print("📥 Update Password Response:\n\(json)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle non-200 HTTP Codes (400, 404, 500...)
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode response
            let decoded = try JSONDecoder().decode(UpdatePasswordResponseModel.self, from: data)

            // Backend returns success = false even with 200
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }

    
    
       // MARK: - Device Details API
    func deviceDetails(accessToken: String) async throws -> DeviceDetailsResponse {

        let urlString = APIConfig.url(APIConfig.Endpoints.deviceDetails)
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        print("Url:\(urlString)")
        print("access token:\(accessToken)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Device Details Response:\n\(jsonString)")
        }

        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? 0

        let decoder = JSONDecoder()

       
        if (200...299).contains(statusCode) {
            if let success = try? decoder.decode(DeviceDetailsResponse.self, from: data) {
                return success
            }
        }

     
        if let errorResponse = try? decoder.decode(deviceDetailsErrorResponse.self, from: data) {
            throw NSError(
                domain: "APIError",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorResponse.detail]
            )
        }


        throw NSError(
            domain: "UnknownError",
            code: statusCode,
            userInfo: [NSLocalizedDescriptionKey: "Something went wrong. Please try again."]
        )
    }



    // MARK: - Forget password  API
//    func requestForgetPassword(email: String) async throws -> ForgetPasswordResponseModel {
//
//        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordRequest)
//            print("🔗 URL: \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                throw URLError(.badURL)
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let params = [
//                "email": email
//            ]
//
//            print("📤 Params: \(params)")
//
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Forget Password Response JSON:\n\(jsonString)")
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(ForgetPasswordResponseModel.self, from: data)
//
//            // Backend returns status: false for errors
//            if decoded.status == false {
//                throw NSError(domain: "ForgetPasswordError", code: 400, userInfo: [
//                    NSLocalizedDescriptionKey: decoded.message
//                ])
//            }
//
//            return decoded
//        }
    
    func requestForgetPassword(email: String) async throws -> ForgetPasswordResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordRequest)
        print("🔗 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "email": email
        ]
        print("📤 Params: \(params)")

        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Forget Password Response JSON:\n\(jsonString)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle non-200 responses
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode always
            let decoded = try JSONDecoder().decode(ForgetPasswordResponseModel.self, from: data)

            // Backend sometimes gives 200 with status=false
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }

    
    
    
    // // MARK: - verify otp
//    func requestVerifyOtp(email: String, otp: String) async throws -> ForgetPasswordOtpVerifyresponse {
//        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordOtpVerify)
//            print("🔗 URL: \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                throw URLError(.badURL)
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let params = [
//                "email": email,
//                "code" : otp
//            ]
//
//            print("📤 Params: \(params)")
//
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Verify otp Response JSON:\n\(jsonString)")
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(ForgetPasswordOtpVerifyresponse.self, from: data)
//
//            // Backend returns status: false for errors
//            if decoded.status == false {
//                throw NSError(domain: "VerifyOtpError", code: 400, userInfo: [
//                    NSLocalizedDescriptionKey: decoded.message
//                ])
//            }
//
//            return decoded
//        }
    
    
    func requestVerifyOtp(email: String, otp: String) async throws -> ForgetPasswordOtpVerifyresponse {

        let urlString = APIConfig.url(APIConfig.Endpoints.forgetPasswordOtpVerify)
        print("🔗 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "email": email,
            "code": otp
        ]

        print("📤 Params: \(params)")

        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Verify OTP Response JSON:\n\(jsonString)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle non-200 responses
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode response
            let decoded = try JSONDecoder().decode(ForgetPasswordOtpVerifyresponse.self, from: data)

            // Backend sometimes returns 200 with status=false
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let apiErr as APIError {
            throw apiErr
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }

    
    // MARK: - User PRofile Details
//    func UserProfileDetails(id:String) async throws -> UserProfileResponse {
//        let urlString = APIConfig.url(APIConfig.Endpoints.getUserProfileData)
//            print("🔗 URL: \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                throw URLError(.badURL)
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let params = [
//                "id": id,
//               
//            ]
//
//            print("📤 Params: \(params)")
//
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Profile details Response JSON:\n\(jsonString)")
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(UserProfileResponse.self, from: data)
//
//            // Backend returns status: false for errors
//            if decoded.status == false {
//                throw NSError(domain: "ProfileDetailsRequestError", code: 400, userInfo: [
//                    NSLocalizedDescriptionKey: decoded.message
//                ])
//            }
//
//            return decoded
//        }
    
    
    func UserProfileDetails(id: String) async throws -> UserProfileResponse {

        let urlString = APIConfig.url(APIConfig.Endpoints.getUserProfileData)
        print("🔗 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "id": id
        ]

        print("📤 Params: \(params)")

        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Profile Details Response JSON:\n\(jsonString)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle all HTTP errors 400 / 404 / 500 properly
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode response
            let decoded = try JSONDecoder().decode(UserProfileResponse.self, from: data)

            // Backend returns 200 with "status": false
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }

    
    // MARK: - profile img upload
//    func UploadProfileImage(userId: String , base64: String) async throws -> UploadProfileImgResponseModel {
//        let urlString = APIConfig.url(APIConfig.Endpoints.uploadProfilePic)
//            print("🔗 URL: \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                throw URLError(.badURL)
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let params = [
//                "user_id": userId,
//                "image": base64
//            ]
//
//            print("📤Upload img Params: \(params)")
//
//            request.httpBody = try JSONSerialization.data(withJSONObject: params)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📥 Upload Profile img Response JSON:\n\(jsonString)")
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
//            }
//
//            // Decode response
//            let decoded = try JSONDecoder().decode(UploadProfileImgResponseModel.self, from: data)
//
//            // Backend returns status: false for errors
//            if decoded.status == false {
//                throw NSError(domain: "UploadProfileImageError", code: 400, userInfo: [
//                    NSLocalizedDescriptionKey: decoded.message
//                ])
//            }
//
//            return decoded
//        }
    func UploadProfileImage(userId: String, base64: String) async throws -> UploadProfileImgResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.uploadProfilePic)
        print("🔗 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params: [String: Any] = [
            "user_id": userId,
            "image": base64
        ]

        print("📤 Upload Image Params: \(params)")

        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Upload Profile Image Response JSON:\n\(jsonString)")
            }

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle all HTTP errors
            guard (200...299).contains(http.statusCode) else {
                let message = extractErrorMessage(from: data) ?? "Something went wrong."
                throw APIError.serverError(code: http.statusCode, message: message)
            }

            // Decode success response
            let decoded = try JSONDecoder().decode(UploadProfileImgResponseModel.self, from: data)

            // Backend returns 200 with status=false
            if decoded.status == false {
                throw APIError.backend(message: decoded.message)
            }

            return decoded

        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.network(error.localizedDescription)
        }
    }

}



