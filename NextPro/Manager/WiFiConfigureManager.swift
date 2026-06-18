//
//  WiFiConfigurator.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import Foundation

class WiFiConfigureManager {

    static func configureDeviceWiFi(
        device: AssignDevice,
        wifiName: String,
        wifiPassword: String,
        completion: @escaping (Bool, String) -> Void
    ) {

        print("🔧 WiFi Configuration Started")
        print("🔧 ==========================================================")

        guard
            !device.serial.isEmpty,
            !device.mac.isEmpty,
            !device.key.isEmpty
        else {
            completion(false, "❌ Device not configured")
            return
        }

        
        print("   SN:", device.serial)
        print("   MAC:", device.mac)
        print("   eKey:", device.key)

        let devModel = LibDevModel()
        devModel.devSn  = device.serial
        devModel.devMac = device.mac
        devModel.eKey   = device.key
        devModel.devType = 13   // keep as-is

//        let serverIP = "13.223.139.54"
//        let serverPort = 6010
        
        let serverIP = KeychainManager.shared.get("mqtt_host") ?? ""
        let serverPort = Int(KeychainManager.shared.get("device_port") ?? "6010") ?? 6010

        guard !serverIP.isEmpty else {
            completion(false, "Server IP missing from Keychain")
            return
        }

      // let isTCDevice = deviceModel.uppercased().hasPrefix("TC")
        let isTCDevice = device.modelName.uppercased().hasPrefix("TC")


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
                            completion(true, "Wi-Fi credentials sent to device")
                        } else {
                            completion(false, "WiFi config failed (code \(wifiRet))")
                        }
                    }

                    if wifiStartRet != 0 {
                        completion(false, "Failed to start WiFi config (code \(wifiStartRet))")
                    }
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 5.0,
                    execute: wifiWorkItem
                )
            }

            if startRet != 0 {
                completion(false, "Failed to start server IP config (code \(startRet))")
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
                completion(true, "Wi-Fi credentials sent to device")
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

                completion(false, "Wi-Fi config failed: \(errorMsg)")
            }
        }

        if ret != 0 {
            completion(false, "Failed to start Wi-Fi config (code \(ret))")
        }
    }
}
