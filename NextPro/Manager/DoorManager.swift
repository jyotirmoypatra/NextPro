//
//  DoorManager.swift
//  NextPro
//
//  Door opening manager using DoorMasterSDK
//

import Foundation
import CoreBluetooth
import Combine

class DoorManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    static let shared = DoorManager()
    
    var centralManager: CBCentralManager?

    @Published var showBluetoothSettingsAlert: Bool = false
    @Published var showBluetoothTurnOnAlert: Bool = false

    private var hasRequestedBluetoothPermissionThisSession = false
    
    // Door operation states
    @Published var isProcessing = false
    @Published var statusMessage = "Ready"
    @Published var lastResult: String?
    @Published var errorMessage: String?
    @Published var retrievedCards: [String] = []
    @Published var cardReadProgress: String = ""
    
    // Device scanning states
    @Published var scannedDevices: [(sn: String, rssi: Int)] = []
    @Published var isScanning = false
    @Published var bluetoothStateMessage = ""
    @Published var isBluetoothInitialized = false
    
    private var resetTimer: DispatchWorkItem?
    private var isBackgroundModeActive = false
    private var currentProcessingDoorSn: String?
    private var currentProcessingDoorID: Int32?
    
    @Published var doorEvent: DoorEvent?

    struct DoorEvent {
        let devSn: String
        let doorId: Int32
        let status: Status
        
        enum Status {
            case starting
            case success
            case failure
        }
    }

    
    // MARK: - Shared Configuration (applies to all doors)
    private struct SharedConfig {
        static let privilege: Int32 = 4       // 1=super admin, 2=admin, 4=normal user
        static let verified: Int32 = 1        // 1=by date, 2=by count, 3=both
        static let startDate = "20240101000000" // Start date: YYYYMMDDHHmmss
        static let endDate = "20251231235959"   // End date: YYYYMMDDHHmmss
    }
 
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)

        // Initialize SDK (keep your original SDK init)
        print("🔧 Initializing DoorMasterSDK...")
        let result = LibDevModel.initBluetoothNotShowPower()
        print("📱 SDK Init result: \(result)")

        // Register SDK callbacks shortly after init
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupCallbacks()
        }
    }

    func checkBluetoothPermissionOnAppear() {
    
        let auth = CBCentralManager.authorization

        switch auth {
        case .notDetermined:
        
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: self, queue: .main)
            } else {
                _ = centralManager?.state
            }
            hasRequestedBluetoothPermissionThisSession = true

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showBluetoothSettingsAlert = true
                self.bluetoothStateMessage = "Bluetooth permission denied"
            }

        case .allowedAlways:
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: self, queue: .main)
            } else {
                startDeviceScanIfPossible()
            }

        @unknown default:
            break
        }
    }

    private func startDeviceScanIfPossible() {
        // Only start if we have permission and Bluetooth is powered on and SDK callbacks registered
        guard let central = centralManager, central.state == .poweredOn else {
            print("🔍 startDeviceScanIfPossible: central not ready")
            return
        }

        startDeviceScan()
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .poweredOn:
                print("📡 centralManagerDidUpdateState: poweredOn")
                // hide any "turn on" alert
                self.showBluetoothTurnOnAlert = false
                // start scan only when fully powered on
                self.bluetoothStateMessage = ""
                // If we previously asked for permission and user allowed, start scan
                self.startDeviceScanIfPossible()

            case .poweredOff:
                print("📡 centralManagerDidUpdateState: poweredOff")
                self.bluetoothStateMessage = "Bluetooth: Powered Off"
                self.showBluetoothTurnOnAlert = true

            case .unauthorized:
                print("📡 centralManagerDidUpdateState: unauthorized")
                self.bluetoothStateMessage = "Bluetooth: Permission denied"
                self.showBluetoothSettingsAlert = true

            case .unsupported:
                print("📡 centralManagerDidUpdateState: unsupported")
                self.bluetoothStateMessage = "Bluetooth: Unsupported"

            case .resetting:
                print("📡 centralManagerDidUpdateState: resetting")
                self.bluetoothStateMessage = "Bluetooth: Resetting"

            case .unknown:
                fallthrough
            @unknown default:
                print("📡 centralManagerDidUpdateState: unknown")
                self.bluetoothStateMessage = "Bluetooth: Unknown"
            }
        }
    }

    // MARK: - Setup Callbacks
    private func setupCallbacks() {
        print("🔧 Setting up SDK callbacks...")
        
        // Bluetooth initialization callback
        LibDevModel.onInitBluetoothOver { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if result == 0 {
                    print("✅ Bluetooth initialized successfully")
                    self.isBluetoothInitialized = true
                    self.bluetoothStateMessage = ""
                } else {
                    print("❌ Bluetooth initialization failed: \(result)")
                    self.bluetoothStateMessage = "Bluetooth initialization failed (\(result))"
                }
            }
        }
        
        // Bluetooth state callback
        LibDevModel.onBluetoothStateOver { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let stateStr = self.bluetoothStateString(state)
                print("📡 Bluetooth state: \(stateStr)")
                
                switch state {
                case 0: self.bluetoothStateMessage = "Bluetooth: Unknown"
                case 1: self.bluetoothStateMessage = "Bluetooth: Resetting"
                case 2: self.bluetoothStateMessage = "Bluetooth: Unsupported"
                case 3: self.bluetoothStateMessage = "Bluetooth: Unauthorized"
                case 4: self.bluetoothStateMessage = "Bluetooth: Powered Off"
                case 5:
                    self.bluetoothStateMessage = "Bluetooth: Powered On"
                    print("✅ Bluetooth is now powered on")
                default:
                    self.bluetoothStateMessage = "Bluetooth: State \(state)"
                }
            }
        }
        
        // Control result callback (door open/write card operations)
        LibDevModel.onControlOver { [weak self] ret, msgDict in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleControlResult(ret, msgDict: msgDict)
            }
        }
        
        // Scan callback
        LibDevModel.onScanOver { [weak self] devDict in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("✅ Scan completed with \(devDict?.count ?? 0) devices found")
                if let devices = devDict as? [String: Int] {
                    print("📱 Devices found: \(devices)")
                    self.scannedDevices = devices.map { (sn: $0.key, rssi: $0.value) }
                        .sorted { $0.rssi > $1.rssi }
                    print("📋 Processed \(self.scannedDevices.count) devices")
                }
                self.completeScan()
            }
        }
        
        // Background scan callback
        LibDevModel.onBGScanOver { [weak self] devDict in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("✅ BG Scan completed with \(devDict?.count ?? 0) devices found")
                if let devices = devDict as? [String: Int] {
                    print("📱 BG Devices found: \(devices)")
                    self.scannedDevices = devices.map { (sn: $0.key, rssi: $0.value) }
                        .sorted { $0.rssi > $1.rssi }
                    print("📋 BG Processed \(self.scannedDevices.count) devices")
                }
                self.completeScan()
            }
        }
        
        print("✅ All SDK callbacks registered successfully")
    }
    
    
    // MARK: - Open Selected Door
    func openSelectedDoor(_ door: DoorModelUser) {
        
        print("🚪 Opening door: \(door.name)")
        
        // Cancel any existing reset timer
        resetTimer?.cancel()
        
        DispatchQueue.main.async {
            self.doorEvent = DoorEvent(devSn: door.devSn, doorId: door.doorID, status: .starting)
           }
        
        // Store the current door SN for callback reference
        currentProcessingDoorSn = door.devSn
        currentProcessingDoorID = door.doorID
        
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
//        devModel.privilege = SharedConfig.privilege
//        devModel.verified = SharedConfig.verified
//        devModel.startDate = SharedConfig.startDate
//        devModel.endDate = SharedConfig.endDate
        
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
                   self.doorEvent = DoorEvent(devSn: door.devSn, doorId: door.doorID, status: .failure)
               }
               self.isProcessing = false
               self.statusMessage = "Failed to initiate"
               self.errorMessage = "SDK returned error code: \(result)"
           } else {
               print("⏳ Waiting for SDK callback...")
               // Callback will handle .success or .failure
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
//            devModel.privilege = SharedConfig.privilege
//            devModel.verified = SharedConfig.verified
//            devModel.startDate = SharedConfig.startDate
//            devModel.endDate = SharedConfig.endDate
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
  
    func scanAndOpenNearestDoorWithRSSI(threshold: Int = -60) {
        print("🔍 Scanning for nearest door with RSSI threshold \(threshold)dBm...")

        isProcessing = true
        statusMessage = "Scanning for nearby doors..."
        errorMessage = nil
        lastResult = nil

        let doors = DoorStorageManager.shared.doors
        guard !doors.isEmpty else {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.statusMessage = "No doors configured"
                self.errorMessage = "Please add doors first"
            }
            return
        }

        // Clear old results
        scannedDevices.removeAll()

        // Start BLE scan
        let timeout: Int32 = 4000
        let result = LibDevModel.scanDevice(timeout)

        if result == 0 {
            print("✅ Scan started successfully")

            // Wait for results that get stored via the global callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                guard !self.scannedDevices.isEmpty else {
                    print("⚠️ No nearby devices found.")
                    self.statusMessage = "No nearby door detected"
                    self.isProcessing = false
                    return
                }

                print("📶 RSSI Results: \(self.scannedDevices)")

                // Find nearest device
                if let nearest = self.scannedDevices.max(by: { $0.rssi < $1.rssi }) {
                    print("📡 Nearest device: \(nearest.sn) with RSSI: \(nearest.rssi)dBm")

                    if nearest.rssi > threshold {
                        // ✅ Found close enough device
                        if let door = doors.first(where: { $0.devSn == nearest.sn }) {
                            print("🚪 Opening \(door.name) (RSSI \(nearest.rssi)dBm within threshold)")
                            self.openSelectedDoor(door)
                        } else {
                            print("⚠️ Device SN \(nearest.sn) not in door list")
                        }
                    } else {
                        print("🚫 Device too far (RSSI \(nearest.rssi)dBm < \(threshold)dBm)")
                        self.statusMessage = "No nearby door found (too far)"
                        self.isProcessing = false
                    }
                }
            }

        } else {
            print("❌ Failed to start scan, error: \(result)")
            self.isProcessing = false
            self.statusMessage = "Scan failed"
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
                
                // Emit success event for door opening
                if let devSn = currentProcessingDoorSn,let doorID = currentProcessingDoorID {
                    DispatchQueue.main.async {
                        self.doorEvent = DoorEvent(devSn: devSn, doorId: doorID, status: .success)
                    }
                }
                
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
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn,let doorId = currentProcessingDoorID {
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
            // Auto-reset after 5 seconds for errors
            scheduleErrorReset()
            
        case 2:
            statusMessage = "❌ Device not found"
            errorMessage = "Cannot find device nearby"
            lastResult = "Not found"
            print("❌ DEVICE NOT FOUND")
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn,let doorId = currentProcessingDoorID {
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
            scheduleErrorReset()
            
        case 3:
            statusMessage = "❌ Connection failed"
            errorMessage = "Failed to connect to device"
            lastResult = "Connection failed"
            print("❌ CONNECTION FAILED")
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn , let doorId = currentProcessingDoorID{
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
            scheduleErrorReset()
            
        case 4:
            statusMessage = "❌ Authentication failed"
            errorMessage = "Invalid credentials or permissions"
            lastResult = "Auth failed"
            print("❌ AUTHENTICATION FAILED")
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn,let doorId  =  currentProcessingDoorID{
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
            scheduleErrorReset()
            
        case 5:
            statusMessage = "❌ Invalid parameters"
            errorMessage = "Check device configuration"
            lastResult = "Invalid params"
            print("❌ INVALID PARAMETERS")
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn ,let doorId  =  currentProcessingDoorID {
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
            scheduleErrorReset()
            
        default:
            statusMessage = "❌ Error code: \(ret)"
            errorMessage = "Unknown error occurred"
            lastResult = "Error \(ret)"
            print("❌ ERROR CODE: \(ret)")
            
            // Emit failure event
            if let devSn = currentProcessingDoorSn , let  doorId =  currentProcessingDoorID{
                DispatchQueue.main.async {
                    self.doorEvent = DoorEvent(devSn: devSn, doorId: doorId, status: .failure)
                }
            }
            
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
    
    // MARK: - Bluetooth Initialization (for onboarding)
    func initializeBluetoothForScanning() {
        print("🔄 Initializing Bluetooth for device scanning...")
        
        guard !isBluetoothInitialized else {
            print("⚠️ Bluetooth already initialized — skipping reinit")
            return
        }
        
        bluetoothStateMessage = "Initializing Bluetooth..."
        
        // Release any existing SDK instance
        print("🔄 Releasing any existing SDK instance...")
        LibDevModel.releaseSDK()
        usleep(200_000) // 0.2 seconds delay
        
        let ret = LibDevModel.initBluetooth()
        print("📡 initBluetooth return code: \(ret)")
        
        if ret != 0 {
            print("❌ Failed to start Bluetooth initialization: \(ret)")
            bluetoothStateMessage = "Failed to initialize Bluetooth (\(ret))"
            
            // Handle specific error codes
            if ret == -101 {
                print("❌ Error -101: SDK already initialized, retrying...")
                bluetoothStateMessage = "Resetting Bluetooth..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.retryBluetoothInit()
                }
            }
        } else {
            print("✅ Bluetooth initialization started successfully")
            setupScanningSDK()
        }
    }
    
    private func retryBluetoothInit() {
        print("🔄 Retrying Bluetooth initialization...")
        bluetoothStateMessage = "Retrying Bluetooth initialization..."
        
        let ret = LibDevModel.initBluetooth()
        print("📡 Retry initBluetooth return code: \(ret)")
        
        if ret == 0 {
            print("✅ Bluetooth initialization successful on retry")
            setupScanningSDK()
        } else {
            print("❌ Bluetooth initialization failed even on retry: \(ret)")
            bluetoothStateMessage = "Bluetooth initialization failed (\(ret))"
        }
    }
    
    private func setupScanningSDK() {
        print("🔧 Setting up SDK for scanning...")
        
        // Disable service filtering to detect all Bluetooth devices
        LibDevModel.notFilteringServiceWhenScan()
        print("✅ Service filtering disabled")
        
        // Note: Scan callbacks are already registered in setupCallbacks()
        print("✅ SDK ready for scanning")
    }
    
    // MARK: - Device Scanning
   

//    func startDeviceScan() {
//        // Prevent reentrant calls
//        LibDevModel.stopBackgroundMode()
//        usleep(250_000)
//        
//        if isScanning {
//            print("⚠️ startDeviceScan: already scanning")
//            return
//        }
//
//        // Check iOS Bluetooth state first
//        guard let central = centralManager else {
//            print("⚠️ startDeviceScan: centralManager is nil -> initialize and wait")
//            centralManager = CBCentralManager(delegate: self, queue: .main)
//            bluetoothStateMessage = "Initializing Bluetooth..."
//            return
//        }
//
//        guard central.state == .poweredOn else {
//            print("⚠️ startDeviceScan: central.state not poweredOn -> \(central.state.rawValue)")
//            // Show appropriate UI
//            if central.state == .poweredOff {
//                bluetoothStateMessage = "Bluetooth: Powered Off"
//                showBluetoothTurnOnAlert = true
//            } else if central.state == .unauthorized {
//                bluetoothStateMessage = "Bluetooth: Permission denied"
//                showBluetoothSettingsAlert = true
//            } else {
//                bluetoothStateMessage = "Bluetooth not ready"
//            }
//            return
//        }
//
//        // Now central is powered on — proceed with SDK scan
//        print("🔍 Starting device scan (SDK)...")
//        isScanning = true
//        scannedDevices.removeAll()
//        bluetoothStateMessage = "Scanning for devices..."
//
////        // If background mode active, stop it
////        if isBackgroundModeActive {
////            let stopRet = LibDevModel.stopBackgroundMode()
////            if stopRet == 0 {
////                isBackgroundModeActive = false
////            } else {
////                print("⚠️ Failed to stop background mode: \(stopRet)")
////            }
////            usleep(350_000)
////        }
//
//        // Call SDK's scan; if it fails we try background scan fallback
//        let ret = LibDevModel.scanDevice(8000)
//        print("📡 LibDevModel.scanDevice returned \(ret)")
//        if ret == 0 {
//            // SDK will callback to onScanOver / onBGScanOver — keep a timeout guard
//            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [weak self] in
//                guard let self = self else { return }
//                if self.isScanning {
//                    print("⏰ scan timeout — trying background scan fallback")
//                 
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.tryBackgroundScan()
//                    }
//                }
//            }
//        } else {
//            print("❌ Regular scan failed (error: \(ret)), trying background scan...")
//            tryBackgroundScan()
//        }
//    }
    
    func startDeviceScan() {

        print("🛑 Resetting SDK: stopping background mode…")
        LibDevModel.stopBackgroundMode()
        usleep(250_000)
//
//        if isBackgroundModeActive {
//            let stopRet = LibDevModel.stopBackgroundMode()
//            if stopRet == 0 {
//                print("✅ Background mode stopped")
//                isBackgroundModeActive = false
//                usleep(250_000) // small pause, enough for SDK
//            } else {
//                print("⚠️ Failed to stop background mode: \(stopRet)")
//            }
//        }

        
        // Prevent reentry
        if isScanning {
            print("⚠️ startDeviceScan: already scanning")
            return
        }

        // Check Bluetooth state
        guard let central = centralManager else {
            print("⚠️ centralManager is nil, initializing…")
            centralManager = CBCentralManager(delegate: self, queue: .main)
            bluetoothStateMessage = "Initializing Bluetooth..."
            return
        }

        guard central.state == .poweredOn else {
            print("⚠️ Bluetooth not powered on")
            if central.state == .poweredOff {
                showBluetoothTurnOnAlert = true
                bluetoothStateMessage = "Bluetooth: Powered Off"
            } else if central.state == .unauthorized {
                showBluetoothSettingsAlert = true
                bluetoothStateMessage = "Bluetooth: Permission denied"
            } else {
                bluetoothStateMessage = "Bluetooth not ready"
            }
            return
        }

        // Scan start
        print("🔍 Starting device scan (SDK)…")
        isScanning = true
        scannedDevices.removeAll()
        bluetoothStateMessage = "Scanning for devices..."

        // SDK scan for 8 sec
        let ret = LibDevModel.scanDevice(8000)
        print("📡 scanDevice returned \(ret)")

        if ret == 0 {

   //
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                if self.isScanning {
                    print("⏰ scan timeout — trying background scan fallback")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tryBackgroundScan()
                    }
                }
            }
            
            

        } else {
            print("❌ Regular scan failed, using background mode…")
            tryBackgroundScan()
        }
    }

    
    private func tryBackgroundScan() {
        print("🔄 Trying background scan as fallback...")
        
        let bgRet = LibDevModel.startBackgroundMode()
        print("📡 Background scan return code: \(bgRet)")
        
        if bgRet == 0 {
            print("✅ Background scan started successfully")
            isScanning = true
            isBackgroundModeActive = true
            bluetoothStateMessage = "Scanning for devices (background mode)..."
            
            // Timeout for background scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if self.isScanning {
                    print("⏰ Background scan timeout - forcing completion")
                    self.completeScan()
                }
            }
        } else {
            print("❌ Background scan also failed (error: \(bgRet))")
            completeScan()
            bluetoothStateMessage = "Failed to start scanning (\(bgRet))"
        }
    }
    
    private func completeScan() {
        // Stop background mode if active
        if isBackgroundModeActive {
            print("🔄 Stopping background mode after scan completion...")
            let stopRet = LibDevModel.stopBackgroundMode()
            if stopRet == 0 {
                print("✅ Background mode stopped successfully")
            } else {
                print("⚠️ Failed to stop background mode: \(stopRet)")
            }
            isBackgroundModeActive = false
        }
        
        isScanning = false
        bluetoothStateMessage = scannedDevices.isEmpty ? "No devices found nearby" : ""
        print("✅ Scan completed. Found \(scannedDevices.count) devices")
    }
    
    // MARK: - Clear Door Event
    func clearDoorEvent() {
        doorEvent = nil
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
        doorEvent = nil  // Also clear door event on full reset
        currentProcessingDoorSn = nil  // Clear the current processing door
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

