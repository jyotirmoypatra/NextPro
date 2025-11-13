//  OpenDoorEndUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI
import CoreBluetooth
import Combine

struct OpenDoorEndUserView: View {
    @State private var bluetoothManager = CBCentralManager()
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @StateObject private var doorManager = DoorManager.shared
    @State private var isAutoOpenEnabled = false
    @State private var isAutoOpeningActive = false
    @State private var showBluetoothAlert = false
    @StateObject private var bleManager = BLEManager()
    @State private var lastDoorRSSI: [String: Int] = [:]
    var body: some View {
        ZStack {
        
            VStack(spacing: 0) {
                // ✅ Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome!")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                        Text("James Arthur")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.black)
                .zIndex(1)

                
                // 🔹 Auto Open Toggle Section
                HStack {
                    Image(systemName: isAutoOpenEnabled ? "dot.radiowaves.left.and.right" : "wave.3.left.circle")
                        .foregroundColor(isAutoOpenEnabled ? .green : .gray)
                        .font(.system(size: 18))
                    
                    Toggle(isOn: $isAutoOpenEnabled) {
                        Text("Auto Open Nearest Door")
                            .font(.custom("Inter-Regular", size: 15))
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.top, 10)


                .onChange(of: isAutoOpenEnabled) { newValue in
                    if newValue {
                        // ✅ Check Bluetooth first
                        if bluetoothManager.state != .poweredOn  {
                            print("⚠️ Bluetooth is OFF. Cannot enable auto-open.")
                            showBluetoothAlert = true
                            // Turn the toggle back off
                            isAutoOpenEnabled = false
                            return
                        }

                        print("🟢 Auto-open enabled — starting continuous BLE scanning...")

                        // Start continuous scanning
                        bleManager.startContinuousScanning()
                        
                        // Begin monitoring RSSI and auto-open logic
                        monitorAndAutoOpenNearbyDoor()
                    } else {
                        print("🔴 Auto-open disabled — stopping all BLE monitoring...")

                        // Stop everything cleanly
                        bleManager.stopContinuousScanning()
                        bleManager.stopMonitoringDevice()
                        bleManager.stopScanning() // in case standard scan was running
                    }
                }

                
                ScrollView(showsIndicators: false) {
                       VStack(spacing: 16) {
                           if doorStorage.isLoading {
                               ProgressView("Loading Doors...")
                                   .foregroundColor(.white)
                                   .padding(.top, 40)
                           } else if let error = doorStorage.errorMessage {
                               Text("⚠️ \(error)")
                                   .foregroundColor(.red)
                                   .padding(.top, 40)
                           } else if doorStorage.doors.isEmpty {
                               Text("No doors found.")
                                   .foregroundColor(.gray)
                                   .padding(.top, 40)
                           } else {
                               ForEach(doorStorage.doors) { door in
                                   DoorCardView(door: door)
                               }
                           }
                       }
                       .padding(.top, 10)
                       .padding(.horizontal, 20)
                   }
            }
        }
        .background(Color.black.opacity(0.4))
        .alert(isPresented: $showBluetoothAlert) {
                Alert(
                    title: Text("Bluetooth is Off"),
                    message: Text("Please enable Bluetooth to use Auto Open."),
                    primaryButton: .default(Text("Open Settings"), action: {
                        if let url = URL(string: "App-Prefs:root=Bluetooth"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        .task {
            await doorStorage.loadDoors()
            
            // Connect MQTT once
            mqttManager.connect()
            
            // Subscribe to all doors
            subscribeToAllDoors()
        }

        

    }

    // Helper function
    func subscribeToAllDoors() {
        for door in doorStorage.doors {
            mqttManager.subscribeToDevice(door.devSn)
        }
    }
    func monitorAndAutoOpenNearbyDoor() {
        // Continuously monitor discovered BLE devices
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // If user has turned it off, stop timer
            guard isAutoOpenEnabled else {
                timer.invalidate()
                return
            }

            for peripheral in bleManager.devices {
                let name = peripheral.name ?? ""
                let rssi = bleManager.monitoredDeviceRSSI ?? bleManager.deviceLastRSSI[peripheral.identifier] ?? -100

                // Example match logic: door BLE name like "XM-<devSn>"
                if let door = doorStorage.doors.first(where: { name.contains($0.devSn) }) {
                    print("📡 Found matching door \(door.name) (RSSI: \(rssi)dBm)")

                    if rssi > -55 && rssi < 0 {
                        print("🚪 Door nearby! Opening \(door.name)...")
                        doorManager.openSelectedDoor(door)

                        // ✅ Turn off auto-open after one success
                        isAutoOpenEnabled = false
                        bleManager.stopScanning()
                        bleManager.stopMonitoringDevice()

                        // Stop this timer permanently
                        timer.invalidate()

                        break
                    }
                }
            }
        }
    }

}


struct DoorCardView: View {
    let door: DoorModelUser
    @State private var progress: CGFloat = 0.0   // Start empty
    @StateObject private var doorManager = DoorManager.shared
    @State private var showBluetoothAlert = false
    @State private var bluetoothManager = CBCentralManager()
    
    // Animation states
    @State private var isOpening = false
    @State private var ringColor: Color = .white
    @State private var lockIcon: String = "lock.fill"
    @State private var showDurationText = false
    
    var body: some View {
        HStack {
            // Left details
            VStack(alignment: .leading, spacing: 5) {
                Image("dooricon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 48)
                
                Text(door.name)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                
                Text(door.devSn)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.gray)
                
                if showDurationText {
                    Text(door.duration)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            Spacer()
            VStack{
                Text("Offline")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.gray)
            
            Button(action: {
                checkBluetoothAndProceed(for: door)
            }) {
                ZStack {
                    // Base black circle
                    Circle()
                        .fill(Color.black)
                        .frame(width: 48, height: 48)
                    
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90)) // clockwise start at top
                    
                    Image(systemName: lockIcon)
                        .foregroundColor(isOpening ? .green : .white.opacity(0.6))
                        .font(.system(size: 20))
                        .scaleEffect(isOpening ? 1.1 : 1.0)
                }
            }
            .buttonStyle(.plain)
            
        }
        }
        .padding()
        .background(Color.white.opacity(0.09))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .alert(isPresented: $showBluetoothAlert) {
            Alert(
                title: Text("Bluetooth is Off"),
                message: Text("Please enable Bluetooth to open the door."),
                primaryButton: .default(Text("Open Settings"), action: {
                    openBluetoothSettings()
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if bluetoothManager.state != .poweredOn {
                    showBluetoothAlert = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
            if let info = notification.userInfo,
               let doorID = info["doorID"] as? Int,
               let verified = info["verified"] as? Int {
                
                if verified == 200 {
                    // ✅ Door opened successfully
                    withAnimation {
                        ringColor = .green
                        lockIcon = "lock.open.fill"
                        isOpening = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            ringColor = .white
                            lockIcon = "lock.fill"
                            isOpening = false
                        }
                    }
                } else {
                    // ❌ Door failed to open
                    withAnimation {
                        ringColor = .red
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        ringColor = .white
                    }
                }
            }
        }
        
        .onReceive(doorManager.$doorEvent.compactMap({ $0 })) { event in
            guard event.devSn == door.devSn else { return }
            switch event.status {
            case .starting:
                animateOpeningStart()
            case .success:
                animateSuccess()
            case .failure:
                animateFailure()
            }
            
            // Clear the event after processing to prevent re-triggering
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                doorManager.clearDoorEvent()
            }
        }


    }
    
    // MARK: - Animations
    func animateOpeningStart() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showDurationText = true
            ringColor = .green
            lockIcon = "lock.open.fill"
            isOpening = true
            progress = 0.0
        }
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }
        resetAnimationAfterDelay()
    }

    // ✅ Success → show green, then reset
    func animateSuccess() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .green
            lockIcon = "lock.open.fill"
            isOpening = true
        }
        resetAnimationAfterDelay()
    }

    // ❌ Failure → red, then reset
    func animateFailure() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .red
            lockIcon = "xmark"
            isOpening = false
        }
        resetAnimationAfterDelay()
    }

    // ⏳ Common reset (3 seconds later)
    func resetAnimationAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ringColor = .white
                lockIcon = "lock.fill"
                isOpening = false
                showDurationText = false
                progress = 0.0
            }
        }
    }

    // MARK: - Bluetooth Check
    func checkBluetoothAndProceed(for door: DoorModelUser) {
        if bluetoothManager.state == .poweredOn {
           // openSelectedDoor(door)
            doorManager.openSelectedDoor(door)
        } else {
            showBluetoothAlert = true
        }
    }
    
    // MARK: - Open Bluetooth Settings
    func openBluetoothSettings() {
        if let url = URL(string: "App-Prefs:root=Bluetooth"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
}

#Preview {
    OpenDoorEndUserView()
}
