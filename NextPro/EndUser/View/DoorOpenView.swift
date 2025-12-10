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
    // let Card: CardModelUser
    @Environment(\.scenePhase) private var scenePhase
  //  @State private var bluetoothManager = CBCentralManager()
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @ObservedObject private var cardStorage = UserCardStorageManager.shared
    @StateObject private var deviceVM = DeviceDetailsViewModel()
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
    @State private var isScanningActive = false
    @State private var isViewVisible = false
    @State private var startMonitoringTask: DispatchWorkItem?
    @ObservedObject var network = NetworkManager.shared
    @State private var selectedCard: CardModelUser?
    
    @State private var doorId : Int?
    @State private var AceesMessage : String?
    
    @State private var isUnauthorise = false
    
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                // MARK: - Header
                if network.didCheckInternet && !network.hasInternet {
                    HStack{
                        ZStack{
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.white)
                        }
                        Text("No Internet Connection")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.bottom,8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: network.hasInternet)
                }
                HStack {
                    Text("Welcome!")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
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
                
                
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                        Spacer().frame(height: 20)
                        
                        VStack(spacing: 30) {
                            
                            // 🪪 Card (centered in the view)
                            VStack(spacing: 32) {
                                HStack {
                                    Text(selectedCard?.FacilityName ?? "")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(selectedCard?.companyName ?? "")
                                        .font(.custom("Inter-Semibold", size: 16))
                                        .foregroundColor(.gray)
                                }
                                
                                 HStack {
                                     Image("dooricon")
                                         .resizable()
                                         .scaledToFit()
                                         .frame(width: 52, height: 48)
                                     
                                     Spacer()
                                     
                                     HotspotWaveExact(isActive: $isScanningActive)
                                         .frame(width: 60, height: 20)
                                 }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(selectedCard?.userName ?? "")
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(.gray)
                                        //                            Text(Card.cardno)
                                        //                                .font(.custom("Inter-Regular", size: 12))
                                        //                                .foregroundColor(.gray)
                                        
                                        
                                        Text(maskCardNumber(selectedCard?.cardno ?? ""))
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Exp")
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(.white)
                                        Text(selectedCard?.duration ?? "")
                                            .font(.custom("Inter-Regular", size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.09),
                                        Color.white.opacity(0.06)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            
                           
                            HStack(spacing: 6) {
                               // Image("bluetooth")
                                   // .frame(width: 30,height: 30)
                               
                                Text(AceesMessage ?? "")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(isScanningActive ? .white.opacity(0.5) : .red.opacity(0.5))
                                
                            }
                            
                            
                            HowItWorksView()
                            
                            
                        }
              
                    }
                    .padding(.bottom, 30)
                    
                }
                
                
            }
            
            // 🔒 Lock + Progress ring OVERLAY (positioned at center with full-screen background)
            if isOpening || progress > 0 || ringColor != .white {
                ZStack {
                    // Full-screen black background
                    Color.black.opacity(0.96)
                        .ignoresSafeArea()
                    
                    // Lock icon and progress ring in the center
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    ringColor,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: progress)
                            
                            Image(systemName: lockIcon)
                                .foregroundColor(ringColor)
                                .font(.system(size: 36, weight: .semibold))
                                .scaleEffect(isOpening ? 1.15 : 1.0)
                                .animation(.spring(), value: isOpening)
                            
                            if isUnauthorise {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 70, height: 6)   // thickness = 6
                                    .rotationEffect(.degrees(45)) // diagonal slash
                            }
                        }
                        .shadow(color: ringColor.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        // Status Message
                        Text(getStatusMessage())
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(ringColor)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .background(Color.black.opacity(0.4))
        .task{
            // Mark view as visible
            isViewVisible = true
            
            //
            
            mqttManager.connect()
            
//            for door in doorStorage.doors {
//                mqttManager.subscribeToDevice(door.devSn)
//            }
//            mqttManager.subscribeToDevice("4283847520")
//            mqttManager.subscribeToDevice("4282184653")
            
            mqttManager.subscribeToDevice("4283847520" ,  model: "tc434")
            mqttManager.subscribeToDevice("4282184653", model: "bc220")
            mqttManager.subscribeToDevice("4282705968", model: "M230")
            
            await cardStorage.loadCards()
            
            if let card = cardStorage.card {
                self.selectedCard = card
            }
            
            
            
            //
            
            
            
            await doorStorage.loadDoors()
            
            AceesMessage = "Preparing Scan.."
            
            // Create a cancellable work item for delayed monitoring start
            let workItem = DispatchWorkItem { [weak bleManager] in
                // Only start monitoring if view is still visible
                guard isViewVisible else {
                    print("⚠️ View is no longer visible. Skipping monitoring start.")
                    return
                }
                
                if let isOn = bleManager?.isBluetoothOn, !isOn {
                    print("⚠️ Bluetooth is OFF. Cannot enable auto-open.")
                   // showBluetoothAlert = true
                    isScanningActive = false
                    return
                }

                print("🟢 Auto-open enabled — starting continuous BLE scanning...")
                
                // Start continuous scanning
                bleManager?.startContinuousScanning()
                isScanningActive = true
                
                // Begin monitoring RSSI and auto-open logic
                monitorAndAutoOpenNearbyDoor()
               
            }
            
            // Store the work item so it can be cancelled
            startMonitoringTask = workItem
            
            // Schedule the work item with 2-second delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        }
        .onDisappear {
            print("🛑 DoorOpenView disappeared — stopping all BLE and timers")
            
            // Mark view as not visible
            isViewVisible = false
            
            // Cancel any pending monitoring start task
            startMonitoringTask?.cancel()
            startMonitoringTask = nil
            
            // Stop continuous BLE scanning & monitoring
            bleManager.stopContinuousScanning()
            bleManager.stopMonitoringDevice()
            bleManager.stopScanning()
            isScanningActive = false
            
            // Stop RSSI monitoring timer
            rssiTimer?.invalidate()
            rssiTimer = nil
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                print("🌙 App went to background — stopping BLE scanning and monitoring")
                
                // Stop all BLE activities
                bleManager.stopContinuousScanning()
                bleManager.stopMonitoringDevice()
                bleManager.stopScanning()
                isScanningActive = false
                AceesMessage = "Preparing Scan.."
                
                // Stop RSSI monitoring timer
                rssiTimer?.invalidate()
                rssiTimer = nil
                
            case .active:
                print("☀️ App became active — restarting BLE scanning and monitoring")
                
                // Only restart if view is still visible
                guard isViewVisible else {
                    print("⚠️ View is not visible. Skipping BLE restart.")
                    return
                }
                
                // Check if Bluetooth is available
//                if bluetoothManager.state != .poweredOn {
//                    print("⚠️ Bluetooth is OFF. Cannot restart auto-open.")
//                    showBluetoothAlert = true
//                    isScanningActive = false
//                    return
//                }
                if !bleManager.isBluetoothOn {
                    print("⚠️ Bluetooth is OFF. Cannot enable auto-open.")
                  //  showBluetoothAlert = true
                    isScanningActive = false
                    return
                }


                // Restart BLE scanning with a small delay to ensure everything is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Double-check view is still visible
                    guard isViewVisible else {
                        print("⚠️ View is no longer visible. Skipping BLE restart.")
                        return
                    }
                    print("🔄 Restarting BLE scanning...")
                    bleManager.startContinuousScanning()
                    isScanningActive = true
                    monitorAndAutoOpenNearbyDoor()
                }
                
            case .inactive:
                print("⏸️ App became inactive")
                // Optional: You can handle inactive state if needed
                
            @unknown default:
                break
            }
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
//        .onReceive(bleManager.$isBluetoothOn) { isOn in
//            if !isOn && CBCentralManager.authorization == .allowedAlways {
//                showBluetoothAlert = true
//                isScanningActive = true
//            }
//        }
        .onReceive(bleManager.$bleState) { state in
            if state == .poweredOff {
                showBluetoothAlert = true
                AceesMessage = "Bluetooth is turned OFF."
                isScanningActive = false
            } else {
                showBluetoothAlert = false
            }
        }

//        .onReceive(bleManager.$isBluetoothOn) { isOn in
//            if !isOn {
//                
//            }
//        }


        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
            guard let info = notification.userInfo
            else { return }
            
            let type = info["type"] as? Int
            doorId = info["doorID"] as? Int
            if type == 0 {
                animateSuccess()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                AceesMessage =  "Door Access Granted"
                speakText("Door Access Granted.")

//                if doorId == 1{
//                    AceesMessage =  "Access Granted"
//                    speakText("Access Granted.")
//                }else{
//                    AceesMessage =  "Door 2 opened successfully."
//                    speakText("Door 2 opened successfully.")
//                }
               
                print("succes event recievd")
                
            } else {
                animateFailure()
                UINotificationFeedbackGenerator().notificationOccurred(.error)

//                if doorId == 1{
//                    AceesMessage =  "Door 1 Access Denied"
//                    speakText("Door 1 Access Denied.")
//                }else{
//                    AceesMessage =  "Door 2 Access Denied"
//                    speakText("Door 2 Access Denied.")
//                }
                
                AceesMessage =  "Door Access Denied."
                speakText("Door Access Denied.")
                
               // speakText("Access Denied.")
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
    
   
    
    func getStatusMessage() -> String {
        if lockIcon == "checkmark" {
            return "Access Granted"
        } else if lockIcon == "xmark" {
            return "Access Denied"
        } else if ringColor == .yellow && lockIcon == "lock.fill" && !isUnauthorise{
            return "Verifying Please Wait..."
        }
        else if lockIcon == "lock.fill" && isUnauthorise {
            return "Unauthorized Door"
        }
        return "Processing..."
    }
    
    func animateOpeningStart() {
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .yellow
            lockIcon = "lock.fill"
            isOpening = true
            progress = 0.0
        }
        withAnimation(.linear(duration: 2.0)) {
            progress = 1.0
        }
        resetAnimationAfterDelay()
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
    
    func unauthorised() {
        isUnauthorise = true
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .orange
            lockIcon = "lock.fill"
            isOpening = false
            progress = 1.0
        }
        resetAnimationAfterDelay()
    }
    
    // ⏳ Common reset (3 seconds later)
    func resetAnimationAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ringColor = .white
                lockIcon = "lock.fill"
                isOpening = false
                progress = 0.0
                AceesMessage = "Walk closer to the door."
                doorId = nil
                isUnauthorise = false
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
        AceesMessage = "Walk closer to the door"
           rssiTimer?.invalidate()
           
           rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
               // 1️⃣ Find the closest device (BLEManager already filters for Thimmo devices only)
               let nearbyDevices = bleManager.devices.compactMap { peripheral -> (peripheral: CBPeripheral, rssi: Int)? in
                   let name = (peripheral.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                   let rssi = bleManager.monitoredDeviceRSSI ?? bleManager.deviceLastRSSI[peripheral.identifier] ?? -100
                   
                   return (peripheral, rssi)
               }
               
               // Sort by strongest RSSI (closest)
               guard let closest = nearbyDevices.max(by: { $0.rssi < $1.rssi }) else { return }
               
               let name = closest.peripheral.name ?? ""
               let rssi = closest.rssi
               
               print("🎯 Closest device: \(name) with RSSI: \(rssi)")
               
               // Only act if RSSI is strong
               guard rssi > -40 && rssi < 0 else { return }
               
               if let door = doorStorage.doors.first(where: { name.contains($0.devSn) }) {
                   // ✅ Authorized door
                   print("🚪 Door nearby! Opening \(door.name)...")
                   doorManager.openSelectedDoor(door)
                   
                   UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                   isScanningActive = false
                   bleManager.stopScanning()
                   bleManager.stopMonitoringDevice()
                   timer.invalidate()
                   rssiTimer = nil
                   
                   // Restart monitoring after 5 seconds
                   DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                       bleManager.startContinuousScanning()
                       isScanningActive = true
                       monitorAndAutoOpenNearbyDoor()
                   }
               }
               else {
                   // ⚠️ Unauthorized Thimmo device
                   print("🚫 Unauthorized Thimmo device nearby: \(name)")
                   
                   bleManager.stopScanning()
                   bleManager.stopMonitoringDevice()
                   timer.invalidate()
                   rssiTimer = nil
                   isScanningActive = false
                   
                   DispatchQueue.main.async {
                       ringColor = .yellow
                       lockIcon = "lock.fill"
                       isOpening = true
                       progress = 1.0
                       AceesMessage = "Verifying..."
                   }
                   
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       unauthorised()
                       AceesMessage = "Unauthorized Door.  Access Not permitted"
                       UINotificationFeedbackGenerator().notificationOccurred(.error)
                       speakText("Unauthorized Door. Access Not permitted")
                   }
                   
                   // Restart scanning after 5 seconds
                   DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                       bleManager.startContinuousScanning()
                       isScanningActive = true
                       monitorAndAutoOpenNearbyDoor()
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


struct HowItWorksView: View {
    var body: some View {
        VStack(spacing: 6) {
            
            // Centered Title
            HStack {
                Spacer()
                Text("How does it work?")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Left-Aligned Content
            VStack(alignment: .leading, spacing: 15) {
                Text("The 'Digital Card' will be activated automatically when you open the app.")
                Text("When activated, walk very close to the door reader and tap your phone.")
                Text("Door unlocks if you have valid access and vice versa.")
                Text("The 'Digital Card' is deactivated when the app is minimized, closed, or screen is off.")
                Text("Scanning resumes automatically when the app returns to the foreground.")
            }
            .font(.custom("Inter-Regular", size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
        }
    }
}

