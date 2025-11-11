//
//  WiFiConfigurator.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import Foundation


class WiFiConfigurator {
    static func configureDeviceWiFi(
        deviceSN: String,
        wifiName: String,
        wifiPassword: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        print("🔧 ========================================")
        print("🔧 WiFi Configuration Started")
        print("🔧 ========================================")
        print("🔧 Looking up device config for SN: \(deviceSN)")
        
        // Get device config from DeviceConfigManager
        guard let deviceConfig = DeviceConfigManager.shared.findDevice(bySn: deviceSN) else {
            print("❌ Device not found in configuration!")
            completion(false, "❌ Device \(deviceSN) not configured. Please add to DeviceConfig.swift")
            return
        }
        
        print("✅ Found device: \(deviceConfig.name)")
        print("   SN: \(deviceConfig.devSn)")
        print("   MAC: \(deviceConfig.devMac)")
        print("   eKey: \(deviceConfig.eKey.prefix(20))...")
        
        let devModel = LibDevModel()
        devModel.devSn = deviceConfig.devSn
        devModel.devMac = deviceConfig.devMac
        devModel.eKey = deviceConfig.eKey
        devModel.devType = 2    // set from docs / device type

        // Change IP & port to match your actual server
        let ip = "13.223.139.54"
        let port = 6010

        let ret = LibDevModel.configWiFi(
            devModel,
            ipAddress: ip,
            port: Int32(port),
            wiFiName: wifiName,
            wiFiPwd: wifiPassword
        ) { retCode, msgDict in
            DispatchQueue.main.async {
                print("📥 ========================================")
                print("📥 WiFi Config Callback Received")
                print("📥 Return Code: \(retCode)")
                print("📥 Message Dict: \(msgDict ?? [:])")
                print("📥 ========================================")
                
                if retCode == 0 {
                    print("✅ SUCCESS: Wi-Fi configured successfully!")
                    completion(true, "✅ Wi-Fi configured successfully.")
                } else {
                    // Map error codes
                    var errorMsg = ""
                    switch retCode {
                    case 1:
                        errorMsg = "Timeout - device not responding"
                    case 2:
                        errorMsg = "Device not found nearby"
                    case 3:
                        errorMsg = "Connection failed"
                    case 4:
                        errorMsg = "Authentication failed - check eKey"
                    case 5:
                        errorMsg = "Invalid parameters"
                    case 11:
                        errorMsg = "Configuration rejected - check MAC/eKey match"
                    default:
                        errorMsg = "Error code: \(retCode)"
                    }
                    
                    print("❌ FAILED: \(errorMsg)")
                    completion(false, "❌ Wi-Fi config failed. \(errorMsg)")
                }
            }
        }
        
        print("📤 ========================================")
        print("📤 configWiFi() RESULT: \(ret)")
        print("📤 ========================================")

        if ret != 0 {
            print("❌ Failed to start WiFi configuration")
            completion(false, "❌ Failed to start configuration. Code: \(ret)")
        } else {
            print("⏳ Waiting for device callback...")
        }
    }
}
