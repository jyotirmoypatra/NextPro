//  OpenDoorEndUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI
import CoreBluetooth

struct OpenDoorEndUserView: View {
    @State private var doors = [
        DoorModelUser(name: "Iron Hive Gym: Gate", duration: "For 5 Second", devSn: "4280125893", devMac: "58:cf:79:1a:8d:0e", devType: 2, eKey: "3ca884ca4f8d16e28199c11df14cfbcf000000000000000000000000000000001000",cardno: "1557198962"),
        DoorModelUser(name: "Iron Hive Gym: Door 1", duration: "For 5 Second", devSn: "4282705968", devMac: "58:cf:79:1a:89:ce", devType: 2, eKey: "92fc410e8d125331c26faf21c7e77292000000000000000000000000000000001000",cardno: "1557198962")
        
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
    }
}



struct DoorCardView: View {
    let door: DoorModelUser
    var progress: CGFloat = 1.0   // Static 100% ring
    @StateObject private var doorManager = DoorManager.shared
    @State private var showBluetoothAlert = false
        @State private var bluetoothManager = CBCentralManager()
    var body: some View {
        HStack {
            // Left door details
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
                
                Text(door.duration)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            
            // ✅ Clickable Lock Button
            Button(action: {
            // openSelectedDoor(door)
                checkBluetoothAndProceed(for: door)
            }) {
                ZStack {
                    // Black background circle
                    Circle()
                        .fill(Color.black)
                        .frame(width: 48, height: 48)
                    
                    // White progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    // Lock icon
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 20))
                }
            }
            .buttonStyle(.plain) // Remove default button highlight
        }
        .padding()
        .background(Color.white.opacity(0.09))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // 🔹 Bluetooth OFF Alert
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
                   // 🔹 Check Bluetooth state on appear
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       if bluetoothManager.state != .poweredOn {
                           showBluetoothAlert = true
                       }
                   }
               }
    }
    
    // MARK: - Bluetooth Checking Logic
        func checkBluetoothAndProceed(for door: DoorModelUser) {
            if bluetoothManager.state == .poweredOn {
                openSelectedDoor(door)
            } else {
                showBluetoothAlert = true
            }
        }
        
        // MARK: - Open iPhone Bluetooth Settings
        func openBluetoothSettings() {
            if let url = URL(string: "App-Prefs:root=Bluetooth"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    func openSelectedDoor(_ door: DoorModelUser) {
        print("🚪 Opening door: \(door.name)")

        let devModel = LibDevModel()
        
        // Set required parameters from selected door
        devModel.devSn = door.devSn
        devModel.devMac = door.devMac
        devModel.devType = door.devType
        devModel.eKey = door.eKey
        devModel.cardno = door.cardno
        
        // Set optional parameters with defaults
        devModel.privilege = 4
        devModel.verified = 1
        devModel.startDate = "20240101000000"
        devModel.endDate = "20251231235959"
        
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
            
        } else {
          
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
