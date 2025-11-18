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

          guard let url = URL(string: urlString) else {
              throw URLError(.badURL)
          }
           
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           let params = [
               "email": email,
               "password": password
           ]

           print("request param:\(params)")
           request.httpBody = try JSONSerialization.data(withJSONObject: params)
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")

           let (data, response) = try await URLSession.shared.data(for: request)

           guard let httpResponse = response as? HTTPURLResponse,
                 (200...299).contains(httpResponse.statusCode) else {
               throw URLError(.badServerResponse)
           }

           let decoded = try JSONDecoder().decode(LoginResponseModel.self, from: data)
           return decoded
       }
    
    // MARK: - Update Password API
    func updatePassword(newPassword: String, confirmPassword: String) async throws -> UpdatePasswordResponseModel {

            guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.updatePassword) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let params: [String: Any] = [
                "newPassword": newPassword,
                "confirmPassword": confirmPassword
            ]
            
            print("request param:\(params)")
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(UpdatePasswordResponseModel.self, from: data)
        }
    
}
