//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI

struct OnboardPageDeviceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWiFiListView = false
    @State private var selectedDeviceIndex: Int? = nil
    @State private var selectedDeviceSN: String? = nil
    @State private var scannedDevices: [(sn: String, rssi: Int)] = []
    @State private var isScanning = false
    @State private var bluetoothStateMessage = ""

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
                                    if !bluetoothStateMessage.isEmpty {
                                        Text(bluetoothStateMessage)
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                    } else if isScanning {
                                        // Loader
                                        ProgressView("Scanning for devices...")
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .foregroundColor(.white)
                                            .padding(.top, 30)

                                    } else  if scannedDevices.isEmpty {
                                            Text("No devices found yet...")
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.top, 20)
                                    } else {
                                            ForEach(Array(scannedDevices.enumerated()), id: \.element.sn) { index, device in
                                                HStack {
                                                    Image("smartphone")
                                                        .resizable()
                                                        .frame(width: 22, height: 22)
                                                        .foregroundColor(.white)

                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text("Device \(device.sn)")
                                                            .font(.custom("Inter-SemiBold", size: 16))
                                                            .foregroundColor(.white)
                                                        Text("Signal: \(device.rssi)dB")
                                                            .font(.custom("Inter-Regular", size: 14))
                                                            .foregroundColor(.white.opacity(0.6))
                                                    }

                                                    Spacer()

                                                    Image(systemName: selectedDeviceIndex == index ? "checkmark.square.fill" : "square")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(selectedDeviceIndex == index ? .white : .white.opacity(0.6))
                                                        .onTapGesture {
                                                            selectedDeviceIndex = index
                                                            selectedDeviceSN = device.sn
                                                        }
                                                }
                                                .padding()
                                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                }


                // "Scan Again" button
                Button(action: {
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
                }
                .disabled(isScanning || bluetoothStateMessage.contains("Failed") || bluetoothStateMessage.contains("Unsupported") || bluetoothStateMessage.contains("Unauthorized") || bluetoothStateMessage.contains("Powered Off"))
                .padding(.top, 10)
                .padding(.horizontal, 10)

                Spacer()

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
                        // TODO: Connect to selected device using DoorMasterSDK
                        // For now, just navigate to WiFi list
                        navigateToWiFiListView = true
                    }) {
                        Text("Next")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .disabled(selectedDeviceSN == nil)
//
                    .navigationDestination(isPresented: $navigateToWiFiListView) {
                        OnboardPageWiFiListView(selectedDeviceSN: selectedDeviceSN ?? "")
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
//        .onAppear{
//            isScanning = true
//            bleManager.startScanning()
//            
////            // stop loader after timeout or when devices found
////                   DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
////                       if !bleManager.devices.isEmpty {
////                           isScanning = false
////                       }
////                   }
//        }

        .onAppear {
            setupDoorMasterSDK()
            initializeBluetooth()
        }
        
        


        .navigationBarBackButtonHidden(true)
    }

    // MARK: - DoorMasterSDK Integration

    private func setupDoorMasterSDK() {
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
                isScanning = false
                bluetoothStateMessage = scannedDevices.isEmpty ? "No devices found nearby" : ""
            }
        }

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

    private func initializeBluetooth() {
        print("🔄 Initializing Bluetooth...")
        bluetoothStateMessage = "Initializing Bluetooth..."
        let ret = LibDevModel.initBluetooth()
        if ret != 0 {
            print("❌ Failed to start Bluetooth initialization: \(ret)")
            bluetoothStateMessage = "Failed to initialize Bluetooth (\(ret))"
        }
    }

    private func startDeviceScan() {
        guard !isScanning else {
            print("⚠️ Scan already in progress")
            return
        }

        // Check if Bluetooth is ready for scanning
        if bluetoothStateMessage.contains("Powered Off") ||
           bluetoothStateMessage.contains("Unsupported") ||
           bluetoothStateMessage.contains("Unauthorized") {
            print("❌ Cannot scan - Bluetooth not ready: \(bluetoothStateMessage)")
            return
        }

        print("🔍 Starting device scan...")
        isScanning = true
        scannedDevices.removeAll()
        selectedDeviceIndex = nil
        selectedDeviceSN = nil
        bluetoothStateMessage = "Scanning for devices..."

        // Scan for 3 seconds (3000ms)
        let ret = LibDevModel.scanDevice(3000)
        print("📡 Scan device return code: \(ret)")

        if ret != 0 {
            print("❌ Failed to start device scan: \(ret)")
            isScanning = false
            bluetoothStateMessage = "Failed to start scanning (\(ret))"
        } else {
            print("✅ Device scan initiated successfully")

            // Set a timeout in case the callback doesn't fire
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [self] in
                if isScanning {
                    print("⏰ Scan timeout - forcing completion")
                    isScanning = false
                    bluetoothStateMessage = scannedDevices.isEmpty ? "No devices found nearby" : ""
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardPageDeviceScanView()
    }
}
