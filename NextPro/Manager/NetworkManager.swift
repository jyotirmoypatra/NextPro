//
//  NetworkManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//

import Foundation
import Network
import Combine

import SwiftUI
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
    
    // MARK: - Validate Email API

    func ValidateEmail(email: String) async throws -> ValidateEmailResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.validateEmail)
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "email": email
        ]

        print("Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Debug print
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Validate Email Response:\n\(jsonString)")
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
            let decoded = try JSONDecoder().decode(ValidateEmailResponseModel.self, from: data)

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
    
    
    
    
    // MARK: - Accept Aggremnt  API

    func AggremntAccept(userEmail: String,isAccepted: Bool) async throws -> AggremntResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.aggremntAccept)
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "email": userEmail,
            "is_aggrement_accepted": isAccepted
        ] as [String : Any]

        print("Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Debug print
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Validate Email Response:\n\(jsonString)")
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
            let decoded = try JSONDecoder().decode(AggremntResponseModel.self, from: data)

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
    
    
    // MARK: - Edit profile
    func EditUserProfileDetails(fullName: String, phone: String ,userId: String) async throws -> UserEditProfileResponse {

        let urlString = APIConfig.url(APIConfig.Endpoints.editUserProfile)
        print("🔗 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let params: [String: Any] = [
            "user_id" : userId,
            "full_name": fullName,
            "phone_number": phone
        ]

        print("📤 Edit Profile Params: \(params)")

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
            let decoded = try JSONDecoder().decode(UserEditProfileResponse.self, from: data)

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



struct InternetOverlayModifier: ViewModifier {
    @ObservedObject var network = NetworkManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if network.didCheckInternet && !network.hasInternet {
                NoInternetOverlayView(retryAction: {
                    network.checkInternet()
                })
                .transition(.opacity)
                .animation(.easeInOut, value: network.hasInternet)
                .zIndex(9999)
            }
        }
    }
}


struct NoInternetOverlayView: View {
    var retryAction: () -> Void

    var body: some View {
        ZStack {
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                //.frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
            
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Image(systemName: "wifi.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                Text("No Internet Connection")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)

                Text("Please check your internet and try again.")
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button(action: retryAction) {
                    HStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        Text("RETRY")
                            .font(.custom("Inter-Bold", size: 16))
                            
                       }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,12)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                    
                }
                .padding(.horizontal, 50)
            }
        }
    }
}


extension View {
    func internetOverlay() -> some View {
        self.modifier(InternetOverlayModifier())
    }
}

// add .internetOverlay to view for full screen no internet overaly


struct GlobalNetworkBanner: ViewModifier {
    @ObservedObject var network = NetworkManager.shared
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if network.didCheckInternet && !network.hasInternet {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("No Internet Connection")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: network.hasInternet)
            }
        }
    }
}

extension View {
    func networkBanner() -> some View {
        self.modifier(GlobalNetworkBanner())
    }
}

// add .networkBanner to view for banner no internet overaly
