//
//  AssignedDeviceViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 07/01/26.
//

import Foundation
import Combine

@MainActor
final class AssignedDeviceViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var issuccess = false
    @Published var hasLoadedOnce = false
    @Published var assignDeviceDetails: AssignDeviceListResponse?
    @Published var alredayConfiguredDeviceList: [AssignDevice] = []
    private let networkManager = NetworkManager.shared
    private var fetchTask: Task<Void, Never>?
    
    private var heartbeatMap: [String: Date] = [:]
    private var heartbeatTask: Task<Void, Never>?

    init() {
        observeHeartbeat()
    }
    
    

    private func startHeartbeatLoop() {
        heartbeatTask?.cancel()

        heartbeatTask = Task { @MainActor in
            while !Task.isCancelled {
                checkAllDevicesHeartbeat()

                // ⏱ wait 7 seconds
                try? await Task.sleep(nanoseconds: 7_000_000_000)
            }
        }
    }


    func fetchAssignDevice() async {
        //  Cancel previous fetch if any
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            errorMessage = nil
            isLoading = true
            
            defer { isLoading = false }

            guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
                errorMessage = "User ID missing!"
                return
            }

            do {
                let response = try await networkManager.AssignDeviceList(userID: userId)

                if response.status {
                    assignDeviceDetails = response
                    issuccess = true
                    
                    //stored alredy configured deviced
                    alredayConfiguredDeviceList.removeAll()
                    let allDevices = response.devices ?? []
                    alredayConfiguredDeviceList = allDevices.filter {
                        $0.isConfigured == false
                    }
                    // START HEARTBEAT TIMER HERE
                    startHeartbeatLoop()
                    
                } else {
                    errorMessage = response.message
                }

            } catch is CancellationError {
               // Ignore Swift concurrency cancellation
               return

           } catch let error as NSError where error.code == NSURLErrorCancelled {
               // Ignore URLSession (-999) cancellation
               return

           } catch {
               errorMessage = error.localizedDescription
           }
        }

        await fetchTask?.value
    }

    deinit {
        heartbeatTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    func stopHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
    }
    
//    private func observeHeartbeat() {
//        NotificationCenter.default.addObserver(
//            forName: .deviceHeartbeatReceived,
//            object: nil,
//            queue: .main
//        ) { [weak self] notification in
//            guard
//                let self,
//                let sn = notification.userInfo?["sn"] as? String
//            else { return }
//
//            self.heartbeatMap[sn] = Date()
//            self.updateDeviceStatus(sn: sn, status: "ONLINE")
//        }
//    }
    
    
    
    private func observeHeartbeat() {
        NotificationCenter.default.addObserver(
            forName: .deviceHeartbeatReceived,
            object: nil,
            queue: nil   // ← important
        ) { [weak self] notification in
            guard
                let self,
                let sn = notification.userInfo?["sn"] as? String
            else { return }

            Task {
                await MainActor.run {
                    self.heartbeatMap[sn] = Date()
                    self.updateDeviceStatus(sn: sn, status: "ONLINE")
                }
            }
        }
    }


    
    private func checkAllDevicesHeartbeat() {
        let now = Date()

        for device in alredayConfiguredDeviceList {

            // 1️⃣ ENSURE SUBSCRIPTION
            MQTTManager.shared.subscribeIfNeeded(sn: device.serial)

            // 2️⃣ SEND HEARTBEAT COMMAND
            MQTTManager.shared.sendHeartbeatCheck(to: device.serial)

            // 3️⃣ OFFLINE CHECK
            if let last = heartbeatMap[device.serial] {
                let diff = now.timeIntervalSince(last)

                // ⏱ safer timeout = 2 cycles (14s)
                if diff > 8 {
                    updateDeviceStatus(sn: device.serial, status: "OFFLINE")
                }
            } else {
                updateDeviceStatus(sn: device.serial, status: "OFFLINE")
            }
        }
    }


    private func updateDeviceStatus(sn: String, status: String) {

        guard let index = alredayConfiguredDeviceList.firstIndex(where: {
            $0.serial == sn
        }) else { return }

        let old = alredayConfiguredDeviceList[index]

        let updated = AssignDevice(
            serial: old.serial,
            mac: old.mac,
            key: old.key,
            modelName: old.modelName,
            isConfigured: old.isConfigured,
            openType: old.openType,
            devType: old.devType,
            status: status
        )

        alredayConfiguredDeviceList[index] = updated
    }

    
}


//@MainActor
//final class AssignedDeviceViewModel: ObservableObject {
//
//    // MARK: - Published State
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var assignDeviceDetails: AssignDeviceListResponse?
//
//    // MARK: - Dependencies
//    private let networkManager = NetworkManager.shared
//
//    // MARK: - API / Static Fetch
//    func fetchAssignDevice() async {
//
//        isLoading = true
//        errorMessage = nil
//        defer { isLoading = false }
//
//        do {
//
//             let staticAssignDeviceJSON = """
//            {
//              "status": true,
//              "message": "successfully get all device",
//              "devices": [
//                {
//                  "serial": "4283847520",
//                  "mac": "d8:3b:da:36:53:62",
//                  "key": "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000",
//                  "model_name": "TC434",
//                  "is_configured": false,
//                  "open_type": 2,
//                  "dev_type": 14
//                },
//                {
//                  "serial": "4286749203",
//                  "mac": "d8:3b:da:37:04:92",
//                  "key": "b7becb164c2ed80ccb349cebc403c89f000000000000000000000000000000001000",
//                  "model_name": "TC434",
//                  "is_configured": false,
//                  "open_type": 2,
//                  "dev_type": 14
//                },
//                {
//                  "serial": "4282184653",
//                  "mac": "a0:76:4e:5a:ae:a2",
//                  "key": "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
//                  "model_name": "BC220",
//                  "is_configured": false,
//                  "open_type": 2,
//                  "dev_type": 14
//                },
//                {
//                  "serial": "4281275348",
//                  "mac": "A0:76:4E:5A:A8:22",
//                  "key": "dac22333fb812a482e773f646f3e538a000000000000000000000000000000001000",
//                  "model_name": "BC220",
//                  "is_configured": false,
//                  "open_type": 2,
//                  "dev_type": 14
//                },
//                {
//                  "serial": "4282705968",
//                  "mac": "58:cf:79:1a:89:ce",
//                  "key": "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000",
//                  "model_name": "M230",
//                  "is_configured": false,
//                  "open_type": 2,
//                  "dev_type": 14
//                }
//              ]
//            }
//            """
//
//            let jsonData = Data(staticAssignDeviceJSON.utf8)
//            let response = try JSONDecoder().decode(
//                AssignDeviceListResponse.self,
//                from: jsonData
//            )
//
//            assignDeviceDetails = response
//
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//    }
//}
