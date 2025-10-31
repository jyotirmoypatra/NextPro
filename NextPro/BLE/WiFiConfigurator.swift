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
        let devModel = LibDevModel()
        devModel.devSn = deviceSN
        devModel.devMac = ""     // optional, if available
        devModel.eKey = ""       // optional (some SDKs need user key)
        devModel.devType = 13    // set from docs / device type

        // Change IP & port to match your actual server
        let ip = "120.24.1.12"
        let port = 8181

        let ret = LibDevModel.configWiFi(
            devModel,
            ipAddress: ip,
            port: Int32(port),
            wiFiName: wifiName,
            wiFiPwd: wifiPassword
        ) { retCode, msgDict in
            DispatchQueue.main.async {
                if retCode == 0 {
                    completion(true, "✅ Wi-Fi configured successfully.")
                } else {
                    completion(false, "❌ Wi-Fi config failed. Code: \(retCode)")
                }
            }
        }

        if ret != 0 {
            completion(false, "❌ Failed to start configuration. Code: \(ret)")
        }
    }
}
