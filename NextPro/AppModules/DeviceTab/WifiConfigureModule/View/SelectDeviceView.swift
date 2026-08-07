//
//  SelectDeviceView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI
import CoreBluetooth
import Combine

struct SelectDeviceView: View {
    let devices: [AssignDevice]
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWiFiListView = false
    @State private var selectedDevice: AssignDevice? = nil
    @StateObject private var bleManager = BLEManager()
    @State private var isCheckingDevice = false
    @State private var showDeviceOfflineAlert = false
    @State private var showBluetoothPermissionAlert = false
    @State private var alertMessage = ""
    @State private var icon = ""
    @State private var tcScanTask: Task<Void, Never>?
    @State private var tcScanTimeoutTask: Task<Void, Never>?
    @State private var tcDeviceFound = false
    @State private var showInfo = false


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    HStack {
                        // LEFT: Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        // RIGHT: Info Icon
                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        Text("Select Your Device")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    VStack(spacing: 15) {
                        Image("socket-plug")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        
                        Text("Power on your device")
                            .font(.custom("Inter-Medium", size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Ensure the device is turned on before selecting it and tapping Next.")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color(hex: "#6D717F"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)   
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.11))
                    )
                    
                    // Device list (scrollable)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                          
                            if devices.isEmpty {
                                VStack(spacing: 14) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 44))
                                        .foregroundColor(.gray.opacity(0.8))

                                    Text("No Devices Found")
                                            .font(.custom("Inter-SemiBold", size: 18))
                                            .foregroundColor(.white)

