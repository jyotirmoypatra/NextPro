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


func isPasswordValid(_ password: String) -> Bool {
    let lengthOK = password.count >= 8
    let upperOK  = password.range(of: "[A-Z]", options: .regularExpression) != nil
    let lowerOK  = password.range(of: "[a-z]", options: .regularExpression) != nil
    let numberOK = password.range(of: "[0-9]", options: .regularExpression) != nil
    let specialOK = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil

    return lengthOK && upperOK && lowerOK && numberOK && specialOK
}

 func isValidEmail(_ email: String) -> Bool {
    let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}

//extension String {
//    func formattedUSPhone() -> String {
//        // keep only digits
//        let digits = self.filter { $0.isNumber }
//        
//        if digits.count == 10 {
//            // (123) 456-7890
//            let area = digits.prefix(3)
//            let prefix = digits.dropFirst(3).prefix(3)
//            let line = digits.suffix(4)
//            return "(\(area)) \(prefix)-\(line)"
//        } else if digits.count == 11, digits.first == "1" {
//            // 1-234-567-8901
//            let country = digits.prefix(1)
//            let area = digits.dropFirst(1).prefix(3)
//            let prefix = digits.dropFirst(4).prefix(3)
//            let line = digits.suffix(4)
//            return "\(country)-(\(area)) \(prefix)-\(line)"
//        }
//        
//        return self  // fallback if not 10/11 digits
//    }
//}

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

func speakText(_ text: String) {
    SpeechManager.shared.speak(text)
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
