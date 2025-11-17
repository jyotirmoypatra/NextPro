////
////  DoorOpenView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 13/11/25.


import SwiftUI
import CoreBluetooth
import Combine
import AVFoundation

struct DoorOpenView: View {
    let Card: CardModelUser
    @State private var bluetoothManager = CBCentralManager()
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @StateObject private var CardStorage = UserCardStorageManager.shared
    @StateObject private var doorManager = DoorManager.shared
    @StateObject private var bleManager = BLEManager()
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var animateWave = false
    @State private var showBluetoothAlert = false
    @State private var isAutoOpenEnabled = false
    @State private var progress: CGFloat = 0.0
    @State private var isOpening = false
    @State private var ringColor: Color = .white
    @State private var lockIcon: String = "lock.fill"
    @State private var rssiTimer: Timer?

    
    var body: some View {
        ZStack {
            // Background gradient
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
          

            // Black translucent overlay
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            VStack(spacing: 40) {
                // 🔒 Lock + Progress ring (placed above card)
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                    
                    Image(systemName: lockIcon)
                       // .foregroundColor(isOpening ? .green : .white.opacity(0.7))
                        .foregroundColor(ringColor)
                        .font(.system(size: 30, weight: .semibold))
                        .scaleEffect(isOpening ? 1.1 : 1.0)
                        .animation(.spring(), value: isOpening)
                }
                
                // 🪪 Card (centered in the view)
                VStack(spacing: 32) {
                    HStack {
                        Text(Card.FacilityName)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Text(Card.companyName)
                            .font(.custom("Inter-Semibold", size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image("dooricon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 48)
                        
                        Spacer()

                        HotspotWaveExact()
                            .frame(width: 60, height: 20)
                    }
                    
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
                        
                        VStack(alignment: .trailing) {
                            Text("Exp")
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.white)
                            Text(Card.duration)
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.09))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // “Hold to card reader” text (below card)
                HStack(spacing: 6) {
                    Image("bluetooth")
                        .frame(width: 30,height: 30)
                        
                    Text("Hold to card reader")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }.padding(.top,-28)
                
                
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .offset(y: -70)
        }
        .task{
            
            await doorStorage.loadDoors()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if bluetoothManager.state != .poweredOn  {
                    print("⚠️ Bluetooth is OFF. Cannot enable auto-open.")
                    showBluetoothAlert = true
                    return
                }
                
                print("🟢 Auto-open enabled — starting continuous BLE scanning...")
                
                // Start continuous scanning
                bleManager.startContinuousScanning()
                
                // Begin monitoring RSSI and auto-open logic
                monitorAndAutoOpenNearbyDoor()
            }
        }
        .onDisappear {
            print("🛑 DoorOpenView disappeared — stopping all BLE and timers")
            
            // Stop continuous BLE scanning & monitoring
            bleManager.stopContinuousScanning()
            bleManager.stopMonitoringDevice()
            bleManager.stopScanning()
            
            // Stop RSSI monitoring timer
            rssiTimer?.invalidate()
            rssiTimer = nil
        }

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
        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
                guard let info = notification.userInfo
                       else { return }

                let type = info["type"] as? Int
                if type == 0 {
                   animateSuccess()
                    speakText("Door opened successfully.")
                    print("succes event recievd")
                   
                } else {
                  animateFailure()
                    speakText("Access Denied.")
                    print("succes event recievd")

                }
                
                doorManager.clearDoorEvent()
            }


            
            .onReceive(doorManager.$doorEvent.compactMap({ $0 })) { event in
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
    
    func animateOpeningStart() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .yellow
            lockIcon = "lock.fill"
            isOpening = true
            progress = 0.0
        }
        withAnimation(.linear(duration: 3.0)) {
            progress = 0.8
        }
       // resetAnimationAfterDelay()
    }
    func animateSuccess() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .green
            lockIcon = "checkmark"
            isOpening = true
            progress = 1.0
        }
        resetAnimationAfterDelay()
    }

    // ❌ Failure → red, then reset
    func animateFailure() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .red
            lockIcon = "xmark"
            isOpening = false
            progress = 1.0
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
                progress = 0.0
            }
        }
    }
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.42                // slightly slower, smooth pace
        utterance.pitchMultiplier = 0.95     // a bit lower pitch, soft and natural
        utterance.volume = 0.9               // gentle loudness
        utterance.postUtteranceDelay = 0.1   // small pause after speaking

        speechSynthesizer.speak(utterance)
    }


    func monitorAndAutoOpenNearbyDoor() {
        // Cancel any previous timer before starting a new one
        rssiTimer?.invalidate()
        
        // Start a new timer
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            for peripheral in bleManager.devices {
                let name = peripheral.name ?? ""
                let rssi = bleManager.monitoredDeviceRSSI ?? bleManager.deviceLastRSSI[peripheral.identifier] ?? -100
                
                // Example match logic
                if let door = doorStorage.doors.first(where: { name.contains($0.devSn) }) {
                    print("📡 Found matching door \(door.name) (RSSI: \(rssi)dBm)")

                    if rssi > -40 && rssi < 0 {
                        print("🚪 Door nearby! Opening \(door.name)...")
                        doorManager.openSelectedDoor(door)

                        // Stop BLE scanning
                        bleManager.stopScanning()
                        bleManager.stopMonitoringDevice()

                        // Stop timer to avoid continuous opening
                        timer.invalidate()
                        rssiTimer = nil

                        // Restart monitoring after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            print("🔄 Restarting door monitoring after 5 seconds...")
                            bleManager.startContinuousScanning()
                            monitorAndAutoOpenNearbyDoor()
                        }

                        break
                    }
                }
            }
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
