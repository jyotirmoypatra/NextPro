//  OpenDoorEndUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI
import CoreBluetooth
import Combine
import AVFoundation

struct OpenDoorEndUserView: View {
    @State private var bluetoothManager = CBCentralManager()
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @StateObject private var CardStorage = UserCardStorageManager.shared
    @StateObject private var doorManager = DoorManager.shared
    @StateObject private var deviceVM = DeviceDetailsViewModel()
    @State private var savedUserName: String = UserDefaults.standard.string(forKey: "username") ?? "Unknown User"
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
//                        Text("James Arthur")
//                            .font(.custom("Inter-Regular", size: 14))
//                            .foregroundColor(.gray)
                        
                        
                        if deviceVM.isLoading {
                            Text("Loading...")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                        } else if let name = deviceVM.deviceDetails?.userFullName {
                            Text(name)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                        } else {
                            Text("Unknown User")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                        
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
                           if CardStorage.isLoading {
                               ProgressView("Loading Doors...")
                                   .foregroundColor(.white)
                                   .padding(.top, 40)
                           } else if let error = CardStorage.errorMessage {
                               Text("⚠️ \(error)")
                                   .foregroundColor(.red)
                                   .padding(.top, 40)
                           } else if let card = CardStorage.card {
                               UserCardView(Card: card, showBluetoothAlert: $showBluetoothAlert)
                           } else {
                               Text("No card found.")
                                   .foregroundColor(.gray)
                                   .padding(.top, 40)
                           }
                       }
                       .padding(.top, 10)
                       .padding(.horizontal, 20)
                   }
            }
            
            
            // LOADING OVERLAY
            if deviceVM.isLoading {
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
            
            // CALL DEVICE DETAILS API
            await deviceVM.fetchDeviceDetails()
            
            mqttManager.connect()
            
            for door in doorStorage.doors {
                mqttManager.subscribeToDevice(door.devSn)
            }
            mqttManager.subscribeToDevice("4283847520")

            await CardStorage.loadCards()
        }
    }


}



struct UserCardView: View {
    let Card: CardModelUser
    @State private var navigateToDoorOpenView = false
    @State private var animateWave = false
    @State private var bluetoothManager = CBCentralManager()
    @Binding var showBluetoothAlert: Bool
    
    var body: some View {
        Button(action: {
            if bluetoothManager.state != .poweredOn {
                   showBluetoothAlert = true   // will work every time
                   return
               }

               navigateToDoorOpenView = true
            
        }) {
            VStack{
                
            
            
            HStack {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Text(Card.FacilityName)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Text(Card.companyName)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    // Door icon + hotspot waves
                    HStack {
                        Image("dooricon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 48)
                        
                        Spacer()
                        
                        /// HotspotWaveExact()
                        //  .frame(width: 60, height: 20)
                        
                    }
                    
                    // Footer
                    HStack {
                        VStack(alignment: .leading) {
                            Text(Card.userName)
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.gray)
//                            Text(Card.cardno)
//                                .font(.custom("Inter-Regular", size: 12))
//                                .foregroundColor(.gray)
                            
                            Text(maskCardNumber(Card.cardno))
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.gray)

                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Exp")
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.white)
                            Text(Card.duration)
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.09))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
                Text("Tap card to unlock")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top,10)
                
        }
        }
        .navigationDestination(isPresented: $navigateToDoorOpenView) {
            DoorOpenView()
            
            
        }
       

    }
    
    func maskCardNumber(_ cardNumber: String) -> String {
        guard cardNumber.count > 6 else {
            return String(repeating: "X", count: cardNumber.count)
        }
        let suffix = cardNumber.suffix(cardNumber.count - 6)
        return "XXXXXX" + suffix
    }


}


struct HotspotWaveExact: View {
    @State private var animateWaves = false
    
    var body: some View {
        ZStack {
            // Left waves
            ForEach(0..<3) { index in
                WaveArc(side: .left, radius: 8 + CGFloat(index) * 5)
                    .stroke(Color.green, lineWidth: 2)
                    .opacity(animateWaves ? 0.0 : 0.7)
                    .scaleEffect(animateWaves ? 1.15 : 0.95)
                    .animation(
                        .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                        value: animateWaves
                    )
            }

            // Center dot
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            // Right waves
            ForEach(0..<3) { index in
                WaveArc(side: .right, radius: 8 + CGFloat(index) * 5)
                    .stroke(Color.green, lineWidth: 2)
                    .opacity(animateWaves ? 0.0 : 0.7)
                    .scaleEffect(animateWaves ? 1.15 : 0.95)
                    .animation(
                        .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                        value: animateWaves
                    )
            }
        }
        .frame(width: 60, height: 24)
        .fixedSize()
        .rotationEffect(.degrees(0))
        .onAppear {
            animateWaves = true
        }
    }
}


// MARK: - Wave Arc Shape
struct WaveArc: Shape {
    enum Side {
        case left, right
    }
    
    let side: Side
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        if side == .left {
            // Left curved arc (opening to the left)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(135),
                endAngle: .degrees(225),
                clockwise: false
            )
        } else {
            // Right curved arc (opening to the right)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-45),
                endAngle: .degrees(45),
                clockwise: false
            )
        }
        
        return path
    }
}

