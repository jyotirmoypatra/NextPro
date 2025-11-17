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
//                HStack {
//                    Image(systemName: isAutoOpenEnabled ? "dot.radiowaves.left.and.right" : "wave.3.left.circle")
//                        .foregroundColor(isAutoOpenEnabled ? .green : .gray)
//                        .font(.system(size: 18))
//                    
//                    Toggle(isOn: $isAutoOpenEnabled) {
//                        Text("Auto Open Nearest Door")
//                            .font(.custom("Inter-Regular", size: 15))
//                            .foregroundColor(.white)
//                    }
//                    .toggleStyle(SwitchToggleStyle(tint: .green))
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .background(Color.white.opacity(0.08))
//                .cornerRadius(10)
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//
//                .onChange(of: isAutoOpenEnabled) { newValue in
//                    if newValue {
//                        // ✅ Check Bluetooth first
//                        if bluetoothManager.state != .poweredOn  {
//                            print("⚠️ Bluetooth is OFF. Cannot enable auto-open.")
//                            showBluetoothAlert = true
//                            // Turn the toggle back off
//                            isAutoOpenEnabled = false
//                            return
//                        }
//
//                        print("🟢 Auto-open enabled — starting continuous BLE scanning...")
//
//                        // Start continuous scanning
//                        bleManager.startContinuousScanning()
//                        
//                        // Begin monitoring RSSI and auto-open logic
//                        monitorAndAutoOpenNearbyDoor()
//                    } else {
//                        print("🔴 Auto-open disabled — stopping all BLE monitoring...")
//
//                        // Stop everything cleanly
//                        bleManager.stopContinuousScanning()
//                        bleManager.stopMonitoringDevice()
//                        bleManager.stopScanning() // in case standard scan was running
//                    }
//                }

                
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
                           } else if CardStorage.card.isEmpty {
                               Text("No doors found.")
                                   .foregroundColor(.gray)
                                   .padding(.top, 40)
                           } else {
                               ForEach(CardStorage.card) { card in
                                   //DoorCardView(door: door)
                                   UserCardView(Card: card, showBluetoothAlert: $showBluetoothAlert)
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
                   mqttManager.connect()
                    for door in doorStorage.doors {
                        mqttManager.subscribeToDevice(door.devSn)
                    }
            mqttManager.subscribeToDevice("4283847520")

            await CardStorage.loadCards()
        }
    }

//
//    func monitorAndAutoOpenNearbyDoor() {
//        // Continuously monitor discovered BLE devices
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            // If user has turned it off, stop timer
//            guard isAutoOpenEnabled else {
//                timer.invalidate()
//                return
//            }
//
//            for peripheral in bleManager.devices {
//                let name = peripheral.name ?? ""
//                let rssi = bleManager.monitoredDeviceRSSI ?? bleManager.deviceLastRSSI[peripheral.identifier] ?? -100
//
//                // Example match logic: door BLE name like "XM-<devSn>"
//                if let door = doorStorage.doors.first(where: { name.contains($0.devSn) }) {
//                    print("📡 Found matching door \(door.name) (RSSI: \(rssi)dBm)")
//
//                    if rssi > -70 && rssi < 0 {
//                        print("🚪 Door nearby! Opening \(door.name)...")
//                        doorManager.openSelectedDoor(door)
//
//                        // ✅ Turn off auto-open after one success
//                        isAutoOpenEnabled = false
//                        bleManager.stopScanning()
//                        bleManager.stopMonitoringDevice()
//
//                        // Stop this timer permanently
//                        timer.invalidate()
//
//                        break
//                    }
//                }
//            }
//        }
//    }

}

