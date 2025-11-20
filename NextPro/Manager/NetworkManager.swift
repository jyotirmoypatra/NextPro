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
    
    
    //All API list
    
    // MARK: - LOGIN API
    func login(email: String, password: String) async throws -> LoginResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.login)
        print("Url:\(urlString)")

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
           
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let params = [
            "username": email,
            "password": password
        ]

        print("request param:\(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥Login Response JSON:\n\(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Decode always
        let decoded = try JSONDecoder().decode(LoginResponseModel.self, from: data)

        // Backend returns 200 even for invalid login, so catch failure here
        if decoded.status == false {
            throw NSError(domain: "LoginError", code: 401, userInfo: [
                NSLocalizedDescriptionKey: decoded.message
            ])
        }

        return decoded
    }

    
    // MARK: - Update Password API
    func updatePassword(newPassword: String, confirmPassword: String , userName: String) async throws -> UpdatePasswordResponseModel {

        let urlString = APIConfig.url(APIConfig.Endpoints.updatePassword)

            print("Url:\(urlString)")
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
             
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let params: [String: Any] = [
                "username" : userName,
                "new_password": newPassword,
                "confirm_password": confirmPassword
            ]
            
            print("request param:\(params)")
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥UpdatePAssword Response JSON:\n\(jsonString)")
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            // Decode always
            let decoded = try JSONDecoder().decode(UpdatePasswordResponseModel.self, from: data)

            // Backend returns 200 even for invalid login, so catch failure here
            if decoded.status == false {
                throw NSError(domain: "LoginError", code: 401, userInfo: [
                    NSLocalizedDescriptionKey: decoded.message
                ])
            }

            return decoded
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



    
}
