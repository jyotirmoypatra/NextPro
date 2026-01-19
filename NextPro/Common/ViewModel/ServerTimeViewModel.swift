//////
//////  LoginViewModel.swift
//////  NextPro
//////
//////  Created by JYOTIRMOY PATRA on 17/11/25.
//////
////
////
//import Foundation
//import Combine
//
//
//
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
//            // Store timezone for later use (access window)
//            self.localTimeZoneID = localTimeZoneID
//
//            // ✅ Parse server datetime CORRECTLY
//            guard let serverDate = parseServerDate(
//                datetime: serverDateTime,
//                timezoneID: serverTimeZoneID
//            ) else {
//                print("❌ Failed to parse server datetime")
//                return
//            }
//
//            // ✅ DO NOT add secondsFromGMT
//            // Just store the absolute Date
//            self.localServerDate = serverDate
//            self.successFlag = true
//
//            // ✅ Format only for DEBUG / DISPLAY
//            if let tz = TimeZone(identifier: localTimeZoneID) {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                formatter.timeZone = tz
//
//                print("🕒 Local Server Time (\(localTimeZoneID)):",
//                      formatter.string(from: serverDate))
//            }
//
//        } catch {
//            print("❌ Error:", error.localizedDescription)
//        }
//    }
//
//    // MARK: - Server datetime parser (correct)
//
//    private func parseServerDate(
//        datetime: String,
//        timezoneID: String
//    ) -> Date? {
//
//        // ISO8601 with Z or offset → timezone embedded
//        if datetime.contains("Z") || datetime.contains("+") {
//            let isoFormatter = ISO8601DateFormatter()
//            isoFormatter.formatOptions = [.withInternetDateTime]
//            return isoFormatter.date(from: datetime)
//        }
//
//        // No timezone in string → apply server_timezone
//        guard let serverTZ = TimeZone(identifier: timezoneID) else {
//            print("❌ Invalid server timezone:", timezoneID)
//            return nil
//        }
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        formatter.timeZone = serverTZ
//
//        return formatter.date(from: datetime)
//    }
//}
