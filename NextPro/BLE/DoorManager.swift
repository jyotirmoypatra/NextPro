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
    @Published var retrievedCards: [String] = []
    @Published var cardReadProgress: String = ""
    
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
    
    // MARK: - Write Card Number to Device
    func writeCardNumber(_ door: DoorModel) {
        print("💳 ========================================")
        print("💳 WRITE CARD OPERATION STARTED")
        print("💳 ========================================")
        print("💳 Writing card number to door: \(door.name)")
        
        // Cancel any existing reset timer
        resetTimer?.cancel()
        
        isProcessing = true
        statusMessage = "Writing card to \(door.name)..."
        errorMessage = nil
        lastResult = nil
        
        // Create LibDevModel object
        let devModel = LibDevModel()
        
        // Set ONLY required parameters as per SDK doc
        devModel.devSn = door.devSn
        devModel.devMac = door.devMac
        devModel.devType = door.devType
        devModel.eKey = door.eKey
        devModel.privilege = 13
        // Note: cardno is NOT needed here - it goes in the array parameter
        
        print("📋 Write Card Config:")
        print("   Name: \(door.name)")
        print("   devSn: \(devModel.devSn ?? "nil")")
        print("   devMac: \(devModel.devMac ?? "nil")")
        print("   devType: \(devModel.devType)")
        print("   eKey length: \(devModel.eKey?.count ?? 0) chars")
        print("   Card to write: \(door.cardno)")
        
        // Validate card number format (should be numeric, typically 10 digits)
        if door.cardno.isEmpty {
            print("❌ ERROR: Card number is empty!")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "Invalid card number"
                self.errorMessage = "Card number is empty"
            }
            return
        }
        
        // Create card array with the door's card number (max 50 cards per batch)
        let cardArray = [door.cardno]
        print("📋 Card array to write: \(cardArray)")
        
        // Call SDK to write card
        print("📤 Calling LibDevModel.writeCard(toDevice:andCards:)...")
        let result = LibDevModel.writeCard(toDevice: devModel, andCards: cardArray)
        
        print("📤 ========================================")
        print("📤 writeCard() RESULT: \(result)")
        print("📤 ========================================")
        
        if result != 0 {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "Failed to initiate write"
                self.errorMessage = "SDK error: \(result). Check if device is powered on and nearby."
                print("❌ writeCard failed with code: \(result)")
                
                // Common error codes:
                // -1: General failure
                // -2: Invalid parameters
                // -101: Bluetooth not initialized or device issue
                if result == -101 {
                    self.errorMessage = "Bluetooth issue. Try restarting the app."
                } else if result == -2 {
                    self.errorMessage = "Invalid parameters. Check device config."
                }
            }
            
            // Auto-reset after error
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.resetState()
            }
        } else {
            print("⏳ Write card command sent successfully, waiting for device callback...")
            print("⏳ The device needs to be:")
            print("   1. Powered ON")
            print("   2. Within Bluetooth range")
            print("   3. Not connected to another device")
            
            // Safety timeout - reset after 30 seconds if no callback
            resetTimer = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if self.isProcessing {
                    print("⚠️ Write operation timed out - no callback received in 30 seconds")
                    print("⚠️ Possible reasons:")
                    print("   - Device is too far away")
                    print("   - Device is powered off")
                    print("   - Device is busy with another connection")
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.statusMessage = "Operation timed out"
                        self.errorMessage = "No response from device. Is it powered on and nearby?"
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
    
    // MARK: - Retrieve Card Numbers from Device
    func retrieveCardNumbers(_ door: DoorModel) {
        print("📖 ========================================")
        print("📖 RETRIEVE CARDS OPERATION STARTED")
        print("📖 ========================================")
        print("📖 Retrieving cards from door: \(door.name)")
        
        // Cancel any existing reset timer
        resetTimer?.cancel()
        
        isProcessing = true
        statusMessage = "Retrieving cards from \(door.name)..."
        errorMessage = nil
        lastResult = nil
        retrievedCards = []
        cardReadProgress = ""
        
        // Create LibDevModel object
        let devModel = LibDevModel()
        
        // Set required parameters
        devModel.devSn = door.devSn
        devModel.devMac = door.devMac
        devModel.devType = door.devType
        devModel.eKey = door.eKey
        
        // Set privilege to ADMIN for reading operations (1=super admin, 2=admin, 4=normal user)
        // Reading card info requires higher privileges
        devModel.privilege = 1  // Super admin privilege for reading
        
        // Set other optional parameters
        devModel.verified = SharedConfig.verified
        devModel.startDate = SharedConfig.startDate
        devModel.endDate = SharedConfig.endDate
        
        print("📋 Retrieve Card Config:")
        print("   Name: \(door.name)")
        print("   devSn: \(devModel.devSn ?? "nil")")
        print("   devMac: \(devModel.devMac ?? "nil")")
        print("   devType: \(devModel.devType)")
        print("   privilege: \(devModel.privilege) (1=super admin for reading)")
        print("   eKey length: \(devModel.eKey?.count ?? 0) chars")
        
        // Call SDK to retrieve cards with progress and complete callbacks
        print("📤 Calling LibDevModel.getCardNumbers(fromDevice:andProgress:andComplete:)...")
        
        let result = LibDevModel.getCardNumbers(
            fromDevice: devModel,
            andProgress: { [weak self] cur, all in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let progress = "Reading \(cur)/\(all) cards..."
                    self.cardReadProgress = progress
                    self.statusMessage = progress
                    print("📊 Progress: \(progress)")
                }
            },
            andComplete: { [weak self] result, all, cardnumbers in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    print("📥 ========================================")
                    print("📥 RETRIEVE CARDS COMPLETED")
                    print("📥 Result code: \(result)")
                    print("📥 Total cards: \(all)")
                    print("📥 Cards: \(cardnumbers ?? [])")
                    print("📥 ========================================")
                    
                    // Cancel the safety timeout timer
                    self.resetTimer?.cancel()
                    self.isProcessing = false
                    self.cardReadProgress = ""
                    
                    if result == 0 {
                        // Success
                        if let cards = cardnumbers, !cards.isEmpty {
                            self.retrievedCards = cards
                            self.statusMessage = "✅ Retrieved \(cards.count) card(s) successfully!"
                            self.lastResult = "Success"
                            self.errorMessage = nil
                            print("✅ SUCCESS: Retrieved \(cards.count) cards")
                            print("📋 Card list: \(cards)")
                        } else {
                            self.retrievedCards = []
                            self.statusMessage = "✅ No cards stored on device"
                            self.lastResult = "Success"
                            self.errorMessage = nil
                            print("✅ Device has no cards stored")
                        }
                        
                        // Schedule auto-reset after 15 seconds (longer to read results)
                        self.resetTimer = DispatchWorkItem { [weak self] in
                            self?.resetState()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: self.resetTimer!)
                    } else {
                        // Error - provide detailed explanation
                        self.retrievedCards = []
                        
                        // Map error codes to user-friendly messages
                        var errorDesc = ""
                        switch result {
                        case 1:
                            errorDesc = "Timeout - device not responding"
                        case 2:
                            errorDesc = "Device not found nearby"
                        case 3:
                            errorDesc = "Connection failed"
                        case 4:
                            errorDesc = "Authentication failed - check eKey"
                        case 5:
                            errorDesc = "Invalid parameters"
                        case 14:
                            errorDesc = "Operation not permitted - check device privileges or device may not support this feature"
                        default:
                            errorDesc = "Unknown error code: \(result)"
                        }
                        
                        self.statusMessage = "❌ Failed to retrieve cards"
                        self.errorMessage = errorDesc
                        self.lastResult = "Failed"
                        print("❌ FAILED: Error code \(result) - \(errorDesc)")
                        
                        if result == 14 {
                            print("⚠️ ERROR 14 possible reasons:")
                            print("   1. eKey doesn't have admin privileges")
                            print("   2. Device doesn't support card reading via BLE")
                            print("   3. Device is in a locked state")
                            print("   4. Feature requires super admin (privilege=1)")
                        }
                        
                        // Auto-reset after error
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            self.resetState()
                        }
                    }
                }
            }
        )
        
        print("📤 ========================================")
        print("📤 getCardNumbers() RESULT: \(result)")
        print("📤 ========================================")
        
        if result != 0 {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "Failed to initiate retrieve"
                self.errorMessage = "SDK error: \(result). Check device connection."
                print("❌ getCardNumbers failed with code: \(result)")
                
                if result == -101 {
                    self.errorMessage = "Bluetooth issue. Try restarting the app."
                } else if result == -2 {
                    self.errorMessage = "Invalid parameters. Check device config."
                }
            }
            
            // Auto-reset after error
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.resetState()
            }
        } else {
            print("⏳ Retrieve command sent successfully, waiting for device response...")
            
            // Safety timeout - reset after 60 seconds (reading cards can take time)
            resetTimer = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if self.isProcessing {
                    print("⚠️ Retrieve operation timed out - no completion callback in 60 seconds")
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.statusMessage = "Operation timed out"
                        self.errorMessage = "No response from device"
                        self.lastResult = "Timeout"
                        self.cardReadProgress = ""
                    }
                    // Auto-reset after timeout
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.resetState()
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: resetTimer!)
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
        print("📥 ========== SDK CALLBACK RECEIVED ==========")
        print("📥 Return code: \(ret)")
        print("📥 Message dict: \(msgDict ?? [:])")
        
        // Log all keys in msgDict for debugging
        if let dict = msgDict {
            print("📥 Message dict details:")
            for (key, value) in dict {
                print("   • \(key): \(value)")
            }
        }
        
        // Cancel the safety timeout timer
        resetTimer?.cancel()
        
        isProcessing = false
        
        switch ret {
        case 0:
            // Check if this was a write card operation or door open
            if statusMessage.contains("Writing") {
                statusMessage = "✅ Card written successfully!"
                lastResult = "Success"
                errorMessage = nil
                print("✅ SUCCESS: Card written to device!")
                print("✅ The card number can now be used on this device")
            } else {
                statusMessage = "✅ Door opened successfully!"
                lastResult = "Success"
                errorMessage = nil
                print("✅ SUCCESS: Door opened!")
            }
            
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
        retrievedCards = []
        cardReadProgress = ""
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

