//
//  Extension.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/11/25.
//

import Foundation
import SwiftUI
import UIKit




extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

extension UIImage {

    func compressTo(maxKB: Int = 300) -> Data? {

        print("🔵================ IMAGE COMPRESSION START ================")
        print("📌 Target max size: \(maxKB) KB")

        let maxBytes = maxKB * 1024

        // STEP 0 — Original size
        guard let originalData = self.jpegData(compressionQuality: 1.0) else {
            print("❌ Original JPEG conversion failed")
            return nil
        }
        let originalKB = originalData.count / 1024
        print("📦 Original Size: \(originalKB) KB")

        // If already below target → return
        if originalData.count <= maxBytes {
            print("✅ Already smaller than target. Returning original.")
            return originalData
        }

        // STEP 1 — Resize ONCE (big impact, no loops)
        let maxDimension: CGFloat = 1024    // Large but safe size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension,
                             height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio,
                             height: maxDimension)
        }

        print("➡️ Resizing once to: \(Int(newSize.width)) x \(Int(newSize.height))")

        let resizedImage = resized(to: newSize) ?? self

        // STEP 2 — Try quality compress from 0.9 → 0.05
        var bestData: Data?
        var compression: CGFloat = 0.9

        while compression >= 0.05 {
            if let data = resizedImage.jpegData(compressionQuality: compression) {
                let kb = data.count / 1024
                print("🎚 Quality \(String(format: "%.2f", compression)) → \(kb) KB")

                bestData = data

                if data.count <= maxBytes {
                    print("🎉 SUCCESS: Size under target")
                    return data
                }
            }

            compression -= 0.1
        }

        // STEP 3 — Cannot reach target → return smallest data found
        if let finalData = bestData {
            let finalKB = finalData.count / 1024
            print("⚠️ Could not reach \(maxKB) KB. Returning smallest: \(finalKB) KB")
            print("🔵================ IMAGE COMPRESSION END =================\n")
            return finalData
        }

        print("❌ Failed to compress")
        return nil
    }



    func resized(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }


}


//func isPasswordValid(_ password: String) -> Bool {
//    let lengthOK = password.count >= 8
//    let upperOK  = password.range(of: "[A-Z]", options: .regularExpression) != nil
//    let lowerOK  = password.range(of: "[a-z]", options: .regularExpression) != nil
//    let numberOK = password.range(of: "[0-9]", options: .regularExpression) != nil
//    let specialOK = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
//
//    return lengthOK && upperOK && lowerOK && numberOK && specialOK
//}

extension String {
    /// iOS "smart punctuation" swaps typed " ' - for curly quotes / en dash, which the
    /// password rule doesn't allow — convert them back to the straight characters.
    var withStraightPunctuation: String {
        self.replacingOccurrences(of: "\u{201C}", with: "\"")
            .replacingOccurrences(of: "\u{201D}", with: "\"")
            .replacingOccurrences(of: "\u{2018}", with: "'")
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
    }
}

// Single source of truth for the password rule's user-facing text — keep in sync
// with the regex in `isPasswordValid` below.
let passwordSpecialCharactersText = #"! @ # $ % ^ & * ( ) _ + - = { } [ ] | \ : ; " ' < > , . ? /"#

let passwordPolicyMessage = """
Password must meet the following requirements:
• Minimum 8 and maximum 64 characters
• At least 1 uppercase letter (A–Z)
• At least 1 lowercase letter (a–z)
• At least 1 number (0–9)
• At least 1 special character (\(passwordSpecialCharactersText))
"""

/// 8–64 characters, with at least one uppercase, one lowercase, one digit and one
/// special character (any symbol typeable on a standard keyboard), and nothing
/// outside those character classes.
func isPasswordValid(_ password: String) -> Bool {
    let passwordRegex = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-={}\[\]|\\:;"'<>,.?/])[A-Za-z\d!@#$%^&*()_+\-={}\[\]|\\:;"'<>,.?/]{8,64}$"#
    return password.range(of: passwordRegex, options: .regularExpression) != nil
}

 func isValidEmail(_ email: String) -> Bool {
    let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}


extension String {
    
    func formattedUSPhone() -> String {
        let digits = self.filter { $0.isNumber }.prefix(10)
        let count = digits.count
        
        switch count {
            
        case 0...3:
            return String(digits)
            
        case 4...6:
            let area = digits.prefix(3)
            let prefix = digits.dropFirst(3)
            return "(\(area)) \(prefix)"
            
        default:
            let area = digits.prefix(3)
            let prefix = digits.dropFirst(3).prefix(3)
            let line = digits.dropFirst(6)
            return "(\(area)) \(prefix)-\(line)"
        }
    }
}

