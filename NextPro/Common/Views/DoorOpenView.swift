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
    @StateObject private var serverTimeVM = ServerTimeService.shared
    @State private var pollingTask: Task<Void, Never>?
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
    
    @State private var successDoorKey: String?
    @State private var activeDoorKey: String? = nil
    @State private var remoteMqttResult: RemoteMQTTResult?

    @State private var selectedTab = 0
    @State private var isRemoteUnlock = false
    @State private var showDoorErrorAlert = false
    
    @State private var hasDigitalKeyAccess: Bool = false
    @State private var hasRemoteAccess: Bool = false
    @State private var pullToRefresh: Bool = false
    
    @State private var didReceiveResponse = false

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
                    .padding(.horizontal,10)
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
                .padding(.top, 16)
                .padding(.bottom, 12)
                .padding(.horizontal,10)
                
                if !hasRemoteAccess && !hasDigitalKeyAccess {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("No Access Available")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                        
                        Text("You don't have any access method enable. Please contact your administrator.")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                    }
                    .padding(.horizontal,10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    
                }else {
                    
                    DoorTabSection
                    
                    Group {
                        
                        if selectedTab == 0 && hasDigitalKeyAccess{
                            // Digital Key Tab start
                            if !doorStorage.hasResolvedDoors {
                                VStack(spacing: 12) {
                                    ProgressView()
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .transition(.opacity)
                            }
                            else if !doorStorage.hasDoor {
                                VStack(spacing: 12) {
                                    Image(systemName: "lock.slash")
                                    
                                        .font(.system(size: 42))
                                        .foregroundColor(.gray)
                                    
                                    Text("No Digital Access Doors")
                                        .font(.custom("Inter-SemiBold", size: 18))
                                        .foregroundColor(.white)
                                    
                                    Text("You do not have any doors available for digital unlocking.")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .transition(.opacity)
                                .padding(.horizontal,10)
                            }
                            else{
                                ZStack {
                                    ScrollView(.vertical, showsIndicators: false){
                                        
                                        VStack{
                                            Spacer().frame(height: 20)
                                            
                                            if let date = serverTimeVM.localServerDate {
                                                Text(date.toReadableString(
                                                    format: "dd MMM yyyy, hh:mm a",
                                                    timeZoneID: serverTimeVM.localTimeZoneID
                                                ))
                                                .font(.custom("Inter-Regular", size: 14))
                                                .foregroundColor(.gray)
                                            }

                                            
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
//                                                    
//                                                    HStack {
//                                                        VStack(alignment: .leading) {
//                                                            //  Text(selectedCard?.userName ?? "")
//                                                            Text(deviceVM.deviceDetails?.userFullName ?? "")
//                                                                .font(.custom("Inter-Regular", size: 12))
//                                                                .foregroundColor(.gray)
//                                                            
//                                                            Text(maskCardNumber(deviceVM.deviceDetails?.digitalCardNumber ?? ""))
//                                                                .font(.custom("Inter-Regular", size: 12))
//                                                                .foregroundColor(.gray)
//                                                            
//                                                        }
//                                                        
//                                                        Spacer()
//                                                        
//                                                        VStack(alignment: .trailing) {
//                                                            Text("Exp")
//                                                                .font(.custom("Inter-Regular", size: 12))
//                                                                .foregroundColor(.white)
//                                                            //.toFormattedDate(outputFormat: "yyyy")
//                                                            Text(deviceVM.deviceDetails?.cardExpiryDate?.toFormattedDate() ?? "")
//                                                                .font(.custom("Inter-Regular", size: 12))
//                                                                .foregroundColor(.gray)
//                                                        }
//                                                    }
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
                                                        VStack(alignment: .leading) {
                                                            Text("VALID FROM")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(.gray)
                                                          
                                                            Text("\(deviceVM.deviceDetails?.startDate ?? ""), \(deviceVM.deviceDetails?.startTime ?? "")")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(.gray)

                                                        }
                                                        Spacer()
                                                        VStack(alignment: .leading) {
                                                            Text("VALID TO")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(.gray)
                                                           
                                                            Text("\(deviceVM.deviceDetails?.endDate ?? ""), \(deviceVM.deviceDetails?.endTime ?? "")")
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
                                               
                                                
                                                
                                                HStack(spacing: 6) {
                                        
                                                    Text(AceesMessage ?? "")
                                                        .font(.custom("Inter-SemiBold", size: 16))
                                                        .foregroundColor(isScanningActive ? .white.opacity(0.5) : .red.opacity(0.8))
                                                        .padding(.horizontal,15)
                                                    
                                                }
                                                
                                                
                                                HowItWorksView()
                                                
                                                
                                            }
                                            
                                        }
                                        .padding(.horizontal,10)
                                        .padding(.bottom, 30)
                                        
                                        
                                    }
                                    .transition(.opacity)
                                    .refreshable{
                                        pullToRefresh = true
                                        await deviceVM.refreshDeviceDetails()
                                        pullToRefresh = false
                                    }
                                    
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
                                                
                                                Text(overlayMessage)
                                                    .font(.custom("Inter-SemiBold", size: 18))
                                                    .foregroundColor(ringColor)
                                                    .padding(.horizontal,10)
                                                    .id(overlayMessage)
                                                    .transition(.opacity)
                                                    .animation(.easeInOut(duration: 0.25), value: overlayMessage)
                                                
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .transition(.opacity)
                                        .ignoresSafeArea()
                                        .zIndex(10)
                                        
                                    }
                                }
                                
                            }
                        }
                        
                        // Digital Key Tab end
                        
                        else if selectedTab == 1 && hasRemoteAccess
                        {
                            
                            if deviceVM.standaloneControllerList.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "wifi.slash")
                                        .font(.system(size: 42))
                                        .foregroundColor(.gray)
                                    
                                    Text("No Remote Access Doors")
                                        .font(.custom("Inter-SemiBold", size: 18))
                                        .foregroundColor(.white)
                                    
                                    Text("You do not have any doors available for remote unlocking.")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .transition(.opacity)
                                .padding(.horizontal,10)
                            }
                            
                            else
                            {
                                // Remote Access Tab
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        ForEach(deviceVM.standaloneControllerList) { door in
                                            RemoteDoorCardView(
                                                door: door,
                                                activeDoorKey: $activeDoorKey,
                                                mqttResult: $remoteMqttResult,
                                                isBluetoothOn: .constant(bleManager.isBluetoothOn),
                                                showBluetoothAlert: $showBluetoothAlert,
                                                onRemoteOpen: {
                                                    activeDoorKey = door.key
                                                    handleRemoteOpen(for: door)
                                                },
                                                onBleOpen: {
                                                    activeDoorKey = door.key
                                                    handleBLEOpen(for: door)
                                                },
                                                canOpenDoor: {
                                                        isWithinAccessWindow()
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                }
                                .id("remote-tab-\(selectedTab)")
                                    .transition(.opacity)
                                .refreshable{
                                    pullToRefresh = true
                                    await deviceVM.refreshDeviceDetails()
                                    pullToRefresh = false
                                    
                                }
                            }
                        }
                        
                    }.animation(.easeInOut(duration: 0.6), value: selectedTab)
                }
                
            }.frame(maxHeight: .infinity, alignment: .top)
            
            
            
            if deviceVM.isLoading && !pullToRefresh{
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
           
            await deviceVM.fetchDeviceDetailsIfNeeded()
            //            if !deviceVM.issuccess && deviceVM.errorMessage != ""{
            //                doorStorage.clearDoors()          // sets hasResolvedDoors = false ❌ (we’ll fix below)
            //                doorStorage.hasResolvedDoors = true
            //                showDoorErrorAlert = true
            //            }
          
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
            
        }
        
        .onAppear {
           // startFetchServerTime()
            // Load access flags from UserDefaults
            hasDigitalKeyAccess = UserDefaults.standard.bool(forKey: "digital_access")
            hasRemoteAccess = UserDefaults.standard.bool(forKey: "remote_access")
            
            
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
            
            doorManager.clearDoorEvent()
        }
        .onChange(of: deviceVM.errorMessage) { message in
            guard !message.isEmpty else { return }
            
            doorStorage.clearDoors()
            doorStorage.hasResolvedDoors = true
            showDoorErrorAlert = true
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
               // startFetchServerTime()
                // Only restart if view is still visible
                guard isViewVisible else {
                    print("⚠️ View is not visible. Skipping BLE restart.")
                    return
                }
                
                guard selectedTab == 0 else {
                    print("🚫 Remote Access tab active — BLE restart blocked")
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
            resetOverlayState()
            doorManager.clearDoorEvent()
            if newTab != 1 {
                //switch tab to reset remote tab view ui
                activeDoorKey = nil
                successDoorKey = nil
            }
            if newTab == 1 {
                stopAllScanningAndMonitoring()
                AceesMessage = "Remote access selected"
            } else {
                guard bleManager.isBluetoothOn else {
                    AceesMessage = "Bluetooth is Off. Please turn it on."
                    return
                }
                
                AceesMessage = "Preparing Scan..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startBLEIfPossible()
                }
            }
        }
        
        
        .onReceive(bleManager.$bleState) { state in
            switch state {
            case .poweredOff:
                print("🔴 Bluetooth OFF")
                AceesMessage = "Bluetooth is Off. Please turn it on."
                isScanningActive = false
                
            case .poweredOn:
                print("🟢 Bluetooth ON")
                AceesMessage = "Preparing Scan..."
                
                // Small delay ensures CoreBluetooth is fully ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startBLEIfPossible()
                }
                
            default:
                AceesMessage = "Checking Bluetooth status..."
            }
        }
        
        
        .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
            
            
            guard
                let info = notification.userInfo,
                let rawUserID = info["userID"],
                let rawcardNumber = info["cardnumber"],
                
                    let cardNumber = (rawcardNumber as? NSNumber)?.intValue
                    ?? (rawcardNumber as? Int)
                    ?? Int(rawcardNumber as? String ?? ""),
                
                    let userid = (rawUserID as? NSNumber)?.intValue
                    ?? (rawUserID as? Int)
                    ?? Int(rawUserID as? String ?? ""),
                
                    let deviceUserId = deviceVM.deviceDetails?.deviceUserId,
                let digitalCardString = deviceVM.deviceDetails?.digitalCardNumber,
                let digitalCardNumber = Int(digitalCardString),
                
                    (
                        (userid == 0 && cardNumber == 999_999_999) ||
                        (userid == 0 && cardNumber == 0) ||
                        (userid == deviceUserId) ||
                        (userid != 0 && cardNumber == digitalCardNumber) ||
                        
                        (userid == 0 && (info["sn"] as? String).map { deviceVM.allControllerSerials.contains($0)} == true)
                    )
            else {
                return
            }
            
            guard DoorManager.shared.shouldProcessMQTTEvent() else {
                print("🚫 MQTT ignored — outside 20s active window")
                return
            }
            
            didReceiveResponse = true
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
                
                if isRemoteUnlock{
                    guard let sn = sn, let doorId = doorId else { return }
                    
                    let key = "\(sn)_\(doorId)"
                    remoteMqttResult = RemoteMQTTResult(
                        doorKey: key,
                        isSuccess: true,
                        message: grantedBase
                    )
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    speakText(accessGrantedMessage + " - " + accessGreetingMessage)
                }else{
                    animateSuccess()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    AceesMessage =  accessGrantedMessage
                    speakText(accessGrantedMessage + " - " + accessGreetingMessage)
                    overlayMessage = accessGrantedMessage
                }
                
            }
            else if type == 19 { //ble unlock
                if isRemoteUnlock{
                    guard let sn = sn, let doorId = doorId else { return }
                    let key = "\(sn)_\(doorId)"
                    remoteMqttResult = RemoteMQTTResult(
                        doorKey: key,
                        isSuccess: true,
                        message: grantedBase
                    )
                    speakText(accessGrantedMessage)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }else{
                    animateSuccess()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    AceesMessage =  accessGrantedMessage
                    speakText(accessGrantedMessage + " - " + accessGreetingMessage)
                    overlayMessage = accessGrantedMessage
                }
            }
            else if type == 8 { //wifi unlock
                guard let sn = sn, let doorId = doorId else { return }
                let key = "\(sn)_\(doorId)"
                remoteMqttResult = RemoteMQTTResult(
                    doorKey: key,
                    isSuccess: true,
                    message: grantedBase
                )
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                speakText(accessGrantedMessage + " - " + accessGreetingMessage)
            }
            else if let type = type, deniedTypes.contains(type) {
                if isRemoteUnlock{
                    guard let sn = sn, let doorId = doorId else { return }
                    let key = "\(sn)_\(doorId)"
                    remoteMqttResult = RemoteMQTTResult(
                        doorKey: key,
                        isSuccess: false,
                        message: deniedBase
                    )
                    speakText(accessDeniedMessage)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }else{
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    AceesMessage = accessDeniedMessage
                    overlayMessage = accessDeniedMessage
                    speakText(accessDeniedMessage)
                    animateFailure()
                }
                
            }
            else {
                print("Ignored door event type:", type ?? -1)
                return
            }
            doorManager.closeMQTTWindow()
            doorManager.clearDoorEvent()
        }
        
        
        
        .onReceive(doorManager.$doorEvent.compactMap({ $0 })) { event in
            
            if isRemoteUnlock && selectedTab == 1 { return }
            
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
        
        .modernAlert(isPresented: $showDoorErrorAlert) {
            ModernAlertView(
                title: "Error!",
                message: deviceVM.errorMessage,
                isSuccess: false,
                buttonTitle: "OK"
            ) { showDoorErrorAlert = false
                
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
    }
    
    //check startdatetime  to  EnddateTime slot--------
    func isWithinAccessWindow() -> Bool {

        // 🔓 Offline → allow access
        if !network.hasInternet {
            print("⚠️ No internet — bypassing access window check")
            return true
        }

        guard
            let currentTime = serverTimeVM.localServerDate,
            let tzID = serverTimeVM.localTimeZoneID,
            let accessTZ = TimeZone(identifier: tzID),
            let startDateStr = deviceVM.startDate,
            let endDateStr = deviceVM.endDate,
            let startTimeStr = deviceVM.startTime,
            let endTimeStr = deviceVM.endTime
        else {
            print("⚠️ Missing access window data")
            return false
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = accessTZ

        // --- Date formatter ---
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = accessTZ

        // --- Time formatter ---
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = accessTZ

        guard
            let startDate = dateFormatter.date(from: startDateStr),
            let endDate = dateFormatter.date(from: endDateStr),
            let startTime = timeFormatter.date(from: startTimeStr),
            let endTime = timeFormatter.date(from: endTimeStr)
        else {
            print("❌ Invalid date/time format")
            return false
        }

        // Combine start date + start time
        guard let startDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: startTime),
            minute: calendar.component(.minute, from: startTime),
            second: 0,
            of: startDate
        ) else { return false }

        // Combine end date + end time
        guard let endDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: endTime),
            minute: calendar.component(.minute, from: endTime),
            second: 59,
            of: endDate
        ) else { return false }

        // 🔍 Debug
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = accessTZ

        print("🧭 Access Window:",
              df.string(from: startDateTime),
              "→",
              df.string(from: endDateTime))

        print("🕒 Current Time:",
              df.string(from: currentTime))

        //  SINGLE comparison (correct)
        return currentTime >= startDateTime && currentTime <= endDateTime
    }


