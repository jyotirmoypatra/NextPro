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
    @State private var navigateToHome = false
    @State private var selectedDeviceIndex: Int? = nil
    @State private var selectedDeviceSN: String? = nil
    @State private var selectedDeviceConfig: DeviceConfig? = nil // Store matched device config
    
    // Use shared DoorManager for all SDK operations
    @StateObject private var doorManager = DoorManager.shared
    
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
                    HStack{
                        Spacer()
                        Button(action: {
                            navigateToHome = true
                        }) {
                            Text("SKIP")
                                .font(.custom("Inter-SemiBold", size: 15))
                                .foregroundColor(.white)
                        }
                        .navigationDestination(isPresented: $navigateToHome) {
                           HomeViewAdmin()
                                .navigationBarBackButtonHidden(true)
                                       .navigationBarHidden(true)
                                       .interactiveDismissDisabled(true)
                        }
                        
                    }
                  
                    
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
                doorManager.initializeBluetoothForScanning()
            }
        }
        .navigationDestination(isPresented: $navigateToWiFiListView) {
            OnboardPageWiFiListView(selectedDeviceSN: selectedDeviceSN ?? "")
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        OnboardPageDeviceScanView()
    }
}

