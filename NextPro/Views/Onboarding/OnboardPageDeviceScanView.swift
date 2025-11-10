//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI
import CoreBluetooth

struct OnboardPageDeviceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWiFiListView = false
    @State private var selectedDeviceIndex: Int? = nil
    @State private var selectedDeviceSN: String? = nil
    @State private var selectedDeviceConfig: DeviceConfig? = nil // Store matched device config
    @State private var scannedDevices: [(sn: String, rssi: Int)] = []
    @State private var isScanning = false
    @State private var bluetoothStateMessage = ""
    @StateObject private var bleManager = BLEManager()
    @State private var isConnecting = false
    @State private var showBLEDebug = false
    @State private var isBackgroundModeActive = false
    private var isBluetoothInitialized = false
    
    // Device config manager
    private let deviceConfigManager = DeviceConfigManager.shared


    var body: some View {
        ZStack {
            // Background image
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Black translucent overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                // Header card
                VStack(spacing: 15) {
                    Image("computer")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.white)

                    Text("STEP 2 OF 3")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("Select your device from the list.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white)


                    Text("You’ll need to accept Bluetooth and location services in order to find and pair your device to the network.")
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(Color.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.12))
                )

                // Device list (scrollable)
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 12) {

                                        
                                        if bluetoothStateMessage.contains("Scanning for devices") {
                                            VStack(spacing: 12) {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(1.4)
                                                Text("Scanning for devices...")
                                                    .foregroundColor(.white)
                                                    .font(.custom("Inter-Regular", size: 15))
                                            }
                                            .padding(.top, 20)
                                        }
                                        else if !bluetoothStateMessage.isEmpty {
                                            Text(bluetoothStateMessage)
                                                .foregroundColor(.red)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        }
                                        else if scannedDevices.isEmpty {
                                            Text("No devices found yet...")
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.top, 20)
                                        }

                                        else {
                                            ForEach(Array(scannedDevices.enumerated()), id: \.element.sn) { index, device in
                                                let deviceConfig = deviceConfigManager.findDevice(bySn: device.sn)
                                                let isConfigured = deviceConfig != nil
                                                
                                                HStack {
                                                    Image("smartphone")
                                                        .resizable()
                                                        .frame(width: 22, height: 22)
                                                        .foregroundColor(isConfigured ? .green : .white)

                                                    VStack(alignment: .leading, spacing: 4) {
                                                        if let config = deviceConfig {
                                                            Text(config.name)
                                                                .font(.custom("Inter-SemiBold", size: 16))
                                                                .foregroundColor(.white)
                                                            Text("SN: \(device.sn) • \(device.rssi)dB")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(.white.opacity(0.6))
                                                        } else {
                                                            Text("Device \(device.sn)")
                                                                .font(.custom("Inter-SemiBold", size: 16))
                                                                .foregroundColor(.white)
                                                            Text("Signal: \(device.rssi)dB • Not Configured")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(.orange.opacity(0.8))
                                                        }
                                                    }

                                                    Spacer()
                                                    
                                                    if isConfigured {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                            .font(.system(size: 16))
                                                    }

                                                    Image(systemName: selectedDeviceIndex == index ? "checkmark.square.fill" : "square")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(selectedDeviceIndex == index ? .white : .white.opacity(0.6))
                                                        .onTapGesture {
                                                            selectedDeviceIndex = index
                                                            selectedDeviceSN = device.sn
                                                            selectedDeviceConfig = deviceConfig
                                                            
                                                            if let config = deviceConfig {
                                                                print("✅ Selected configured device: \(config.name)")
                                                                print("   SN: \(config.devSn)")
                                                                print("   MAC: \(config.devMac)")
                                                                print("   eKey: \(config.eKey.prefix(20))...")
                                                            } else {
                                                                print("⚠️ Selected unconfigured device: \(device.sn)")
                                                            }
                                                        }
                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(isConfigured ? Color.green.opacity(0.1) : Color.white.opacity(0.1))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(isConfigured ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                                                )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                }


                // "Scan Again" button
                Button(action: {
                    // Double-check scanning state before starting
                    guard !isScanning else {
                        print("⚠️ Ignoring scan request - already scanning")
                        return
                    }
                    startDeviceScan()
                }) {
                    HStack {
                        Image("scanning")
                        Text(isScanning ? "Scanning..." : "Scan Again")
                            .font(.custom("Inter-SemiBold", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .opacity(isScanning ? 0.5 : 1)
                }
                .disabled(isScanning || bluetoothStateMessage.contains("Failed") || bluetoothStateMessage.contains("Unsupported") || bluetoothStateMessage.contains("Unauthorized") || bluetoothStateMessage.contains("Powered Off"))
                .padding(.top, 5)
                .padding(.horizontal, 10)



                // Bottom controls
                HStack {
                    // Prev button
                    Button(action: { dismiss() }) {
                        Text("Prev")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }

                    Spacer()

                    // Page indicators
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }

                    Spacer()

                    // Next button
                    Button(action: {
                        guard selectedDeviceSN != nil else { return }
                        
                        if let config = selectedDeviceConfig {
                            print("🎯 Proceeding with configured device:")
                            print("   Name: \(config.name)")
                            print("   SN: \(config.devSn)")
                            print("   MAC: \(config.devMac)")
                            print("   Will use this config for WiFi setup and door operations")
                        } else {
                            print("⚠️ Proceeding with unconfigured device: \(selectedDeviceSN ?? "unknown")")
                        }
                        
                        navigateToWiFiListView = true
                    }) {
                        Text("Next")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .disabled(selectedDeviceSN == nil)
      



                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }

        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                initializeBluetooth()
            }
        }
        .navigationDestination(isPresented: $navigateToWiFiListView) {
            OnboardPageWiFiListView(selectedDeviceSN: selectedDeviceSN ?? "")
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - DoorMasterSDK Integration

    private func initializeBluetooth() {
        print("🔄 Initializing Bluetooth...")
        
        if isBluetoothInitialized {
                print("⚠️ Bluetooth already initialized — skipping reinit")
                return
            }
        
        bluetoothStateMessage = "Initializing Bluetooth..."

        // First, try to release any existing SDK instance to avoid -101 error
        print("🔄 Releasing any existing SDK instance...")
        LibDevModel.releaseSDK()

        // Small delay to ensure cleanup
        usleep(200_000) // 0.05 seconds

        let ret = LibDevModel.initBluetooth()

        print("📡 initBluetooth return code: \(ret)")

        if ret != 0 {
            print("❌ Failed to start Bluetooth initialization: \(ret)")
            bluetoothStateMessage = "Failed to initialize Bluetooth (\(ret))"

            // Try to understand the error code
            switch ret {
            case -101:
                print("❌ Error -101: SDK already initialized or Bluetooth state issue")
                print("🔄 Attempting to reset and retry...")
                bluetoothStateMessage = "Resetting Bluetooth..."

                // Try one more time after a longer delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.retryBluetoothInit()
                }
            case -1:
                print("❌ Error -1: General failure")
            case -2:
                print("❌ Error -2: Invalid parameters")
            default:
                print("❌ Unknown error code: \(ret)")
            }
        } else {
            print("✅ Bluetooth initialization started successfully")
            // Setup SDK after init call
            setupDoorMasterSDK()
        }
    }

    private func retryBluetoothInit() {
        print("🔄 Retrying Bluetooth initialization...")
        bluetoothStateMessage = "Retrying Bluetooth initialization..."

        let ret = LibDevModel.initBluetooth()
        print("📡 Retry initBluetooth return code: \(ret)")

        if ret == 0 {
            print("✅ Bluetooth initialization successful on retry")
            setupDoorMasterSDK()
        } else {
            print("❌ Bluetooth initialization failed even on retry: \(ret)")
            bluetoothStateMessage = "Bluetooth initialization failed (\(ret))"
        }
    }

    private func setupDoorMasterSDK() {
        print("🔧 Setting up DoorMaster SDK...")

        // Disable service filtering to detect all Bluetooth devices (including Thinmo devices)
        LibDevModel.notFilteringServiceWhenScan()
        print("✅ Service filtering disabled")

        // Set up Bluetooth initialization callback
        LibDevModel.onInitBluetoothOver { ret in
            DispatchQueue.main.async {
                if ret == 0 {
                    print("✅ Bluetooth initialized successfully")
                    bluetoothStateMessage = ""
                    // Auto-start scanning when Bluetooth is ready
                    startDeviceScan()
                } else {
                    print("❌ Bluetooth initialization failed: \(ret)")
                    bluetoothStateMessage = "Bluetooth initialization failed (\(ret))"
                }
            }
        }

        // Set up scan callback
        print("🔧 Setting up scan callback...")
        LibDevModel.onScanOver { devDict in
            DispatchQueue.main.async {
                print("✅ Scan completed with \(devDict?.count ?? 0) devices found")
                if let devices = devDict as? [String: Int] {
                    print("📱 Devices found: \(devices)")
                    // Convert to array sorted by RSSI (strongest signal first)
                    scannedDevices = devices.map { (sn: $0.key, rssi: $0.value) }
                        .sorted { $0.rssi > $1.rssi }
                    print("📋 Processed \(scannedDevices.count) devices")
                } else {
                    print("⚠️ No devices received in scan callback")
                }
                completeScan()
            }
        }
        print("✅ Scan callback setup complete")

        // Set up background scan callback as backup
        print("🔧 Setting up background scan callback...")
        LibDevModel.onBGScanOver { devDict in
            DispatchQueue.main.async {
                print("✅ BG Scan completed with \(devDict?.count ?? 0) devices found")
                if let devices = devDict as? [String: Int] {
                    print("📱 BG Devices found: \(devices)")
                    // Convert to array sorted by RSSI (strongest signal first)
                    scannedDevices = devices.map { (sn: $0.key, rssi: $0.value) }
                        .sorted { $0.rssi > $1.rssi }
                    print("📋 BG Processed \(scannedDevices.count) devices")
                } else {
                    print("⚠️ No devices received in BG scan callback")
                }
                completeScan()
            }
        }
        print("✅ BG Scan callback setup complete")

        // Set up Bluetooth state change callback
        LibDevModel.onBluetoothStateOver { state in
            DispatchQueue.main.async {
                let wasPoweredOn = (state == 5)
                switch state {
                case 0:
                    bluetoothStateMessage = "Bluetooth: Unknown"
                case 1:
                    bluetoothStateMessage = "Bluetooth: Resetting"
                case 2:
                    bluetoothStateMessage = "Bluetooth: Unsupported"
                case 3:
                    bluetoothStateMessage = "Bluetooth: Unauthorized"
                case 4:
                    bluetoothStateMessage = "Bluetooth: Powered Off"
                case 5:
                    bluetoothStateMessage = "Bluetooth: Powered On"
                    print("✅ Bluetooth is now powered on")
                    // Auto-start scanning when Bluetooth becomes available
                    if scannedDevices.isEmpty && !isScanning {
                        print("🔄 Auto-starting scan since Bluetooth is ready")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.startDeviceScan()
                        }
                    }
                default:
                    bluetoothStateMessage = "Bluetooth: State \(state)"
                }
                print("🔄 Bluetooth state changed to: \(state) - \(bluetoothStateMessage)")
            }
        }
    }

//    private func initializeBluetooth() {
//        print("🔄 Initializing Bluetooth...")
//        bluetoothStateMessage = "Initializing Bluetooth..."
//        let ret = LibDevModel.initBluetooth()
//        if ret != 0 {
//            print("❌ Failed to start Bluetooth initialization: \(ret)")
//            bluetoothStateMessage = "Failed to initialize Bluetooth (\(ret))"
//        }
//    }

    private func startDeviceScan() {
        // Double guard check for scanning state
        guard !isScanning else {
            print("⚠️ Scan already in progress - ignoring request")
            return
        }

        // Check if Bluetooth is ready for scanning
        if bluetoothStateMessage.contains("Powered Off") ||
           bluetoothStateMessage.contains("Unsupported") ||
           bluetoothStateMessage.contains("Unauthorized") ||
           bluetoothStateMessage.contains("Failed") {
            print("❌ Cannot scan - Bluetooth not ready: \(bluetoothStateMessage)")
            return
        }

        print("🔍 Starting device scan... (isScanning was: \(isScanning))")

        // Immediately set scanning state to prevent race conditions
        isScanning = true
        scannedDevices.removeAll()
        selectedDeviceIndex = nil
        selectedDeviceSN = nil
        bluetoothStateMessage = "Scanning for devices..."

        // Only stop background mode if it's actually running
        if isBackgroundModeActive {
            print("🔄 Stopping background mode before regular scan...")
            let stopRet = LibDevModel.stopBackgroundMode()
            if stopRet == 0 {
                print("✅ Background mode stopped successfully")
                isBackgroundModeActive = false
            } else {
                print("⚠️ Failed to stop background mode: \(stopRet)")
            }
            usleep(100000) // 0.1 second delay
        }

        print("📡 About to call LibDevModel.scanDevice(5000)")

        // Use shorter scan time (5 seconds) to avoid conflicts
        let ret = LibDevModel.scanDevice(5000)
        print("📡 Scan device return code: \(ret)")

        if ret == 0 {
            print("✅ Regular scan initiated successfully, waiting for callback...")
            isScanning = true
            bluetoothStateMessage = "Scanning for devices..."

            // Set a timeout in case the callback doesn't fire
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [self] in  // 5 second scan + 3 second buffer
                if isScanning {
                    print("⏰ Scan timeout - trying background scan as fallback...")
                    completeScan() // Complete current scan first

                    // Try background scan as fallback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tryBackgroundScan()
                    }
                }
            }
        } else {
            print("❌ Regular scan failed (error: \(ret)), trying background scan...")
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
            isBackgroundModeActive = true  // Track that background mode is active
            bluetoothStateMessage = "Scanning for devices (background mode)..."

            // Set a timeout for background scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [self] in
                if isScanning {
                    print("⏰ Background scan timeout - forcing completion")
                    completeScan()
                }
            }
        } else {
            print("❌ Background scan also failed (error: \(bgRet))")
            completeScan()
            bluetoothStateMessage = "Failed to start scanning (\(bgRet))"
        }
    }

    private func completeScan() {
        // Stop background mode if it's still active
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
}

#Preview {
    NavigationStack {
        OnboardPageDeviceScanView()
    }
}

