//
//  ServerTimeService.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 19/01/26.
//


import Foundation
import Combine

@MainActor
final class ServerTimeService: ObservableObject {

    static let shared = ServerTimeService()

    @Published private(set) var localServerDate: Date?
    @Published private(set) var localTimeZoneID: String?

    private let networkManager = NetworkManager.shared
    private var pollingTask: Task<Void, Never>?

    private init() {}
}


extension ServerTimeService {
    func start(forceImmediate: Bool = false) {
        guard pollingTask == nil else { return }

        pollingTask = Task(priority: .userInitiated) {

            if forceImmediate {
                print("Server Time Fetch Immidiatly")
                await fetchTime()   // immediate refresh
            }

            //  Fast retry ONLY if no value yet
            while !Task.isCancelled && localServerDate == nil {
                await fetchTime()
                try? await Task.sleep(nanoseconds: 500_000_000)
            }

            // ⏱ Normal polling
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await fetchTime()
            }
        }

        print("🟢 ServerTimeService started (forceImmediate: \(forceImmediate))")
    }


    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
        print("🔴 ServerTimeService stopped")
    }

    private func fetchTime() async {
        guard networkManager.hasInternet else { return }
        
        // ✅ If user not logged in, don't even try
            guard let token = KeychainManager.shared.get("access_token"),
                  !token.isEmpty else {
               // print("⛔️ No access token. Skipping server time fetch.")
                return
            }

        do {
            let response = try await networkManager.serverTime()

            guard
                let serverDateTime = response.serverDateTime,
                let serverTimeZoneID = response.serverTimezone,
                let localTimeZoneID = response.localTimezone
            else { return }

            self.localTimeZoneID = localTimeZoneID

            guard let serverDate = parseServerDate(
                datetime: serverDateTime,
                timezoneID: serverTimeZoneID
            ) else { return }

            self.localServerDate = serverDate
            
            //store system uptime with server time to local
            let uptime = ProcessInfo.processInfo.systemUptime
            UserDefaults.standard.set(serverDate.timeIntervalSince1970, forKey: "server_time_epoch")
            UserDefaults.standard.set(uptime, forKey: "server_time_uptime")
            
            if let tz = TimeZone(identifier: localTimeZoneID) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = tz

                print("🕒 Local Server Time (\(localTimeZoneID)):",
                      formatter.string(from: serverDate))
            }

        } catch {
            print("❌ Server time error:", error.localizedDescription)
        }
    }
    
    private func parseServerDate(
        datetime: String,
        timezoneID: String
    ) -> Date? {

        // ISO8601 with Z or offset → timezone embedded
        if datetime.contains("Z") || datetime.contains("+") {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]
            return isoFormatter.date(from: datetime)
        }

        // No timezone in string → apply server_timezone
        guard let serverTZ = TimeZone(identifier: timezoneID) else {
            print("❌ Invalid server timezone:", timezoneID)
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = serverTZ

        return formatter.date(from: datetime)
    }
    
    func getEstimatedServerTime() -> Date? {
        print("──────── SERVER TIME ESTIMATION ────────")
        
        if networkManager.hasInternet {
            return localServerDate
        }
        
        print("📴 Offline mode — estimating server time")
        let defaults = UserDefaults.standard
        
        let savedServerEpoch = defaults.double(forKey: "server_time_epoch")
        let savedUptime = defaults.double(forKey: "server_time_uptime")
        
        
        print("💾 Saved Server Epoch:", savedServerEpoch)
           print("💾 Saved Uptime:", savedUptime)
        guard savedServerEpoch > 0, savedUptime > 0 else {
            return nil
        }
        
        let currentUptime = ProcessInfo.processInfo.systemUptime
        
        // Detect device restart
        if currentUptime < savedUptime {
            return nil
        }
        
        let elapsed = currentUptime - savedUptime
        
        // 4 hour limit
       // if elapsed > 14400 {
        if elapsed > 120 {
            return nil
        }
        
        let estimatedEpoch = savedServerEpoch + elapsed
        let estimatedDate = Date(timeIntervalSince1970: estimatedEpoch)
        print("🕒 Estimated Server Time:", estimatedDate)
           print("──────── ESTIMATION COMPLETE ────────")
        
        return Date(timeIntervalSince1970: estimatedEpoch)
    }
}