                                        Text("No devices have been assigned to your account yet.\nPlease contact your administrator or try again later.")
                                            .font(.custom("Inter-Regular", size: 14))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                }
                                .padding(.top,60)

                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .transition(.opacity)
                            } else {
                                ForEach(devices) { item in
                                    DeviceItemCardView(
                                        device: item,
                                        isSelected: selectedDevice?.serial == item.serial
                                    ) {
                                        // ✅ Store FULL DEVICE
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedDevice = item
                                        }
                                    }
                                }


                                
                            }
                        }
                        .padding(.top, 10)
                    }
                    
            
                    // Next button
                    Button(action: {
//                        guard selectedDevice != nil else { return }
                       // navigateToWiFiListView = true
                        checkDeviceSignalAndProceed()
                    }) {
                        if isCheckingDevice {
                                HStack(spacing: 10) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))

                                    Text("Checking device...")
                                        .font(.custom("Inter-SemiBold", size: 15))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                Text("Next")
                                    .font(.custom("Inter-Bold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                    }
                    .background(selectedDevice == nil ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .disabled(selectedDevice == nil)
                    .padding(.bottom, 10)

                    
                    
                    
                    
                }
                .padding(.horizontal, 10)
                
                if showDeviceOfflineAlert {
                   
                    DeviceOfflineAlertView(
                        message: alertMessage, 
                        icon: icon
                    ) {
                        withAnimation {
                            showDeviceOfflineAlert = false
                        }
                    }
                    .zIndex(10)
                }
                
                if isCheckingDevice{
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }

            }
        }

        .navigationDestination(isPresented: $navigateToWiFiListView) {
            if let selectedDevice {
                SelectWiFiView(selectedDevice: selectedDevice)
            }
        }

        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showInfo) {
            InfoScreenView(infoType: "device_config_info")
        }
        .onReceive(bleManager.$bleState) { state in
            if state == .poweredOff {
                icon = "bluetooth-red"
                alertMessage = "Bluetooth is turned off.\nPlease enable Bluetooth to proceed."
            }
        }
        .modernAlert(isPresented: $showBluetoothPermissionAlert) {
            ModernAlertView(
                title: "Bluetooth Permission Required",
                message: "Bluetooth permission is disabled. \nPlease enable it in iPhone Settings → Apps → ZYLX → Bluetooth.",
                isSuccess: false,
                buttonTitle: "Cancel",
                action: {
                    showBluetoothPermissionAlert = false
                },
                secondaryButtonTitle: "Open Settings",
                secondaryAction: {
                    showBluetoothPermissionAlert = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }

    private var isBluetoothPermissionDenied: Bool {
        bleManager.bleState == .unauthorized
    }

    private var isBluetoothOff: Bool {
        bleManager.bleState == .poweredOff
    }

    private func checkDeviceSignalAndProceed() {
        guard let device = selectedDevice else { return }

        // STEP 1: Bluetooth permission check FIRST
        if isBluetoothPermissionDenied {
            showBluetoothPermissionAlert = true
            return
        }

        // STEP 2: Bluetooth power check
        if isBluetoothOff {
            icon = "bluetooth-red"   // your bluetooth icon asset
            alertMessage = "Bluetooth is turned off.\nPlease enable Bluetooth to proceed."
            showDeviceOfflineAlert = true
            return
        }

        // STEP 3: Continue with device power check
        startDeviceScan(serial: device.serial)

//        let isTCDevice = device.modelName.uppercased().hasPrefix("TC")
//        
//        // TC434 → BLE proximity scan (20s)
//            if isTCDevice {
//                startDeviceScan(serial: device.serial)
//                return
//            }
//            
//        isCheckingDevice = true
//        
//            let devModel = LibDevModel()
//            devModel.devSn = device.serial
//            devModel.devMac = device.mac
//            devModel.eKey = device.key
//            devModel.devType = Int32(device.devType ?? 13)
//            
//            let ret = LibDevModel.getDeviceSignal(devModel) { ret, msgDict in
//                DispatchQueue.main.async {
//                    isCheckingDevice = false
//                    
//                    if ret == 0, let rssi = msgDict?["signal"] as? NSNumber {
//                        print("Device RSSI:", rssi)
//                        navigateToWiFiListView = true
//                    } else {
//                        icon = "power-off"
//                        alertMessage =
//                        "The selected device is currently not powered on.\nPlease turn on the device to proceed."
//                        showDeviceOfflineAlert = true
//                    }
//                }
//            }
//            
//            if ret != 0 {
//                isCheckingDevice = false
//                icon = "power-off"
//                alertMessage =
//                "The selected device is currently not powered on.\nPlease turn on the device to proceed."
//                showDeviceOfflineAlert = true
//            }
        
    }
    private func startDeviceScan(serial: String) {
        isCheckingDevice = true
        tcDeviceFound = false

        // Cancel old tasks
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()

        bleManager.startScanning()

        // 🔍 Scan task
        tcScanTask = Task { @MainActor in
            for await devices in bleManager.$devices.values {
                for peripheral in devices {
                    let name = (peripheral.name ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if name.contains(serial) {
                        print("TC434 detected via BLE:", name)

                        tcDeviceFound = true
                        stopTCScan()

                        navigateToWiFiListView = true
                        return
                    }
                }
            }
        }

        // ⏱ Timeout task (ONLY if not found)
        tcScanTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 15_000_000_000)

            guard !tcDeviceFound else {
                return   // device already found → do nothing
            }

            stopTCScan()

            icon = "power-off"
            alertMessage =
            "The selected device is currently not powered on.\nPlease turn on the device to proceed."
            showDeviceOfflineAlert = true
        }
    }

    
    private func stopTCScan() {
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()

        tcScanTask = nil
        tcScanTimeoutTask = nil

        bleManager.stopScanning()
        isCheckingDevice = false
    }




}




struct DeviceItemCardView: View {
    let device: AssignDevice
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack(spacing: 16) {
                Image("smartphone")
                    .resizable()
                    .frame(width: 33, height: 33)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(device.modelName) (\(device.serial))")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(2)

//                    Text("Serial No : \(device.serial)")
//                        .font(.custom("Inter-Regular", size: 14))
//                        .foregroundColor(.gray.opacity(0.9))
//                        .lineLimit(2)
                }

                Spacer()

                // CHECKBOX
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(15)
            .background(
                isSelected
                ? Color.white.opacity(0.15)
                : Color.white.opacity(0.08)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                         Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct DeviceOfflineAlertView: View {
    let message: String
    let icon: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Icon
                Image(icon)
                    .resizable()
                    .frame(width: 48,height: 48)

                // Message
                Text(message)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // OK Button
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(25)
            .background(Color(hex: "#292929"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(.horizontal, 30)
        }
        .transition(.opacity)
    }
}
