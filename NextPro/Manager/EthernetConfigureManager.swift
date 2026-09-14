//
//  EthernetConfigureManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 14/09/26.
//

import Foundation

class EthernetConfigureManager {

    /// Guards against a completion handler firing more than once, mirroring
    /// `WiFiConfigureManager.SingleFireCompletion`.
    private final class SingleFireCompletion {
        private let lock = NSLock()
        private var hasFired = false
        private let completion: (Bool, String) -> Void

        init(_ completion: @escaping (Bool, String) -> Void) {
            self.completion = completion
        }

        func callAsFunction(_ success: Bool, _ message: String) {
            lock.lock()
            let alreadyFired = hasFired
            hasFired = true
            lock.unlock()

            guard !alreadyFired else {
                print("⚠️ EthernetConfigureManager completion fired again after first result — ignoring. (\(success), \(message))")
                return
            }
            completion(success, message)
        }
    }

    /// Number of times the SDK call is attempted in total before giving up (1 initial + 2 retries),
    /// matching the retry count `SetWiFiPassword` used for `WiFiConfigureManager`.
    private static let maxAttempts = 3
    private static let retryDelay: TimeInterval = 1.0

    /// Configures only the server IP/port on the device over Ethernet — no Wi-Fi
    /// credentials are involved since the device reaches the server over its wired link.
    /// The server IP/port are read from Keychain, same as `WiFiConfigureManager`.
    /// Retries the SDK call up to `maxAttempts` times if it fails.
    static func configureServerIP(
        device: AssignDevice,
        completion rawCompletion: @escaping (Bool, String) -> Void
    ) {
        let completion = SingleFireCompletion(rawCompletion)

        guard
            !device.serial.isEmpty,
            !device.mac.isEmpty,
            !device.key.isEmpty
        else {
            completion(false, "Device not configured")
            return
        }

        let serverIP = KeychainManager.shared.get("mqtt_host") ?? ""
        let serverPort = Int(KeychainManager.shared.get("device_port") ?? "6010") ?? 6010

        guard !serverIP.isEmpty else {
            completion(false, "Server IP missing from Keychain")
            return
        }

        attemptConfigureServerIP(
            device: device,
            serverIP: serverIP,
            serverPort: serverPort,
            attempt: 1,
            completion: completion
        )
    }

    private static func attemptConfigureServerIP(
        device: AssignDevice,
        serverIP: String,
        serverPort: Int,
        attempt: Int,
        completion: SingleFireCompletion
    ) {
        print("🔌 Ethernet Server IP Configuration Started (attempt \(attempt)/\(maxAttempts))")
        print("🔌 ==========================================================")
        print("   SN:", device.serial)
        print("   MAC:", device.mac)
        print("   eKey:", device.key)
        print("   Server IP:", serverIP)
        print("   Server Port:", serverPort)

        let devModel = LibDevModel()
        devModel.devSn = device.serial
        devModel.devMac = device.mac
        devModel.eKey = device.key
        devModel.devType = 13   // keep as-is

        func retryOrFail(_ message: String) {
            guard attempt < maxAttempts else {
                completion(false, message)
                return
            }

            print("Server IP config failed (attempt \(attempt)/\(maxAttempts)) — retrying in \(retryDelay)s: \(message)")

            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                attemptConfigureServerIP(
                    device: device,
                    serverIP: serverIP,
                    serverPort: serverPort,
                    attempt: attempt + 1,
                    completion: completion
                )
            }
        }

        let startRet = LibDevModel.setServerIP(
            devModel,
            andServerIP: serverIP,
            andServerPort: Int32(serverPort)
        ) { serverRet, serverMsg in

            print("📥 setServerIP callback")
            print("   ret:", serverRet)
            print("   msg:", serverMsg ?? [:])

            if serverRet == 0 {
                completion(true, "Server IP sent to device")
            } else {
                retryOrFail("Server IP set failed: \(SDKErrorCode.reason(for: Int(serverRet)))")
            }
        }

        if startRet != 0 {
            retryOrFail("Failed to start server IP config: \(SDKErrorCode.reason(for: Int(startRet)))")
        }
    }
}
