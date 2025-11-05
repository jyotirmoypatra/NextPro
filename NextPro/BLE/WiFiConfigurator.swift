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
        devModel.devMac = "d8:3b:da:36:53:62"     // optional, if available
        devModel.eKey = "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000"       // optional (some SDKs need user key)
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