//
//struct DoorCardView: View {
//    let door: DoorModelUser
//    @State private var progress: CGFloat = 0.0   // Start empty
//    @StateObject private var doorManager = DoorManager.shared
//    @State private var showBluetoothAlert = false
//    @State private var bluetoothManager = CBCentralManager()
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    // Animation states
//    @State private var isOpening = false
//    @State private var ringColor: Color = .white
//    @State private var lockIcon: String = "lock.fill"
//    @State private var showDurationText = false
//    
//    var body: some View {
//        HStack {
//            // Left details
//            VStack(alignment: .leading, spacing: 5) {
//                Image("dooricon")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 52, height: 48)
//                
//                Text(door.name)
//                    .font(.custom("Inter-SemiBold", size: 16))
//                    .foregroundColor(.white)
//                
//                Text(door.devSn)
//                    .font(.custom("Inter-Regular", size: 12))
//                    .foregroundColor(.gray)
//                
//                if showDurationText {
//                    Text(door.duration)
//                        .font(.custom("Inter-Regular", size: 12))
//                        .foregroundColor(.gray)
//                        .transition(.opacity)
//                }
//            }
//            Spacer()
//            
//           
//            Button(action: {
//                checkBluetoothAndProceed(for: door)
//            }) {
//                ZStack {
//                    // Base black circle
//                    Circle()
//                        .fill(Color.black)
//                        .frame(width: 48, height: 48)
//                    
//                    
//                    Circle()
//                        .trim(from: 0, to: progress)
//                        .stroke(
//                            ringColor,
//                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
//                        )
//                        .frame(width: 48, height: 48)
//                        .rotationEffect(.degrees(-90)) // clockwise start at top
//                    
//                    Image(systemName: lockIcon)
//                        .foregroundColor(isOpening ? .green : .white.opacity(0.6))
//                        .font(.system(size: 20))
//                        .scaleEffect(isOpening ? 1.1 : 1.0)
//                }
//            }
//            .buttonStyle(.plain)
//        }
//        .padding()
//        .background(Color.white.opacity(0.09))
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.white.opacity(0.1), lineWidth: 1)
//        )
//        .alert(isPresented: $showBluetoothAlert) {
//            Alert(
//                title: Text("Bluetooth is Off"),
//                message: Text("Please enable Bluetooth to open the door."),
//                primaryButton: .default(Text("Open Settings"), action: {
//                    openBluetoothSettings()
//                }),
//                secondaryButton: .cancel(Text("Cancel"))
//            )
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                if bluetoothManager.state != .poweredOn {
//                    showBluetoothAlert = true
//                }
//            }
//        }
//        
//        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
//            guard let info = notification.userInfo,
//                  let doorID = info["doorID"] as? Int,
//                  doorID == door.doorID else { return }
//
//            let type = info["type"] as? Int
//            if type == 0 {
//               animateSuccess()
//                speakText("Door opened successfully.")
//               
//            } else {
//              animateFailure()
//                speakText("Access Denied.")
//
//            }
//            
//            doorManager.clearDoorEvent()
//        }
//
//
//        
//        .onReceive(doorManager.$doorEvent.compactMap({ $0 })) { event in
//            guard event.doorId == door.doorID else { return }
//            switch event.status {
//            case .starting:
//                animateOpeningStart()
//            case .success:
//                animateSuccess()
//            case .failure:
//                animateFailure()
//            }
//            
//            // Clear the event after processing to prevent re-triggering
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                doorManager.clearDoorEvent()
//            }
//        }
//
//
//    }
//    
//    // MARK: - Animations
//    func animateOpeningStart() {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            showDurationText = true
//            ringColor = .green
//            lockIcon = "lock.open.fill"
//            isOpening = true
//            progress = 0.0
//        }
//        withAnimation(.linear(duration: 3.0)) {
//            progress = 1.0
//        }
//        resetAnimationAfterDelay()
//    }
//
//    // ✅ Success → show green, then reset
//    func animateSuccess() {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            ringColor = .green
//            lockIcon = "lock.open.fill"
//            isOpening = true
//        }
//        resetAnimationAfterDelay()
//    }
//
//    // ❌ Failure → red, then reset
//    func animateFailure() {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            ringColor = .red
//            lockIcon = "xmark"
//            isOpening = false
//        }
//        resetAnimationAfterDelay()
//    }
//
//    // ⏳ Common reset (3 seconds later)
//    func resetAnimationAfterDelay() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                ringColor = .white
//                lockIcon = "lock.fill"
//                isOpening = false
//                showDurationText = false
//                progress = 0.0
//            }
//        }
//    }
//
//    // MARK: - Bluetooth Check
//    func checkBluetoothAndProceed(for door: DoorModelUser) {
//        if bluetoothManager.state == .poweredOn {
//           // openSelectedDoor(door)
//            doorManager.openSelectedDoor(door)
//        } else {
//            showBluetoothAlert = true
//        }
//    }
//    
//    // MARK: - Open Bluetooth Settings
//    func openBluetoothSettings() {
//        if let url = URL(string: "App-Prefs:root=Bluetooth"),
//           UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
//    }
//    
//    func speakText(_ text: String) {
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = 0.42                // slightly slower, smooth pace
//        utterance.pitchMultiplier = 0.95     // a bit lower pitch, soft and natural
//        utterance.volume = 0.9               // gentle loudness
//        utterance.postUtteranceDelay = 0.1   // small pause after speaking
//
//        speechSynthesizer.speak(utterance)
//    }
//
//    
//}




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
            DoorOpenView(Card: Card)
            
            
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

