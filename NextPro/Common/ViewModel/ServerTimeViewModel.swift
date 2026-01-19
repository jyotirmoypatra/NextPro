////
////  LoginViewModel.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 17/11/25.
////
//
//
import Foundation
import Combine

//
//@MainActor
//class ServerTimeViewModel: ObservableObject {
//
//    @Published var localServerDate: Date?
//    @Published var localTimeZoneID: String?
//
//    @Published var errorMessage: String?
//    @Published var successFlag = false
//
//    let networkManager = NetworkManager.shared
//
//    func getTime() async {
//        guard networkManager.hasInternet else {
//            print("❌ No internet")
//            return
//        }
//
//        do {
//            let response = try await networkManager.serverTime()
//
//            guard
//                let serverDateTime = response.serverDateTime,
//                let serverTimeZoneID = response.serverTimezone,
//                let localTimeZoneID = response.localTimezone
//            else {
//                print("❌ Missing datetime or timezone fields")
//                return
//            }
//
//            // Store local timezone ONCE per fetch
//            self.localTimeZoneID = localTimeZoneID
//            
//            // 1️⃣ Parse server datetime using server_timezone
//            guard let serverDate = parseServerDate(
//                datetime: serverDateTime,
//                timezoneID: serverTimeZoneID
//            ) else {
//                print("❌ Failed to parse server datetime")
//                return
//            }
//
//            // 2️⃣ Convert to local_timezone
//            guard let localTimeZone = TimeZone(identifier: localTimeZoneID) else {
//                print("❌ Invalid local timezone:", localTimeZoneID)
//                return
//            }
//
//            let localSeconds =
//                TimeInterval(localTimeZone.secondsFromGMT(for: serverDate))
//
//            let localDate = serverDate.addingTimeInterval(localSeconds)
//
//            // 3️⃣ Store final value
//            self.localServerDate = localDate
//            self.successFlag = true
//
//            // Debug
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            formatter.timeZone = localTimeZone
//            print("🕒 Local Server Time (\(localTimeZoneID)):",
//                  formatter.string(from: localDate))
//
//        } catch {
//            print("❌ Error:", error.localizedDescription)
//        }
//    }
//
//    // MARK: - Server datetime parser (timezone-safe)
//
//    private func parseServerDate(
//        datetime: String,
//        timezoneID: String
//    ) -> Date? {
//
//        // Case 1: ISO8601 with Z or +HH:mm → timezone embedded
//        if datetime.contains("Z") || datetime.contains("+") {
//            let isoFormatter = ISO8601DateFormatter()
//            isoFormatter.formatOptions = [.withInternetDateTime]
//            return isoFormatter.date(from: datetime)
//        }
//
//        // Case 2: No timezone info → use server_timezone
//        guard let serverTimeZone = TimeZone(identifier: timezoneID) else {
//            print("❌ Invalid server timezone:", timezoneID)
//            return nil
//        }
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.timeZone = serverTimeZone
//
//        return formatter.date(from: datetime)
//    }
//}


@MainActor
class ServerTimeViewModel: ObservableObject {

    @Published var localServerDate: Date?
    @Published var localTimeZoneID: String?

    @Published var errorMessage: String?
    @Published var successFlag = false

    let networkManager = NetworkManager.shared

    func getTime() async {
        guard networkManager.hasInternet else {
            print("❌ No internet")
            return
        }

        do {
            let response = try await networkManager.serverTime()

            guard
                let serverDateTime = response.serverDateTime,
                let serverTimeZoneID = response.serverTimezone,
                let localTimeZoneID = response.localTimezone
            else {
                print("❌ Missing datetime or timezone fields")
                return
            }

            // Store timezone for later use (access window)
            self.localTimeZoneID = localTimeZoneID

            // ✅ Parse server datetime CORRECTLY
            guard let serverDate = parseServerDate(
                datetime: serverDateTime,
                timezoneID: serverTimeZoneID
            ) else {
                print("❌ Failed to parse server datetime")
                return
            }

            // ✅ DO NOT add secondsFromGMT
            // Just store the absolute Date
            self.localServerDate = serverDate
            self.successFlag = true

            // ✅ Format only for DEBUG / DISPLAY
            if let tz = TimeZone(identifier: localTimeZoneID) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = tz

                print("🕒 Local Server Time (\(localTimeZoneID)):",
                      formatter.string(from: serverDate))
            }

        } catch {
            print("❌ Error:", error.localizedDescription)
        }
    }

    // MARK: - Server datetime parser (correct)

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
