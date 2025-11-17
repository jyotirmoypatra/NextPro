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
}
