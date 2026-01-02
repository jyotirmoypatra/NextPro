//
//  WiFiConfigurator.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import Foundation


//class WiFiConfigurator {
//    static func configureDeviceWiFi(
//        deviceSN: String,
//        wifiName: String,
//        wifiPassword: String,
//        deviceModel:String,
//        completion: @escaping (Bool, String) -> Void
//    ) {
//        print("🔧 ========================================")
//        print("🔧 WiFi Configuration Started")
//        print("🔧 ========================================")
//        print("🔧 Looking up device config for SN: \(deviceSN)")
//        
//        // Get device config from DeviceConfigManager
//        guard let deviceConfig = DeviceConfigManager.shared.findDevice(bySn: deviceSN) else {
//            print("❌ Device not found in configuration!")
//            completion(false, "❌ Device \(deviceSN) not configured. Please add to DeviceConfig.swift")
//            return
//        }
//        
//        print("✅ Found device: \(deviceConfig.name)")
//        print("   SN: \(deviceConfig.devSn)")
//        print("   MAC: \(deviceConfig.devMac)")
//        print("   eKey: \(deviceConfig.eKey.prefix(20))...")
//        
//        let devModel = LibDevModel()
//        devModel.devSn = deviceConfig.devSn
//        devModel.devMac = deviceConfig.devMac
//        devModel.eKey = deviceConfig.eKey
//        devModel.devType = 13    // set from docs / device type
//
//        // Change IP & port to match your actual server
//        let ip = "13.223.139.54"
//        let port = 6010
//
//        let ret = LibDevModel.configWiFi(
//            devModel,
//            ipAddress: ip,
//            port: Int32(port),
//            wiFiName: wifiName,
//            wiFiPwd: wifiPassword
//        ) { retCode, msgDict in
//            DispatchQueue.main.async {
//                print("📥 ========================================")
//                print("📥 WiFi Config Callback Received")
//                print("📥 Return Code: \(retCode)")
//                print("📥 Message Dict: \(msgDict ?? [:])")
//                print("📥 ========================================")
//                
//                if retCode == 0 {
//                    print("✅ SUCCESS: Wi-Fi configured successfully!")
//                    completion(true, "✅ Wi-Fi configured successfully.")
//                } else {
//                    // Map error codes
//                    var errorMsg = ""
//                    switch retCode {
//                    case 1:
//                        errorMsg = "Timeout - device not responding"
//                    case 2:
//                        errorMsg = "Device not found nearby"
//                    case 3:
//                        errorMsg = "Connection failed"
//                    case 4:
//                        errorMsg = "Authentication failed - check eKey"
//                    case 5:
//                        errorMsg = "Invalid parameters"
//                    case 11:
//                        errorMsg = "Configuration rejected - check MAC/eKey match"
//                    default:
//                        errorMsg = "Error code: \(retCode)"
//                    }
//                    
//                    print("❌ FAILED: \(errorMsg)")
//                    completion(false, "❌ Wi-Fi config failed. \(errorMsg)")
//                }
//            }
//        }
//        
//        print("📤 ========================================")
//        print("📤 configWiFi() RESULT: \(ret)")
//        print("📤 ========================================")
//
//        if ret != 0 {
//            print("❌ Failed to start WiFi configuration")
//            completion(false, "❌ Failed to start configuration. Code: \(ret)")
//        } else {
//            print("⏳ Waiting for device callback...")
//        }
//    }
//}

//
//  WiFiConfigurator.swift
//  NextPro
//

import Foundation

class WiFiConfigurator {

    static func configureDeviceWiFi(
        deviceSN: String,
        wifiName: String,
        wifiPassword: String,
        deviceModel: String,
        completion: @escaping (Bool, String) -> Void
    ) {

        print("🔧 ========================================")
        print("🔧 WiFi Configuration Started")
        print("🔧 ========================================")

        guard let deviceConfig = DeviceConfigManager.shared.findDevice(bySn: deviceSN) else {
            completion(false, "❌ Device not configured")
            return
        }

        print("✅ Found device:", deviceConfig.name)
        print("   SN:", deviceConfig.devSn)
        print("   MAC:", deviceConfig.devMac)
        print("   eKey:", deviceConfig.eKey.prefix(20), "...")

        let devModel = LibDevModel()
        devModel.devSn  = deviceConfig.devSn
        devModel.devMac = deviceConfig.devMac
        devModel.eKey   = deviceConfig.eKey
        devModel.devType = 13   // keep as-is

        let serverIP = "13.223.139.54"
        let serverPort = 6010

        let isTCDevice = deviceModel.uppercased().hasPrefix("TC")


        // TC DEVICE FLOW (STRICT SEQUENTIAL)
        // =====================================================
        if isTCDevice {

            print("📡 TC device detected → setting Server IP first")

            let startRet = LibDevModel.setServerIP(
                devModel,
                andServerIP: serverIP,
                andServerPort: Int32(serverPort)
            ) { serverRet, serverMsg in

                print("📥 setServerIP callback")
                print("   ret:", serverRet)
                print("   msg:", serverMsg ?? [:])

                // ❌ STOP if server IP failed
                guard serverRet == 0 else {
                    completion(false, "❌ Server IP set failed (code \(serverRet))")
                    return
                }

                print("✅ Server IP set successfully")
                print("⏳ Waiting 5 seconds before configuring Host WiFi")

                // ✅ DELAY 5 SECONDS BEFORE WIFI CONFIG
                let wifiWorkItem = DispatchWorkItem {

                    print("📶 Now configuring Host WiFi")

                    let wifiStartRet = LibDevModel.configHostWifi(
                        devModel,
                        wiFiName: wifiName,
                        wiFiPwd: wifiPassword
                    ) { wifiRet, wifiMsg in

                        print("📥 configHostWifi callback")
                        print("   ret:", wifiRet)
                        print("   msg:", wifiMsg ?? [:])

                        if wifiRet == 0 {
                            completion(true, "✅ TC device WiFi configured successfully")
                        } else {
                            completion(false, "❌ TC WiFi config failed (code \(wifiRet))")
                        }
                    }

                    if wifiStartRet != 0 {
                        completion(false, "❌ Failed to start WiFi config (code \(wifiStartRet))")
                    }
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 5.0,
                    execute: wifiWorkItem
                )
            }

            if startRet != 0 {
                completion(false, "❌ Failed to start server IP config (code \(startRet))")
            }

            return
        }



        //  NON-TC DEVICES (BC220 Device or standalone all in one)
        // =====================================================
        print("📡 Non-TC device → using configWiFi")

        let ret = LibDevModel.configWiFi(
            devModel,
            ipAddress: serverIP,
            port: Int32(serverPort),
            wiFiName: wifiName,
            wiFiPwd: wifiPassword
        ) { retCode, msgDict in

            print("📥 configWiFi callback")
            print("   ret:", retCode)
            print("   msg:", msgDict ?? [:])

            if retCode == 0 {
                completion(true, "✅ Wi-Fi configured successfully")
            } else {

                let errorMsg: String
                switch retCode {
                case 1: errorMsg = "Timeout"
                case 2: errorMsg = "Device not nearby"
                case 3: errorMsg = "Connection failed"
                case 4: errorMsg = "Authentication failed"
                case 5: errorMsg = "Invalid parameters"
                case 11: errorMsg = "MAC / eKey mismatch"
                default: errorMsg = "Error code \(retCode)"
                }

                completion(false, "❌ Wi-Fi config failed: \(errorMsg)")
            }
        }

        if ret != 0 {
            completion(false, "❌ Failed to start Wi-Fi config (code \(ret))")
        }
    }
}
