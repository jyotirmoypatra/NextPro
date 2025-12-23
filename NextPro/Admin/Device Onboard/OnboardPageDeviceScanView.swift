//
//  OnboardPageDeviceScanView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI
import CoreBluetooth

struct OnboardPageDeviceScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWiFiListView = false
    @State private var navigateToHome = false
    @State private var selectedDeviceIndex: Int? = nil
    @State private var selectedDeviceSN: String? = nil
    @State private var selectedDeviceConfig: DeviceConfig? = nil // Store matched device config
    
    // Use shared DoorManager for all SDK operations
    @StateObject private var doorManager = DoorManager.shared
    
    // Device config manager
    private let deviceConfigManager = DeviceConfigManager.shared


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
                
                VStack(spacing: 25) {
                    HStack {
                        // LEFT: Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        
                        Spacer()
                        
                        // RIGHT: Info Icon
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .overlay(
                        Text("Provision Device")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 5)
                    
                    
                    
                    // Device list (scrollable)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            
                            
                            if doorManager.bluetoothStateMessage.contains("Scanning for devices") {
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
                            else if !doorManager.bluetoothStateMessage.isEmpty {
                                Text(doorManager.bluetoothStateMessage)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            else if doorManager.scannedDevices.isEmpty {
                                Text("No devices found yet...")
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.top, 20)
                            }
                            
                            else {
                                ForEach(Array(doorManager.scannedDevices.enumerated()), id: \.element.sn) { index, device in
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
                        doorManager.startDeviceScan()
                    }) {
                        HStack {
                            Image("scanning")
                            Text(doorManager.isScanning ? "Scanning..." : "Scan Again")
                                .font(.custom("Inter-SemiBold", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .opacity(doorManager.isScanning ? 0.5 : 1)
                    }
                    .disabled(doorManager.isScanning || doorManager.bluetoothStateMessage.contains("Failed") || doorManager.bluetoothStateMessage.contains("Unsupported") || doorManager.bluetoothStateMessage.contains("Unauthorized") || doorManager.bluetoothStateMessage.contains("Powered Off"))
                    .padding(.top, 5)
                    .padding(.horizontal, 10)
                    
                    
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
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                    }
                    .background(selectedDeviceSN == nil ? Color.gray : Color.white)
                    .cornerRadius(12)           // ← APPLY HERE
                    .disabled(selectedDeviceSN == nil)
                    .padding(.horizontal, 10)    // ← Only side padding
                    .padding(.bottom, 30)
                    
                    
                    
                    
                }
                .padding(.horizontal, 20)
            }
        }

        .onAppear {
            doorManager.checkBluetoothPermissionOnAppear()
        }
        // Settings alert when permission denied
        .alert("Bluetooth Permission Required", isPresented: $doorManager.showBluetoothSettingsAlert) {
            Button("Close", role: .cancel) {}
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable Bluetooth permission for this app in Settings.")
        }

        // Turn ON Bluetooth alert
        .alert("Bluetooth is OFF", isPresented: $doorManager.showBluetoothTurnOnAlert) {
            Button("Close", role: .cancel) {}
            Button("Open Bluetooth Settings") {
                // "App-Prefs:root=Bluetooth" may work on some iOS versions; fallback to app settings
                if let url = URL(string: "App-Prefs:root=Bluetooth"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please turn on Bluetooth to scan devices.")
        }

        
        .navigationDestination(isPresented: $navigateToWiFiListView) {
            OnboardPageWiFiListView(selectedDeviceSN: selectedDeviceSN ?? "")
        }
        .navigationBarBackButtonHidden(true)
    }
}



