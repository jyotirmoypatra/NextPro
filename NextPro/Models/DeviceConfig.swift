//
//  DeviceConfig.swift
//  NextPro
//
//  Central device configuration - used for onboarding and door operations
//

import Foundation

struct DeviceConfig: Identifiable {
    let id = UUID()
    let name: String
    let devSn: String
    let devMac: String
    let eKey: String
    
    // Check if this device matches a scanned serial number
    func matches(scannedSn: String) -> Bool {
        return devSn == scannedSn
    }
}

// MARK: - Device Configuration Manager
class DeviceConfigManager {
    static let shared = DeviceConfigManager()
    
    // Hardcoded device list - update this array with your devices
    let devices: [DeviceConfig] = [
        DeviceConfig(
            name: "TC434(Access control machine)",
            devSn: "4283847520",
            devMac: "d8:3b:da:36:53:62",
            eKey: "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000"
        ),
//        DeviceConfig(
//            name: "TC434(Access control machine)",
//            devSn: "4286749203",
//            devMac: "d8:3b:da:37:04:92",
//            eKey: "b7becb164c2ed80ccb349cebc403c89f000000000000000000000000000000001000"
//        ),
//        DeviceConfig(
//            name: "M230 (Access control machine)",
//            devSn: "4282705968",
//            devMac: "58:cf:79:1a:89:ce",
//            eKey: "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000"
//        ),
//        DeviceConfig(
//            name: "M230(Access control reader)",
//            devSn: "4282894706",
//            devMac: "58:cf:79:1d:f7:e6",
//            eKey: "97b4c368894a17be950800a8022b7a21000000000000000000000000000000001000"
//        ),
//        DeviceConfig(
//            name: "M230(Access control reader)",
//            devSn: "4285397402",
//            devMac: "58:cf:79:1b:0b:42",
//            eKey: "27f9462cca787604a57494c98290b42b000000000000000000000000000000001000"
//        ),
//        DeviceConfig(
//            name: "M230(Access control reader)",
//            devSn: "4287123590",
//            devMac: "58:cf:79:1a:c4:86",
//            eKey: "d8829cf1e861620e2d42b2f4af4fd4db000000000000000000000000000000001000"
//        ),
        DeviceConfig(
            name: "M230(Access control reader)",
            devSn: "4280125893",
            devMac: "58:cf:79:1a:8d:0e",
            eKey: "3ca884ca4f8d16e28199c11df14cfbcf000000000000000000000000000000001000"
        ),
        
//        DeviceConfig(
//            name: "BC220(Access control machine)",
//            devSn: "4282184653",
//            devMac: "a0:76:4e:5a:ae:a2",
//            eKey: "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000"
//        ),
//        DeviceConfig(
//            name: "BC220(Access control machine)",
//            devSn: "4281275348",
//            devMac: "A0:76:4E:5A:A8:22",
//            eKey: "dac22333fb812a482e773f646f3e538a000000000000000000000000000000001000"
//        ),
    ]
    
    private init() {
        print("📋 DeviceConfigManager initialized with \(devices.count) devices")
    }
    
    // MARK: - Find Device by Serial Number
    /// Find device configuration by serial number (used during BLE scan)
    func findDevice(bySn sn: String) -> DeviceConfig? {
        let device = devices.first { $0.devSn == sn }
        if let found = device {
            print("✅ Found device config for SN: \(sn) - \(found.name)")
        } else {
            print("⚠️ No device config found for SN: \(sn)")
        }
        return device
    }
    
    // MARK: - Find Device by MAC Address
    /// Find device configuration by MAC address
    func findDevice(byMac mac: String) -> DeviceConfig? {
        let device = devices.first { $0.devMac.lowercased() == mac.lowercased() }
        if let found = device {
            print("✅ Found device config for MAC: \(mac) - \(found.name)")
        } else {
            print("⚠️ No device config found for MAC: \(mac)")
        }
        return device
    }
    
    // MARK: - Get All Devices
    /// Get all configured devices
    func getAllDevices() -> [DeviceConfig] {
        return devices
    }
    
    // MARK: - Check if Device is Configured
    /// Check if a serial number is in our configuration
    func isDeviceConfigured(sn: String) -> Bool {
        return devices.contains { $0.devSn == sn }
    }
    
    // MARK: - Get Device Info
    /// Get device info for display
    func getDeviceInfo(bySn sn: String) -> String? {
        if let device = findDevice(bySn: sn) {
            return """
            Name: \(device.name)
            SN: \(device.devSn)
            MAC: \(device.devMac)
            eKey: \(device.eKey.prefix(20))...
            """
        }
        return nil
    }
}