//check date range and also time slot--------
//    func isWithinAccessWindow() -> Bool {
//
//        if !network.hasInternet {
//            print("⚠️ No internet — bypassing access window check")
//            return true
//        }
//
//        guard
//            let currentTime = serverTimeVM.localServerDate,
//            let localTZID = serverTimeVM.localTimeZoneID,
//            let accessTZ = TimeZone(identifier: localTZID),
//            let startDateStr = deviceVM.startDate,
//            let endDateStr = deviceVM.endDate,
//            let startTimeStr = deviceVM.startTime,
//            let endTimeStr = deviceVM.endTime
//        else {
//            print("⚠️ Missing access window data")
//            return false
//        }
//
//        var calendar = Calendar(identifier: .gregorian)
//        calendar.timeZone = accessTZ
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.timeZone = accessTZ
//
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateFormat = "HH:mm"
//        timeFormatter.timeZone = accessTZ
//
//        guard
//            let startDate = dateFormatter.date(from: startDateStr),
//            let endDate = dateFormatter.date(from: endDateStr),
//            let startTime = timeFormatter.date(from: startTimeStr),
//            let endTime = timeFormatter.date(from: endTimeStr)
//        else {
//            print("❌ Invalid date/time format")
//            return false
//        }
//
//        //  Date range check
//        let isDateValid =
//            currentTime >= startDate &&
//            currentTime <= endDate
//
//        // Time window check (daily)
//        let now = calendar.dateComponents([.hour, .minute], from: currentTime)
//        let currentMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
//
//        let startMinutes =
//            calendar.component(.hour, from: startTime) * 60 +
//            calendar.component(.minute, from: startTime)
//
//        let endMinutes =
//            calendar.component(.hour, from: endTime) * 60 +
//            calendar.component(.minute, from: endTime)
//
//        let isTimeValid =
//            currentMinutes >= startMinutes &&
//            currentMinutes <= endMinutes
//
//        print("🧭 Date valid:", isDateValid)
//        print("⏰ Time valid:", isTimeValid)
//
//        return isDateValid && isTimeValid
//    }
    

    
    private func resetOverlayState() {
        animationResetTask?.cancel()
        isOpening = false
        progress = 0
        ringColor = .white
        lockIcon = "lock.fill"
        overlayMessage = ""
        isUnauthorise = false
        isRemoteUnlock = false
        AceesMessage = "Walk closer to the door."
    }

    
    private func startBLEIfPossible() {
        guard isViewVisible else { return }
        guard selectedTab == 0 else { return }
        guard hasDigitalKeyAccess else { return }
        guard bleManager.isBluetoothOn else { return }
        
        print("🟢 Starting BLE scanning")
        
        bleManager.startContinuousScanning()
        isScanningActive = true
        monitorAndAutoOpenNearbyDoor()
    }
    
    
    
    private func handleRemoteOpen(for door: RemoteDoorItem) {
        DoorManager.shared.activateMQTTWindow()
        isRemoteUnlock = true
        MQTTManager.shared.sendOpenDoorCommand(
            to: door.serial,
            doorID: Int32(door.doorNumber),
            duration: 5
        )
        
    }
    
    
    private func handleBLEOpen(for door: RemoteDoorItem) {
        print("📡 BLE open tapped for:", door.doorName)
        
        // Ensure BLE is on
        guard bleManager.isBluetoothOn else {
            showBluetoothAlert = true
            return
        }
        
        DoorManager.shared.activateMQTTWindow()
        isRemoteUnlock = true
        // Open via BLE
        guard let sensor = door.sensorDetails else {
            print("❌ Sensor details missing for door:", door.id)
            return
        }

        doorManager.openSelectedDoor(sensor)
        
    }
    
    
    private var DoorTabSection: some View {
        VStack(spacing: 0) {
            HStack {
                if hasDigitalKeyAccess && hasRemoteAccess {
                    Button(action: { withAnimation { selectedTab = 0 } }) {
                        Text("Digital Access")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 0 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: { withAnimation { selectedTab = 1 } }) {
                        Text("Remote Access")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 1 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                //                if hasRemoteAccess {
                //
                //                }
            }
            .padding(.horizontal, 15)
            .padding(.top,(hasDigitalKeyAccess && hasRemoteAccess) ? 15 : 0)
            
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
                    //                    Rectangle()
                    //                        .fill(Color.white)
                    //                        .frame(width: UIScreen.main.bounds.width - 40, height: 2)
                    //                        .animation(.easeInOut(duration: 0.07), value: selectedTab)
                    //                        .padding(.horizontal,20)
                }
            }
            .padding(.top, 10)
            //.padding(.bottom, 10)
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
        prefix + grantedBase
        
        accessDeniedMessage =
        prefix + deniedBase
        
        accessUnAuthorizedMessage =
        prefix + unauthorizedBase
        
        remoteAccessMessage =
        prefix + "Door Unlocked!"
    }
    
    
    func animateOpeningStart() {
        
        // Cancel previous reset (important)
        animationResetTask?.cancel()
        didReceiveResponse = false
        
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
        //scheduleReset()
        scheduleTimeoutCheck()
    }
    func scheduleTimeoutCheck() {
        animationResetTask?.cancel()

        let task = DispatchWorkItem {
            // ❌ No response received in 5 sec
            guard !didReceiveResponse else { return }

            withAnimation(.easeInOut(duration: 0.3)) {
                ringColor = .red
                lockIcon = "xmark"
                overlayMessage = "No response received from the door"
                isOpening = false
                progress = 1.0
            }

            // Reset after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                resetOverlayState()
            }
        }

        animationResetTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: task)
    }

    func animateSuccess() {
        
        animationResetTask?.cancel()
        isRemoteUnlock = false
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .green
            lockIcon = "checkmark"
            isOpening = true
            progress = 1.0
        }
        scheduleReset()
    }
    
    // Failure → red, then reset
    func animateFailure() {
        animationResetTask?.cancel()
        isRemoteUnlock = false
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .red
            lockIcon = "xmark"
            isOpening = false
            progress = 1.0
            // overlayMessage = isRemoteUnlock ? "Remote Unlock Failed" : accessDeniedMessage
            
        }
        scheduleReset()
    }
    
    func animateFailureOutSideTime() {
        animationResetTask?.cancel()
        isRemoteUnlock = false
        withAnimation(.easeInOut(duration: 0.3)) {
            ringColor = .red
            lockIcon = "clock.badge.exclamationmark"
            isOpening = false
            progress = 1.0
            // overlayMessage = isRemoteUnlock ? "Remote Unlock Failed" : accessDeniedMessage
            
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: task)
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
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isScanningActive = false
                bleManager.stopScanning()
                bleManager.stopMonitoringDevice()
                timer.invalidate()
                rssiTimer = nil
                
                guard isWithinAccessWindow() else {
                    print("⛔ Outside allowed time window")

                    overlayMessage = "Access denied. Time Restricted."
                    AceesMessage = "Outside time period"

                    animateFailureOutSideTime()
                    speakText("Access denied. Time Restricted.")
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    
                    // Restart monitoring after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                        bleManager.startContinuousScanning()
                        isScanningActive = true
                        monitorAndAutoOpenNearbyDoor()
                    }

                    return
                }

                
                doorManager.openSelectedDoor(door)
                // ✅ Activate 20s MQTT window
                DoorManager.shared.activateMQTTWindow()
                
                
                // Restart monitoring after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
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

