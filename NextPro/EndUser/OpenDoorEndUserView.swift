//  OpenDoorEndUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI
import CoreBluetooth

struct OpenDoorEndUserView: View {
    @StateObject private var mqttManager = MQTTManager.shared
    @State private var doors = [
        DoorModelUser(name: "Iron Hive Gym: Gate", duration: "For 5 Second", devSn: "4280125893", devMac: "58:cf:79:1a:8d:0e", devType: 2, eKey: "3ca884ca4f8d16e28199c11df14cfbcf000000000000000000000000000000001000",cardno: "1557198962"),
       // DoorModelUser(name: "Iron Hive Gym: Door 1", duration: "For 5 Second", devSn: "4282705968", devMac: "58:cf:79:1a:89:ce", devType: 2, eKey: "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000",cardno: "1557198962"),
        //DoorModelUser(name: "Iron Hive Gym: Door 1", duration: "For 5 Second", devSn: "4283847520", devMac: "d8:3b:da:36:53:62", devType: 2, eKey: "41f888c5017576eb80f030fe8730851d000000000000000000000000000000001000",cardno: "1557198962")
        
    ]
    
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
                
                
             
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(doors, id: \.name) { door in
                            DoorCardView(door: door)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color.black.opacity(0.4))
        .onAppear {
                    mqttManager.connect()
                    // Subscribe to all device topics on appear
                    for door in doors {
                        mqttManager.subscribeToDevice(door.devSn)
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

    }
    
    
    // MARK: - Bluetooth Check
    func checkBluetoothAndProceed(for door: DoorModelUser) {
        if bluetoothManager.state == .poweredOn {
            openSelectedDoor(door)
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
    
    // MARK: - Door Open Logic
    func openSelectedDoor(_ door: DoorModelUser) {
        print("🚪 Opening door: \(door.name)")
        let mqtt = MQTTManager.shared
        mqtt.subscribeToDevice(door.devSn)
        mqtt.sendOpenDoorCommand(to: door.devSn)
       
        
        let devModel = LibDevModel()
        devModel.devSn = door.devSn
        devModel.devMac = door.devMac
        devModel.devType = door.devType
        devModel.eKey = door.eKey
        devModel.cardno = door.cardno
        devModel.privilege = 4
        devModel.verified = 1
        devModel.startDate = "20240101000000"
        devModel.endDate = "20251231235959"
        
        let result = LibDevModel.openDoor(devModel)
        print("📤 openDoor() result: \(result)")
        
        // 🔹 Animate progress clockwise smoothly (3s)
        withAnimation(.easeInOut(duration: 0.3)) {
            showDurationText = true
            ringColor = .green
            lockIcon = "lock.open.fill"
            isOpening = true
            progress = 0.0 // ensure starts from 0 each tap
        }
        
        // Animate from 0 → 1 (smooth clockwise)
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }
        
        // Reset visuals after complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ringColor = .white
                lockIcon = "lock.fill"
                isOpening = false
                showDurationText = false
                progress = 0.0 // reset cleanly for next tap
            }
        }
    }
}


struct DoorModelUser {
    let name: String
    let duration: String
    let devSn: String
    let devMac: String
    let devType: Int32
    let eKey: String
    let cardno: String
}

#Preview {
    OpenDoorEndUserView()
}
