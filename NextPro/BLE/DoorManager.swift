//
//  DoorManager.swift
//  NextPro
//
//  Door opening manager using DoorMasterSDK
//

import Foundation
import CoreBluetooth
import Combine

class DoorManager: ObservableObject {
    static let shared = DoorManager()
    
    @Published var isProcessing = false
    @Published var statusMessage = "Ready"
    @Published var lastResult: String?
    @Published var errorMessage: String?
    
    private var resetTimer: DispatchWorkItem?
    
    // MARK: - Shared Configuration (applies to all doors)
    private struct SharedConfig {
        static let privilege: Int32 = 4       // 1=super admin, 2=admin, 4=normal user
        static let verified: Int32 = 1        // 1=by date, 2=by count, 3=both
        static let startDate = "20240101000000" // Start date: YYYYMMDDHHmmss
        static let endDate = "20251231235959"   // End date: YYYYMMDDHHmmss
    }
    
    private init() {
        // Initialize SDK
        print("🔧 Initializing DoorMasterSDK...")
        let result = LibDevModel.initBluetoothNotShowPower()
        print("📱 SDK Init result: \(result)")
        
        // Setup callbacks
        setupCallbacks()
    }
    
    // MARK: - Setup Callbacks
    private func setupCallbacks() {
        // Bluetooth initialization callback
        LibDevModel.onInitBluetoothOver { result in
            print("✅ Bluetooth initialized with result: \(result)")
        }
        
        // Bluetooth state callback
        LibDevModel.onBluetoothStateOver { state in
            let stateStr = self.bluetoothStateString(state)
            print("📡 Bluetooth state: \(stateStr)")
        }
        
        // Control result callback
        LibDevModel.onControlOver { [weak self] ret, msgDict in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleControlResult(ret, msgDict: msgDict)
            }
        }
    }
    
    // MARK: - Open Door Function (Deprecated - use openSelectedDoor instead)
    // Kept for backward compatibility, but now requires a door to be selected
    func openDoorWithHardcodedValues() {
        print("⚠️ openDoorWithHardcodedValues() is deprecated, use openSelectedDoor() instead")
        
        // Try to open selected door from storage
        if let selectedDoor = DoorStorageManager.shared.getSelectedDoor() {
            openSelectedDoor(selectedDoor)
        } else {
            DispatchQueue.main.async {
                self.statusMessage = "No door selected"
                self.errorMessage = "Please select a door from the list"
                print("❌ No door selected in storage")
            }
        }
    }
    
    // MARK: - Open Selected Door
    func openSelectedDoor(_ door: DoorModel) {
        print("🚪 Opening door: \(door.name)")
        
        // Cancel any existing reset timer
        resetTimer?.cancel()
        
        isProcessing = true
        statusMessage = "Opening \(door.name)..."
        errorMessage = nil
        lastResult = nil
        
        // Create LibDevModel object
        let devModel = LibDevModel()
        
        // Set required parameters from selected door
        devModel.devSn = door.devSn
        devModel.devMac = door.devMac
        devModel.devType = door.devType
        devModel.eKey = door.eKey
        devModel.cardno = door.cardno
        
        // Set optional parameters with defaults
        devModel.privilege = SharedConfig.privilege
        devModel.verified = SharedConfig.verified
        devModel.startDate = SharedConfig.startDate
        devModel.endDate = SharedConfig.endDate
        
        print("📋 Door Config:")
        print("   Name: \(door.name)")
        print("   devSn: \(devModel.devSn ?? "nil")")
        print("   devMac: \(devModel.devMac ?? "nil")")
        print("   devType: \(devModel.devType)")
        print("   cardno: \(devModel.cardno ?? "nil")")
        
        // Call SDK to open door
        let result = LibDevModel.openDoor(devModel)
        
        print("📤 openDoor() called, result: \(result)")
        
        if result != 0 {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "Failed to initiate"
                self.errorMessage = "SDK returned error code: \(result)"
                print("❌ openDoor failed with code: \(result)")
            }
        } else {
            print("⏳ Waiting for callback result...")
            
            // Safety timeout - reset after 30 seconds if no callback
            resetTimer = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if self.isProcessing {
                    print("⚠️ Operation timed out - no callback received in 30 seconds")
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.statusMessage = "Operation timed out"
                        self.errorMessage = "No response from device"
                        self.lastResult = "Timeout"
                    }
                    // Auto-reset after timeout
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.resetState()
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: resetTimer!)
        }
    }
    
    // MARK: - Scan and Open Nearest Door
    func scanAndOpenNearestDoor() {
        print("🔍 Scanning for nearest door...")
        isProcessing = true
        statusMessage = "Scanning for doors..."
        errorMessage = nil
        lastResult = nil
        
        // Get all doors from storage
        let doors = DoorStorageManager.shared.doors
        
        if doors.isEmpty {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "No doors configured"
                self.errorMessage = "Please add doors first"
                print("❌ No doors in storage")
            }
            return
        }
        
        // Create device list from all doors
        var devList: [LibDevModel] = []
        for door in doors {
            let devModel = LibDevModel()
            devModel.devSn = door.devSn
            devModel.devMac = door.devMac
            devModel.devType = door.devType
            devModel.eKey = door.eKey
            devModel.cardno = door.cardno
            devModel.privilege = SharedConfig.privilege
            devModel.verified = SharedConfig.verified
            devModel.startDate = SharedConfig.startDate
            devModel.endDate = SharedConfig.endDate
            devList.append(devModel)
        }
        
        print("📋 Scanning \(devList.count) configured doors")
        
        let timeout: Int32 = 5000 // 5 seconds
        
        // Scan and open nearest door
        let result = LibDevModel.scanAndOpenDoor(
            devList,
            timeout: timeout
        ) { [weak self] ret, msgDict in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleControlResult(ret, msgDict: msgDict)
            }
        }
        
        print("📤 scanAndOpenDoor() called, result: \(result)")
        
        if result != 0 {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "Scan failed"
                self.errorMessage = "SDK returned error code: \(result)"
            }
        }
    }
    
    // MARK: - Manual Scan
    func scanForDevices() {
        print("🔍 Manual device scan...")
        statusMessage = "Scanning..."
        
        // Setup scan callback
        LibDevModel.onScanOverSort { [weak self] devRssiArray in
            guard let self = self else { return }
            print("📊 Scan results: \(devRssiArray?.count ?? 0) devices found")
            
            if let devices = devRssiArray {
                for (index, device) in devices.enumerated() {
                    print("   Device \(index + 1): \(device)")
                }
            }
            
            DispatchQueue.main.async {
                self.statusMessage = "Found \(devRssiArray?.count ?? 0) devices"
            }
        }
        
        // Start scan (1000-10000ms for device scan, 100-600ms for quick open scan)
        let scanTime: Int32 = 3000 // 3 seconds
        let result = LibDevModel.scanDevice(scanTime)
        
        print("📤 scanDevice() called, result: \(result)")
    }
    
    // MARK: - Handle Control Result
    private func handleControlResult(_ ret: Int32, msgDict: NSMutableDictionary?) {
        print("📥 Control result received:")
        print("   Return code: \(ret)")
        print("   Message dict: \(msgDict ?? [:])")
        
        // Cancel the safety timeout timer
        resetTimer?.cancel()
        
        isProcessing = false
        
        switch ret {
        case 0:
            statusMessage = "✅ Door opened successfully!"
            lastResult = "Success"
            errorMessage = nil
            print("✅ SUCCESS: Door opened!")
            
            // Schedule auto-reset after 10 seconds
            resetTimer = DispatchWorkItem { [weak self] in
                self?.resetState()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: resetTimer!)
            
        case 1:
            statusMessage = "⏱️ Operation timeout"
            errorMessage = "Device did not respond in time"
            lastResult = "Timeout"
            print("⏱️ TIMEOUT")
            
            // Auto-reset after 5 seconds for errors
            scheduleErrorReset()
            
        case 2:
            statusMessage = "❌ Device not found"
            errorMessage = "Cannot find device nearby"
            lastResult = "Not found"
            print("❌ DEVICE NOT FOUND")
            
            scheduleErrorReset()
            
        case 3:
            statusMessage = "❌ Connection failed"
            errorMessage = "Failed to connect to device"
            lastResult = "Connection failed"
            print("❌ CONNECTION FAILED")
            
            scheduleErrorReset()
            
        case 4:
            statusMessage = "❌ Authentication failed"
            errorMessage = "Invalid credentials or permissions"
            lastResult = "Auth failed"
            print("❌ AUTHENTICATION FAILED")
            
            scheduleErrorReset()
            
        case 5:
            statusMessage = "❌ Invalid parameters"
            errorMessage = "Check device configuration"
            lastResult = "Invalid params"
            print("❌ INVALID PARAMETERS")
            
            scheduleErrorReset()
            
        default:
            statusMessage = "❌ Error code: \(ret)"
            errorMessage = "Unknown error occurred"
            lastResult = "Error \(ret)"
            print("❌ ERROR CODE: \(ret)")
            
            scheduleErrorReset()
        }
        
        // Parse additional info from msgDict if available
        if let dict = msgDict {
            for (key, value) in dict {
                print("   \(key): \(value)")
            }
        }
    }
    
    // MARK: - Schedule Error Reset
    private func scheduleErrorReset() {
        resetTimer = DispatchWorkItem { [weak self] in
            self?.resetState()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: resetTimer!)
    }
    
    // MARK: - Reset State
    func resetState() {
        print("🔄 Resetting DoorManager state...")
        resetTimer?.cancel()
        statusMessage = "Ready"
        lastResult = nil
        errorMessage = nil
        isProcessing = false
    }
    
    // MARK: - Helper Functions
    private func bluetoothStateString(_ state: Int32) -> String {
        switch state {
        case 0: return "Unknown"
        case 1: return "Resetting"
        case 2: return "Unsupported"
        case 3: return "Unauthorized"
        case 4: return "Powered Off"
        case 5: return "Powered On"
        default: return "Unknown(\(state))"
        }
    }
    
    // MARK: - Get SDK Version
    func getSDKVersion() -> String {
        return LibDevModel.getDoorMasterSDKVersion()
    }
}

