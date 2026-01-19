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
}