func loadHTML(_ fileName: String) -> String {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "html"),
       let html = try? String(contentsOf: url) {
        return html
    }
    return "<p>Failed to load \(fileName).html</p>"
}

func parseMQTTTime(_ value: Any?) -> Date? {
    if let date = value as? Date {
        return date
    }

    if let str = value as? String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: str)
    }

    return nil
}


extension String {
    
    /// Converts a date string to formatted display string
    /// Example: "2026-01-10T21:26" → "10 Jan 2026"
    /// .toFormattedDate(outputFormat: "yyyy")
    func toFormattedDateTime(
        inputFormat: String = "yyyy-MM-dd'T'HH:mm",
        outputFormat: String = "yyyy/MMM/dd"
    ) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: self) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        return outputFormatter.string(from: date)
    }
    
    func toFormattedDate(
        inputFormat: String = "yyyy-MM-dd",
        outputFormat: String = "yyyy/MMM/dd"
    ) -> String {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: self) else {
            return ""
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        return outputFormatter.string(from: date)
    }

}

extension Notification.Name {
    static let deviceHeartbeatReceived = Notification.Name("deviceHeartbeatReceived")
}


extension Date {
    func toReadableString(
        format: String = "dd MMM yyyy, hh:mm a",
        timeZoneID: String? = nil
    ) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let id = timeZoneID,
           let tz = TimeZone(identifier: id) {
            formatter.timeZone = tz
        }

        return formatter.string(from: self)
    }
}

func speakText(_ text: String, onFinish: (() -> Void)? = nil) {
    SpeechManager.shared.speak(text, onFinish: onFinish)
}


extension Date {

    /// yyyy-MM-dd (example: 2026-02-10)
    func toAPIDate() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    /// HH:mm (example: 14:30)
    func toAPITime() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}


extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else {
            throw NSError(
                domain: "EncodingError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert model to dictionary"]
            )
        }
        return dict
    }
}


extension Notification.Name {
    static let roleChanged = Notification.Name("roleChanged")
}

extension Notification.Name {
    static let accessFlagsChanged = Notification.Name("accessFlagsChanged")
}


// MARK: - App Version
// Single source of truth for the displayed app version string, so SplashScreen and the
// Profile "App Version" row can never drift out of sync with each other.
extension APIConfig {
    static var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        guard !version.isEmpty else { return "" }

        switch environment {
        case .development, .staging:
            return build.isEmpty
                ? "Version \(version)"
                : "Version \(version) (\(build))"

        case .production:
            return "Version \(version)"
        }
    }
}


struct CountryOption: Identifiable {
    let id: String
    let name: String
    let dialingCode: String

    init(id: String, name: String, dialingCode: String) {
        self.id = id
        self.name = name
        self.dialingCode = dialingCode
    }

    init(country: Country) {
        id = country.code
        name = country.name
        dialingCode = country.dialCode
    }

    var flag: String {
        let base: UInt32 = 127397
        let scalars = id.uppercased().unicodeScalars
        guard scalars.count == 2,
              scalars.allSatisfy({ $0.value >= 65 && $0.value <= 90 }) else {
            return ""
        }
        let flagScalars = scalars.compactMap { UnicodeScalar(base + $0.value) }
        return String(String.UnicodeScalarView(flagScalars))
    }

}

extension CountryOption {
    static var supportedCountries: [CountryOption] {
        guard let data = UserDefaults.standard.data(forKey: CountryListViewModel.countriesCacheKey),
              let countries = try? JSONDecoder().decode([Country].self, from: data) else {
            return [CountryOption(id: "", name: "", dialingCode: "")]
        }
        return countries.map(CountryOption.init(country:))
    }

    static func matchingCountry(for countryCode: String) -> CountryOption? {
        matchingCountry(for: countryCode, in: supportedCountries)
    }

    static func matchingCountry(for countryCode: String, in countries: [CountryOption]) -> CountryOption? {
        let normalizedCountryCode = countryCode.filter { $0.isNumber }

        return countries.first {
            $0.id.caseInsensitiveCompare(countryCode) == .orderedSame ||
            $0.dialingCode == countryCode ||
            $0.dialingCode.filter { $0.isNumber } == normalizedCountryCode
        }
    }
}
