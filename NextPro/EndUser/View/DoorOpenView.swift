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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
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
    
    @State private var doorId : Int?
    @State private var doorName : String?
    @State private var AceesMessage : String?
    
    @State private var isUnauthorise = false
    
    @State private var grantedBase = ""
    @State private var deniedBase = ""
    @State private var unauthorizedBase = ""

    @State private var accessGrantedMessage = ""
    @State private var accessDeniedMessage = ""
    @State private var accessUnAuthorizedMessage = ""
    @State private var accessGreetingMessage = ""
    @State private var remoteAccessMessage = ""
    @State private var overlayMessage = ""
    
    @State private var animationResetTask: DispatchWorkItem?

    
    @State private var selectedTab = 0
    @State private var isRemoteUnlock = false
    
    @State private var hasDigitalKeyAccess: Bool = false
    @State private var hasRemoteAccess: Bool = false
    
    
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
                    VStack(alignment: .leading,spacing: 5) {
                        Text("Welcome!")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                       
                        if deviceVM.isLoading {
                            ShimmerTextView(width: 100, height: 16)
                        } else {
                            Text(deviceVM.deviceDetails?.userFullName ?? "")
                                .font(.custom("Inter-Regular", size: 16))
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
                
                
                DoorTabSection
                Group {
                    
                    if selectedTab == 0 && hasDigitalKeyAccess{
                        // Digital Key Tab start
                        
                        ScrollView(.vertical, showsIndicators: false){
                            VStack{
                                Spacer().frame(height: 20)
                                
                                VStack(spacing: 20) {
                                    
                                    // 🪪 Card (centered in the view)
                                    VStack(spacing: 32) {
                                        HStack {
                                            Text(deviceVM.deviceDetails?.organizationName ?? "")
                                                .font(.custom("Inter-SemiBold", size: 16))
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("NextPro")
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
                                                //  Text(selectedCard?.userName ?? "")
                                                Text(deviceVM.deviceDetails?.userFullName ?? "")
                                                    .font(.custom("Inter-Regular", size: 12))
                                                    .foregroundColor(.gray)
                                                
                                                Text(maskCardNumber(deviceVM.deviceDetails?.digitalCardNumber ?? ""))
                                                    .font(.custom("Inter-Regular", size: 12))
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing) {
                                                Text("Exp")
                                                    .font(.custom("Inter-Regular", size: 12))
                                                    .foregroundColor(.white)
                                                //.toFormattedDate(outputFormat: "yyyy") 
                                                Text(deviceVM.deviceDetails?.cardExpiryDate?.toFormattedDate() ?? "")
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
                                    .padding(.horizontal, 10)
                                    
                                    
                                    HStack(spacing: 6) {
                                        // Image("bluetooth")
                                        // .frame(width: 30,height: 30)
                                        
                                        Text(AceesMessage ?? "")
                                            .font(.custom("Inter-SemiBold", size: 16))
                                            .foregroundColor(isScanningActive ? .white.opacity(0.5) : .red.opacity(0.8))
                                            .padding(.horizontal,15)
                                        
                                    }
                                    
                                    
                                    HowItWorksView()
                                    
                                    
                                }
                                
                            }
                            .padding(.bottom, 30)
                            
                        }.transition(.opacity)
                            .refreshable{
                               
                                await deviceVM.refreshDeviceDetails()

                            }
                    }
                    
                    // Digital Key Tab end
                    
                     else if selectedTab == 1 && hasRemoteAccess
                    {
                        
                        // Remote Access Tab
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(deviceVM.standaloneControllerList) { door in
                                    RemoteDoorCardView(
                                        door: door,
                                        onRemoteOpen: {
                                            handleRemoteOpen(for: door)
                                        },
                                        onBLEOpen: {
                                            handleBLEOpen(for: door)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 20)
                        }


                        .transition(.opacity)
                        // Remote Access Tab
                    }
                    
                }.animation(.easeInOut(duration: 0.6), value: selectedTab)
                
            }.frame(maxHeight: .infinity, alignment: .top)
            
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
                       // Text(getStatusMessage())
                        Text(overlayMessage)
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(ringColor)
                            .padding(.horizontal,10)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .zIndex(10)
            }
            
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
        .task{
          
//            hasDigitalKeyAccess = UserDefaults.standard.bool(forKey: "digital_access")
//            hasRemoteAccess = UserDefaults.standard.bool(forKey: "remote_access")
            
            hasDigitalKeyAccess = true
            hasRemoteAccess = true
            
            
            await deviceVM.fetchDeviceDetailsIfNeeded()
            // Make sure deviceDetails is not nil
            print("Controller Serials:", deviceVM.allControllerSerials)

            
            accessGreetingMessage =
                UserDefaults.standard.string(forKey: "voice_greeting")
                ?? VoiceMessageDefaults.greetings.first?.text
                ?? ""

            grantedBase =
                UserDefaults.standard.string(forKey: "voice_granted")
                ?? VoiceMessageDefaults.granted.first?.text
                ?? ""

            deniedBase =
                UserDefaults.standard.string(forKey: "voice_denied")
                ?? VoiceMessageDefaults.denied.first?.text
                ?? ""

            unauthorizedBase =
                UserDefaults.standard.string(forKey: "voice_unauthorized")
                ?? VoiceMessageDefaults.unauthorized.first?.text
                ?? ""

            
            

            isViewVisible = true

            mqttManager.connect()
            

            
            AceesMessage = "Preparing Scan.."
            
            // Create a cancellable work item for delayed monitoring start
            let workItem = DispatchWorkItem { [weak bleManager] in
                // Only start monitoring if view is still visible
                guard isViewVisible else {
                    print("⚠️ View is no longer visible. Skipping monitoring start.")
                    return
                }
                
                guard hasDigitalKeyAccess else {
                       print("🚫 Digital Key Access not allowed. Skipping BLE monitoring.")
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
        .onAppear {
            // Load access flags from UserDefaults
//            hasDigitalKeyAccess = UserDefaults.standard.bool(forKey: "digital_access")
//            hasRemoteAccess = UserDefaults.standard.bool(forKey: "remote_access")
            
            hasDigitalKeyAccess = true
            hasRemoteAccess = true
            
            // Automatically select first available tab
                if hasDigitalKeyAccess {
                    selectedTab = 0
                } else if hasRemoteAccess {
                    selectedTab = 1
                }
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

                guard hasDigitalKeyAccess else {
                        print("🚫 Digital Key disabled — BLE restart blocked")
                        return
                    }
                
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
        

        .onChange(of: selectedTab) { newTab in
            if newTab == 1 {
                // 👉 Switched to Remote Access
                stopAllScanningAndMonitoring()
            } else {
                
                guard hasDigitalKeyAccess else {
                            print("🚫 Digital Key disabled — BLE not allowed")
                            return
                        }
                // 👉 Back to Digital Key
                guard isViewVisible else { return }
                guard bleManager.isBluetoothOn else {
                    AceesMessage = "Bluetooth is Off. Please turn it on."
                    return
                }

                print("🔄 Restarting BLE scanning (Back to Digital Key)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    bleManager.startContinuousScanning()
                    isScanningActive = true
                    monitorAndAutoOpenNearbyDoor()
                }
            }
        }

        
        
        
        .bluetoothModernAlert(isPresented: $showBluetoothAlert) {

            BluetoothAlertView(
                    onCancel: { showBluetoothAlert = false },
                    openSettings: {
                        if let url = URL(string: "App-Prefs:root=Bluetooth"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
        }
        

        .onReceive(bleManager.$bleState) { state in
            if state == .poweredOff {
               // showBluetoothAlert = true
                AceesMessage = "Bluetooth is Off. Please turn it on."
                isScanningActive = false
            } else {
                //showBluetoothAlert = false
            }
        }


        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
            guard let info = notification.userInfo
            else { return }
            
            
            let eventTime = parseMQTTTime(info["time"]) ?? Date()

               // ⛔ Drop old MQTT events
               if DoorManager.shared.shouldIgnoreMQTT(eventTime: eventTime) {
                   return
               }
            
            let type = info["type"] as? Int
            doorId = info["doorID"] as? Int
            let sn = info["sn"] as? String
            
            let resolvedDoorName = deviceVM.getDoorName(sn: sn, doorId: doorId)
            doorName = resolvedDoorName
            updateVoiceMessages(for: resolvedDoorName)
            let deniedTypes: Set<Int> = [
                41, // Non-effective time period
                42, // Illegal time period
                43, // Illegal access permission
                47, // Card not registered
                49, // Card expired
                53, // Card reported lost
                54, // Blacklist user
                55, // Verification mode error
                62  // User permission disabled
            ]

            
            if type == 0 {
                animateSuccess()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                AceesMessage =  accessGrantedMessage
                speakText(accessGrantedMessage)
                print("succes event recievd")
                
            }
            else if type == 19 {
                animateSuccess()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
               // speakText("Remote Open Door Successfully")
                speakText(remoteAccessMessage)
                overlayMessage = remoteAccessMessage
                
            }
            else if type == 126 {
                print("Ignore event-device startup")
                return
                
            }
            
            else if type == 8 {
                
                animateSuccess()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                //speakText("Remote Open Door Successfully")
                speakText(remoteAccessMessage)
                overlayMessage = remoteAccessMessage
                
            }
            else if let type = type, deniedTypes.contains(type) {
                   // ✅ ONLY real denial codes come here
                   animateFailure()
                   UINotificationFeedbackGenerator().notificationOccurred(.error)
                   AceesMessage = accessDeniedMessage
                   speakText(accessDeniedMessage)

            }
           else {
               // 🚫 Ignore all other events
               print("Ignored door event type:", type ?? -1)
               return
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
    
    private func handleRemoteOpen(for door: DoorModelUser) {
        print("🌐 Remote open tapped for:", door.name)

        // 1️⃣ Ensure MQTT is connected
//        MQTTManager.shared.connect()
//
//        // 2️⃣ Subscribe to this device (optional but recommended)
//        MQTTManager.shared.subscribeToDevice(
//            door.devSn,
//            model: "BC220" // or door.model if you have it
//        )

        isRemoteUnlock = true
        animateOpeningStart()
        MQTTManager.shared.sendOpenDoorCommand(
            to: door.devSn,
            doorID: door.doorID,
            duration: 5
        )
        

        print("🚪 Remote open command sent for doorID:", door.doorID)
    }


    private func handleBLEOpen(for door: DoorModelUser) {
        print("📡 BLE open tapped for:", door.name)

        // Ensure BLE is on
        guard bleManager.isBluetoothOn else {
            showBluetoothAlert = true
            return
        }

        isRemoteUnlock = true
        animateOpeningStart()
        // Open via BLE
        doorManager.openSelectedDoor(door)
    }

    
    private var DoorTabSection: some View {
        VStack(spacing: 0) {
            HStack {
                if hasDigitalKeyAccess {
                    Button(action: { withAnimation { selectedTab = 0 } }) {
                        Text("Digital Access")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 0 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                }
            
                if hasRemoteAccess {
                    Button(action: { withAnimation { selectedTab = 1 } }) {
                        Text("Remote Access")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 1 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)
            
            ZStack(alignment: selectedTab == 0 ? .leading : .trailing) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1.0)
                        
                        if hasDigitalKeyAccess && hasRemoteAccess {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 2)
                                .animation(.easeInOut(duration: 0.07), value: selectedTab)
                                .padding(.horizontal,20)
                        } else {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width - 40, height: 2)
                                .animation(.easeInOut(duration: 0.07), value: selectedTab)
                                .padding(.horizontal,20)
                        }
                    }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }

    
    private func stopAllScanningAndMonitoring() {
        print("🛑 Stopping BLE scanning & monitoring (Tab switch)")

        bleManager.stopContinuousScanning()
        bleManager.stopMonitoringDevice()
        bleManager.stopScanning()

        rssiTimer?.invalidate()
        rssiTimer = nil

        isScanningActive = false
        AceesMessage = "Scanning paused"
        

    }
    
//    private func updateVoiceMessages(for doorName: String?) {
//        let prefix = doorName.map { "\($0), " } ?? ""
//
//        accessGrantedMessage =
//            prefix + grantedBase + " - " + accessGreetingMessage
//
//        accessDeniedMessage =
//            prefix + deniedBase
//
//        accessUnAuthorizedMessage =
//            prefix + unauthorizedBase
//        
//        remoteAccessMessage = prefix + "Remote Open Successfully"
//    }
    
    private func updateVoiceMessages(for doorName: String?) {
        let cleanName = doorName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let prefix: String
        if let name = cleanName, !name.isEmpty {
            prefix = "\(name), "
        } else {
            prefix = ""
        }

        accessGrantedMessage =
            prefix + grantedBase + " - " + accessGreetingMessage

        accessDeniedMessage =
            prefix + deniedBase

        accessUnAuthorizedMessage =
            prefix + unauthorizedBase

        remoteAccessMessage =
            prefix + "Remote Open Successfully"
    }


    func animateOpeningStart() {
        
        // Cancel previous reset (important)
            animationResetTask?.cancel()

        
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .yellow
            lockIcon = "lock.fill"
            isOpening = true
            overlayMessage = "Verifying Please Wait..."
            progress = 0.0
        }
        withAnimation(.linear(duration: 1.5)) {
            progress = 1.0
        }
        scheduleReset()
    }
    func animateSuccess() {
        
        animationResetTask?.cancel()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .green
            lockIcon = "checkmark"
            isOpening = true
            progress = 1.0
            
            if isRemoteUnlock{
                overlayMessage = remoteAccessMessage
            }else{
                overlayMessage = accessGrantedMessage
            }
        }
        scheduleReset()
    }
    
    // ❌ Failure → red, then reset
    func animateFailure() {
        animationResetTask?.cancel()
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .red
            lockIcon = "xmark"
            isOpening = false
            progress = 1.0
            overlayMessage = isRemoteUnlock ? "Remote Unlock Failed" : accessDeniedMessage
            
        }
        scheduleReset()
    }
    
    func unauthorised() {
        animationResetTask?.cancel()
        isUnauthorise = true
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .orange
            lockIcon = "lock.fill"
            isOpening = false
            progress = 1.0
            overlayMessage = accessUnAuthorizedMessage
            
            
        }
        scheduleReset()
    }
    
    
    func scheduleReset() {
        // Cancel any previous reset
        animationResetTask?.cancel()

        let task = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.3)) {
                ringColor = .white
                lockIcon = "lock.fill"
                isOpening = false
                progress = 0.0
                AceesMessage = "Walk closer to the door."
                doorId = nil
                doorName = ""
                isUnauthorise = false
                isRemoteUnlock = false
                overlayMessage = "Processing.."
                
            }
        }

        animationResetTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: task)
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
                   doorName = ""
                   doorId = nil
                   updateVoiceMessages(for: "")
                   isScanningActive = false
                   
                   DispatchQueue.main.async {
                       ringColor = .yellow
                       lockIcon = "lock.fill"
                       isOpening = true
                       progress = 1.0
                       AceesMessage = "Verifying..."
                   }
                   
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       overlayMessage = accessUnAuthorizedMessage
                       unauthorised()
                       AceesMessage = accessUnAuthorizedMessage
                       UINotificationFeedbackGenerator().notificationOccurred(.error)
                       speakText(accessUnAuthorizedMessage)
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
            .padding(.horizontal, 10)
        }
    }
}

