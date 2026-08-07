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
    @EnvironmentObject private var notificationCountVM: NotificationCountViewModel
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var mqttManager = MQTTManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @StateObject private var deviceVM = DeviceDetailsViewModel()
    @StateObject private var doorManager = DoorManager.shared
    @StateObject private var bleManager = BLEManager()
    @StateObject private var serverTimeVM = ServerTimeService.shared
    @State private var pollingTask: Task<Void, Never>?
    @State private var animateWave = false
    @State private var showBluetoothAlert = false
    @State private var showBluetoothPermissionAlert = false
    @State private var isAutoOpenEnabled = false
    @State private var progress: CGFloat = 0.0
    @State private var isOpening = false
    @State private var ringColor: Color = .white
    @State private var lockIcon: String = "lock.fill"
    @State private var rssiTimer: Timer?
    @State private var isScanningActive = false
    @State private var isBLERestarting = false
    @State private var isViewVisible = false
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
    
    @State private var isProcessingDoor = false
    
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
    
    @State private var showTimeSyncAlert = false
    @State private var offlineTimeCheckTimer: Timer?
    @State private var navigateToNotifications = false
    @ObservedObject private var notificationNav = NotificationNavigationManager.shared
    
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
                ZStack {
                    VStack{
                        TopHeaderView(
                            type: .welcome(
                                userName: deviceVM.deviceDetails?.userFullName ?? "",
                                isLoading: deviceVM.isLoading
                            ),
                            onBellTap: {
                                navigateToNotifications = true
                            }
                        )
                        .padding(.top, 10)
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
                                    
                                    ZStack {
                                        ScrollView(.vertical, showsIndicators: false){
                                            
                                            VStack{
                                                Spacer().frame(height: 20)
                                                
                                                //                                            if let date = serverTimeVM.localServerDate {
                                                //                                                Text(date.toReadableString(
                                                //                                                    format: "dd MMM yyyy, hh:mm a",
                                                //                                                    timeZoneID: serverTimeVM.localTimeZoneID
                                                //                                                ))
                                                //                                                .font(.custom("Inter-Regular", size: 14))
                                                //                                                .foregroundColor(.gray)
                                                //                                            }
                                                
                                                if !doorStorage.hasResolvedDoors {
                                                    VStack(spacing: 12) {
                                                        // ProgressView()
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
                                                    .padding(.top,80)
                                                }
                                                else {
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
                                                                VStack(alignment: .leading,spacing: 2) {
                                                                    //  Text(selectedCard?.userName ?? "")
                                                                    Text(deviceVM.deviceDetails?.userFullName ?? "")
                                                                        .font(.custom("Inter-Regular", size: 12))
                                                                        .foregroundColor(.gray)
                                                                   
                                                                }
                                                                
                                                                Spacer()
                                                                
                                                                VStack(alignment: .trailing, spacing: 2) {
                                                                    Text(maskCardNumber(deviceVM.deviceDetails?.digitalCardNumber ?? ""))
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
                                                
                                            }
                                            .padding(.horizontal,10)
                                            .padding(.bottom, 30)
                                            
                                            
                                        }
                                        .transition(.opacity)
                                        .refreshable{
                                            pullToRefresh = true
                                            
                                            if network.hasInternet {
                                                await deviceVM.fetchDeviceDetailsIfNeeded(force: true) // force API
                                            } else {
                                                await deviceVM.fetchDeviceDetailsIfNeeded() // load cache
                                            }
                                            
                                            pullToRefresh = false
                                        }
                                        
                                        if isOpening || progress > 0 || ringColor != .white {
                                            ZStack {
                                                // Full-screen black background
                                                Color.black.opacity(0.98)
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
                                
                                // Digital Key Tab end
                                
                                else if selectedTab == 1 && hasRemoteAccess
                                {
                                    
                                    
                                    // Remote Access Tab
                                    ScrollView(.vertical, showsIndicators: false) {
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
                                            .padding(.top,80)
                                        } else {
                                            VStack(alignment: .leading, spacing: 20) {
                                                ForEach(deviceVM.standaloneControllerList) { door in
                                                    RemoteDoorCardView(
                                                        door: door,
                                                        activeDoorKey: $activeDoorKey,
                                                        mqttResult: $remoteMqttResult,
                                                        isBluetoothOn: .constant(bleManager.isBluetoothOn),
                                                        isBluetoothPermissionDenied: .constant(bleManager.bleState == .unauthorized),
                                                        showBluetoothAlert: $showBluetoothAlert,
                                                        showBluetoothPermissionAlert: $showBluetoothPermissionAlert,
                                                        onRemoteOpen: {
                                                            activeDoorKey = door.key
                                                            handleRemoteOpen(for: door)
                                                        },
                                                        onBleOpen: {
                                                            activeDoorKey = door.key
                                                            handleBLEOpen(for: door)
                                                        },
                                                        onNoInternet: {
                                                            toastManager.show(
                                                                message: "Internet connection is required for Wi-Fi unlock.",
                                                                type: .error,
                                                                duration: 1.5
                                                            )
                                                        },
                                                        canOpenDoor: {
                                                            isWithinAccessWindow(accessGroups: door.accessGroups)
                                                        }
                                                    )
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.top, 20)
                                            .padding(.bottom, 20)
                                        }
                                    }
                                    .id("remote-tab-\(selectedTab)")
                                    .transition(.opacity)
                                    //                            .refreshable{
                                    //                                pullToRefresh = true
                                    //                                await deviceVM.refreshDeviceDetails()
                                    //                                pullToRefresh = false
                                    //
                                    //                            }
                                    
                                    .refreshable{
                                        pullToRefresh = true
                                        
                                        if network.hasInternet {
                                            await deviceVM.fetchDeviceDetailsIfNeeded(force: true) // force API
                                        } else {
                                            await deviceVM.fetchDeviceDetailsIfNeeded() // load cache
                                        }
                                        
                                        pullToRefresh = false
                                    }
                                    
                                }
                                
                            }.animation(.easeInOut(duration: 0.6), value: selectedTab)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if showTimeSyncAlert {
                        TimeSyncOverlayView {
                            network.checkInternet()
                            
                            if network.hasInternet {
                                serverTimeVM.start(forceImmediate: true)
                                showTimeSyncAlert = false
                            }
                        }
                    }
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
            
        }.toast()
            .task{
                if network.hasInternet {
                    await deviceVM.fetchDeviceDetailsIfNeeded(force: true) // force API
                } else {
                    await deviceVM.fetchDeviceDetailsIfNeeded() // load cache
                }
                
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
                
                
                mqttManager.connect()
                
            }
        
            .onAppear {
                isViewVisible = true
                // Load access flags from UserDefaults
                hasDigitalKeyAccess = UserDefaults.standard.bool(forKey: "digital_access")
                hasRemoteAccess = UserDefaults.standard.bool(forKey: "remote_access")

                notificationCountVM.refreshUnreadCount()

                
                // Automatically select first available tab
                if hasDigitalKeyAccess {
                    selectedTab = 0
                } else if hasRemoteAccess {
                    selectedTab = 1
                }
                
                if !network.hasInternet {
                    startOfflineTimeObserver()
                }

                updateBLEState()

                if notificationNav.shouldOpenNotifications {
                    navigateToNotifications = true
                    notificationNav.shouldOpenNotifications = false
                }
            }
            .onChange(of: notificationNav.shouldOpenNotifications) { shouldOpen in
                guard shouldOpen else { return }
                navigateToNotifications = true
                notificationNav.shouldOpenNotifications = false
            }
            .onDisappear {
                print("🛑 DoorOpenView disappeared — stopping all BLE and timers")

                // Mark view as not visible
                isViewVisible = false

                stopBLE()

                doorManager.clearDoorEvent()

                offlineTimeCheckTimer?.invalidate()
                offlineTimeCheckTimer = nil
            }
            .onChange(of: deviceVM.errorMessage) { message in
                guard !message.isEmpty else { return }
                
                doorStorage.clearDoors()
                doorStorage.hasResolvedDoors = true
                showDoorErrorAlert = true
            }
            .onChange(of: network.hasInternet) { hasInternet in
                
                if hasInternet {
                    offlineTimeCheckTimer?.invalidate()
                    offlineTimeCheckTimer = nil
                    showTimeSyncAlert = false
                    
                    // Reconnect MQTT if it dropped while offline
                    mqttManager.reconnectIfNeeded()
                    
                    // Refresh server time immediately so access-window checks use fresh time
                    Task { await serverTimeVM.forceRefresh() }
                    
                    // Task { await deviceVM.fetchDeviceDetailsIfNeeded(force: true) }
                    
                } else {
                    startOfflineTimeObserver()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    print("🌙 App went to background — stopping BLE scanning and monitoring")
                    stopBLE(reason: "Preparing Scan..")

                case .active:
                    updateBLEState()

                case .inactive:
                    print("⏸️ App became inactive")
                    
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
                    stopBLE(reason: "Remote access selected")
                } else {
                    guard hasAvailableDoor else {
                        stopBLE()
                        return
                    }
                    guard bleManager.isBluetoothOn else {
                        handleBluetoothUnavailable()
                        return
                    }

                    AceesMessage = "Preparing Scan..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        startBLE()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didEnterBackgroundNotification
            )) { _ in
                print("🌙 didEnterBackground — force stop BLE")
                stopBLE(reason: "Preparing Scan..")
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification
            )) { _ in
                // Backup resume path: scenePhase's .active case can silently fail to fire
                // for a view nested this deep (TabView/NavigationStack), which is what left
                // scanning stuck on "Preparing Scan..." until a manual pull-to-refresh/tab
                // switch. This notification fires independently of scenePhase, so force a
                // full restart here regardless of whatever state the scenePhase path left us in.
                print("☀️ didBecomeActive — force restart BLE")
                bleManager.refreshAuthorizationStatus()
                guard isViewVisible, selectedTab == 0 else { return }
                restartBLE()
            }


            .onReceive(bleManager.$bleState) { state in
                switch state {
                case .poweredOff:
                    print("🔴 Bluetooth OFF")
                    AceesMessage = "Bluetooth is Off. Please turn it on."
                    isScanningActive = false

                case .unauthorized:
                    print("🚫 Bluetooth permission denied")
                    stopBLE()
                    showBluetoothPermissionAlert = true

                case .poweredOn:
                    print("🟢 Bluetooth ON")

                    // Small delay ensures CoreBluetooth is fully ready.
                    // Routed through restartBLE() (guarded by isBLERestarting) so this
                    // doesn't race with the didBecomeActive/updateBLEState restart paths
                    // and double-trigger "Preparing Scan..." / a duplicate scan start.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        restartBLE()
                    }
                    
                default:
                    AceesMessage = "Checking Bluetooth status..."
                }
            }
            .onChange(of: doorStorage.hasDoor) { _ in
                syncBLEWithDoorAvailability()
            }
            .onChange(of: doorStorage.hasResolvedDoors) { _ in
                syncBLEWithDoorAvailability()
            }
        
        
            .onReceive(NotificationCenter.default.publisher(for: .doorEventReceived)) { notification in
                
                DispatchQueue.main.async {
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
                            guard key == activeDoorKey else {
                                print("🚫 Ignoring MQTT event for a different door:", key)
                                return
                            }
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
                            AceesMessage = accessGrantedMessage
                            overlayMessage = accessGrantedMessage
                            speakAndReset(accessGrantedMessage + " - " + accessGreetingMessage) {
                                guard !self.isScanningActive else { return }
                                self.startBLE()
                            }
                        }
                        
                    }
                    else if type == 19 { //ble unlock
                        if isRemoteUnlock{
                            guard let sn = sn, let doorId = doorId else { return }
                            let key = "\(sn)_\(doorId)"
                            guard key == activeDoorKey else {
                                print("🚫 Ignoring MQTT event for a different door:", key)
                                return
                            }
                            remoteMqttResult = RemoteMQTTResult(
                                doorKey: key,
                                isSuccess: true,
                                message: grantedBase
                            )
                            speakText(accessGrantedMessage + " - " + accessGreetingMessage)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }else{
                            animateSuccess()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            AceesMessage = accessGrantedMessage
                            overlayMessage = accessGrantedMessage
                            speakAndReset(accessGrantedMessage + " - " + accessGreetingMessage) {
                                guard !self.isScanningActive else { return }
                                self.startBLE()
                            }
                        }
                    }
                    else if type == 8 { //wifi unlock
                        guard let sn = sn, let doorId = doorId else { return }
                        let key = "\(sn)_\(doorId)"
                        guard key == activeDoorKey else {
                            print("🚫 Ignoring MQTT event for a different door:", key)
                            return
                        }
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
                            guard key == activeDoorKey else {
                                print("🚫 Ignoring MQTT event for a different door:", key)
                                return
                            }
                            remoteMqttResult = RemoteMQTTResult(
                                doorKey: key,
                                isSuccess: false,
                                message: deniedBase
                            )
                            
                            if type == 42 || type == 43 {
                                speakText(accessDeniedMessage + ". " + "Time Restricted")
                            }else{
                                speakText(accessDeniedMessage)
                            }
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }else{
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            AceesMessage = accessDeniedMessage
                            overlayMessage = accessDeniedMessage
                            animateFailure()
                            let deniedSpeech = (type == 42 || type == 43)
                                ? accessDeniedMessage + ". " + "Time Restricted"
                                : accessDeniedMessage
                            speakAndReset(deniedSpeech) {
                                guard !self.isScanningActive else { return }
                                self.startBLE()
                            }
                        }
                        
                    }
                    else {
                        print("Ignored door event type:", type ?? -1)
                        if isRemoteUnlock {
                            guard let sn = sn, let doorId = doorId else { return }
                            let key = "\(sn)_\(doorId)"
                            guard key == activeDoorKey else {
                                print("🚫 Ignoring MQTT event for a different door:", key)
                                return
                            }
                            remoteMqttResult = RemoteMQTTResult(
                                doorKey: key,
                                isSuccess: false,
                                message: deniedBase
                            )
                            speakText(accessDeniedMessage)
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            AceesMessage = accessDeniedMessage
                            overlayMessage = accessDeniedMessage
                            animateFailure()
                            speakAndReset(accessDeniedMessage) {
                                guard !self.isScanningActive else { return }
                                self.startBLE()
                            }
                        }
                    }
                    doorManager.closeMQTTWindow()
                    doorManager.clearDoorEvent()
                }
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

//                BluetoothAlertView(
//                    onCancel: { showBluetoothAlert = false },
//                    openSettings: {
//                        if let url = URL(string: "App-Prefs:root=Bluetooth"),
//                           UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//                )
                
                BluetoothAlertView(onDismiss: {showBluetoothAlert = false})
            }
            .modernAlert(isPresented: $showBluetoothPermissionAlert) {
                ModernAlertView(
                    title: "Bluetooth Permission Required",
                    message: "Bluetooth permission is disabled. \nPlease enable it in iPhone Settings → Apps → ZYLX → Bluetooth.",
                    isSuccess: false,
                    buttonTitle: "Cancel",
                    action: {
                        showBluetoothPermissionAlert = false
                        AceesMessage = "Bluetooth permission is disabled. \nPlease enable it in iPhone Settings → Apps → ZYLX → Bluetooth."
                    },
                    secondaryButtonTitle: "Open Settings",
                    secondaryAction: {
                        showBluetoothPermissionAlert = false
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $navigateToNotifications) {
                Notifications()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
    }
    
    func isWithinAccessWindow(accessGroups: [AccessGroups]?) -> Bool {
        guard
            let currentDateTime = serverTimeVM.getEstimatedServerTime(),
            let tzID = serverTimeVM.localTimeZoneID,
            let accessTZ = TimeZone(identifier: tzID)
        else {
            DispatchQueue.main.async {
                showTimeSyncAlert = true
            }
            return false
        }

        guard let accessGroups, !accessGroups.isEmpty else {
            print("⛔ FAILED: No access groups found for this door")
            return false
        }

        for (index, accessGroup) in accessGroups.enumerated() {
            print("🔐 Checking access group \(index + 1):", accessGroup.accessGroupName ?? accessGroup.accessGroupId)

            if isWithinAccessWindow(
                currentDateTime: currentDateTime,
                accessTZ: accessTZ,
                accessGroup: accessGroup
            ) {
                print("✅ ACCESS GRANTED by access group:", accessGroup.accessGroupName ?? accessGroup.accessGroupId)
                return true
            }
        }

        print("⛔ FAILED: No access group matched")
        print("──────── ACCESS DENIED ────────")
        return false
    }

    private func isWithinAccessWindow(
        currentDateTime: Date,
        accessTZ: TimeZone,
        accessGroup: AccessGroups
    ) -> Bool {
        guard
            let startDateStr = accessGroup.startDate,
            let endDateStr = accessGroup.endDate,
            let timeSlots = accessGroup.timeSlots,
            let weekDaysStr = accessGroup.weekDays
        else {
            print("⛔ FAILED: Access group schedule details missing")
            return false
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = accessTZ

        let debugFormatter = DateFormatter()
        debugFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        debugFormatter.locale = Locale(identifier: "en_US_POSIX")
        debugFormatter.timeZone = accessTZ

        print("🕒 Current Time:", debugFormatter.string(from: currentDateTime))
        print("📅 Start Date:", startDateStr)
        print("📅 End Date:", endDateStr)
        print("📆 Allowed Weekdays:", weekDaysStr)
        print("⏰ Total Time Slots:", timeSlots.count)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = accessTZ

        guard
            let startDate = dateFormatter.date(from: startDateStr),
            let endDate = dateFormatter.date(from: endDateStr)
        else {
            print("❌ Invalid start/end date format")
            return false
        }

        let today = calendar.startOfDay(for: currentDateTime)
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        if !(today >= start && today <= end) {
            print("⛔ FAILED: Outside date range")
            print("👉 Today:", debugFormatter.string(from: today))
            print("👉 Valid Between:", debugFormatter.string(from: start),
                  "to", debugFormatter.string(from: end))
            return false
        }

        print("✅ Date range check passed")

        let iosWeekday = calendar.component(.weekday, from: currentDateTime)
        let backendWeekday = iosWeekday == 1 ? 7 : iosWeekday - 1

        let allowedWeekdays = parseWeekdays(from: weekDaysStr)

        print("📆 iOS Weekday:", iosWeekday)
        print("📆 Backend Weekday:", backendWeekday)
        print("📆 Allowed Weekday Array:", allowedWeekdays)

        if !allowedWeekdays.contains(backendWeekday) {
            print("⛔ FAILED: Weekday not allowed")
            return false
        }

        print("✅ Weekday check passed")

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = accessTZ

        let nowComponents = calendar.dateComponents([.hour, .minute], from: currentDateTime)
        let nowMinutes = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)

        print("🕒 Current Minutes:", nowMinutes)

        for (index, slot) in timeSlots.enumerated() {
            guard
                let startTime = timeFormatter.date(from: slot.start_time),
                let endTime = timeFormatter.date(from: slot.end_time)
            else {
                print("⚠️ Slot \(index + 1) invalid time format")
                continue
            }

            let startMinutes =
            calendar.component(.hour, from: startTime) * 60 +
            calendar.component(.minute, from: startTime)

            let endMinutes =
            calendar.component(.hour, from: endTime) * 60 +
            calendar.component(.minute, from: endTime)

            print("⏰ Slot \(index + 1):",
                  slot.start_time, "→", slot.end_time,
                  "| Minutes:", startMinutes, "→", endMinutes)

            if nowMinutes >= startMinutes && nowMinutes <= endMinutes {
                print("✅ SUCCESS: Time slot \(index + 1) matched")
                return true
            } else {
                print("❌ Slot \(index + 1) not matched")
            }
        }

        print("⛔ FAILED: No time slot matched")
        return false
    }

    private func parseWeekdays(from weekDaysStr: String) -> [Int] {
        weekDaysStr
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }
    

    
    func startOfflineTimeObserver() {
        
        guard offlineTimeCheckTimer == nil else { return }
        
        //FIRST CHECK IMMEDIATELY
        if !network.hasInternet {
            let time = serverTimeVM.getEstimatedServerTime()
            if time == nil {
                showTimeSyncAlert = true
                if selectedTab == 0 {
                    stopBLE()
                }
                return
            }
        }
        offlineTimeCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !network.hasInternet else { return }
            let time = serverTimeVM.getEstimatedServerTime()

            if time == nil {
                // Prevent repeating UI updates every second
                guard !showTimeSyncAlert else { return }
                DispatchQueue.main.async {
                    showTimeSyncAlert = true
                    if selectedTab == 0 {
                        stopBLE()
                    }
                }
            }
            else {

                DispatchQueue.main.async {

                    // Stop timer so it doesn't fire repeatedly
                    guard selectedTab == 0 else { return }
                    // If scanning already running → do nothing
                    guard !isScanningActive else { return }
                    guard hasAvailableDoor else {
                        stopBLE()
                        return
                    }
                    guard bleManager.isBluetoothOn else {
                        handleBluetoothUnavailable()
                        return
                    }
                    AceesMessage = "Preparing Scan..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        startBLE()
                    }


                }
            }
        }
    }
    
    
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
        
        // release processing lock
        isProcessingDoor = false
    }
    
    private var hasAvailableDoor: Bool {
        doorStorage.hasResolvedDoors && doorStorage.hasDoor
    }
    
    private func syncBLEWithDoorAvailability() {
        guard selectedTab == 0 else { return }
        guard hasDigitalKeyAccess else { return }
        guard doorStorage.hasResolvedDoors else { return }
        
        if doorStorage.hasDoor {
            startBLE()
        } else {
            stopBLE()
        }
    }

    // MARK: - BLE Lifecycle
    //
    // Every BLE start/stop/restart decision in this view funnels through the four methods
    // below instead of each call site re-implementing its own guard chain:
    //   - startBLE()      the one place that begins scanning
    //   - stopBLE(reason:) the one place that ends scanning
    //   - restartBLE()    stop, then retry-until-ready start (CoreBluetooth foreground recovery)
    //   - updateBLEState() "should scanning be running right now?" reconciliation, used by
    //                      any hook that just needs to resync (onAppear, scenePhase active,
    //                      door/bluetooth availability changes)

    /// THE single entry point for starting BLE scanning + nearby-door monitoring.
    /// Safe to call from anywhere — no-ops if a time-sync alert is blocking access, or if the
    /// view isn't visible, the digital-key tab isn't selected, there's no available door, or
    /// Bluetooth is off.
    private func startBLE() {
        guard !showTimeSyncAlert else {
            print("⛔ Time sync required — BLE start blocked")
            return
        }
        guard isViewVisible else { return }
        guard selectedTab == 0 else { return }
        guard hasDigitalKeyAccess else { return }
        guard hasAvailableDoor else {
            stopBLE()
            return
        }
        guard bleManager.isBluetoothOn else { return }

        print("🟢 Starting BLE scanning")

        bleManager.startContinuousScanning()
        isScanningActive = true
        monitorAndAutoOpenNearbyDoor()
    }

    /// Case 1 (permission denied/restricted) vs Case 2 (permission granted, hardware off) —
    /// routes to the correct feedback so callers never have to branch on this themselves.
    private func handleBluetoothUnavailable() {
        if bleManager.bleState == .unauthorized {
            showBluetoothPermissionAlert = true
        } else {
            AceesMessage = "Bluetooth is Off. Please turn it on."
        }
    }

    /// THE single entry point for stopping BLE scanning, monitoring, and the RSSI timer.
    /// Pass `reason` to show a specific status message; omit it to fall back to the same
    /// Bluetooth-state-based message every caller used to compute for itself.
    private func stopBLE(reason: String? = nil) {
        bleManager.stopContinuousScanning()
        bleManager.stopMonitoringDevice()
        bleManager.stopScanning()

        rssiTimer?.invalidate()
        rssiTimer = nil

        isScanningActive = false

        AceesMessage = reason ?? {
            if bleManager.bleState == .unauthorized {
                return "Bluetooth permission is disabled. \nPlease enable it in iPhone Settings → Apps → ZYLX → Bluetooth."
            }
            return bleManager.isBluetoothOn ? "Scanning paused" : "Bluetooth is Off. Please turn it on."
        }()
    }

    /// Re-evaluates whether BLE scanning should currently be running and reconciles state:
    /// stops it if it shouldn't be running, restarts it if it should be but has gone
    /// stale/inactive, or leaves it alone if everything already matches.
    private func updateBLEState() {
        guard isViewVisible else { return }
        guard selectedTab == 0 else { return }
        guard hasDigitalKeyAccess else { return }
        guard hasAvailableDoor else {
            stopBLE()
            return
        }

        if !bleManager.isBluetoothOn {
            isScanningActive = false
            return
        }

        if !isScanningActive || bleManager.devices.isEmpty {
            print("⚠️ BLE inactive, restarting")
            restartBLE()
        } else {
            print("✅ BLE already active, no restart needed")
        }
    }

    /// Stops, then retries `startBLE()` with progressively longer delays while CoreBluetooth
    /// recovers (e.g. after returning from the background, or a Bluetooth power-on event).
    /// `retryIndex` drives the recursive retry ladder — always call with the default (0) from
    /// the outside. Guarded by `isBLERestarting` so overlapping triggers (foreground
    /// notification + `bleState` publisher + scenePhase) never race into a duplicate ladder.
    private func restartBLE(retryIndex: Int = 0) {
        if retryIndex == 0 {
            guard !isBLERestarting else {
                print("⏭️ BLE restart already in progress — skipping duplicate trigger")
                return
            }
            guard bleManager.isBluetoothOn else {
                print("⛔ BLE restart skipped — Bluetooth is off")
                handleBluetoothUnavailable()
                return
            }
            print("🔄 Restarting BLE after foreground")
            isBLERestarting = true
            stopBLE(reason: "Preparing Scan...")
        }

        // Progressive delays: quick first try, then increasing waits as CoreBluetooth recovers
        let delays: [Double] = [0.15, 0.5, 1.0, 2.0, 3.0, 4.0]

        guard retryIndex < delays.count else {
            print("❌ BLE restart failed after all retries")
            if bleManager.isBluetoothOn {
                AceesMessage = "Preparing Scan..."
            } else {
                handleBluetoothUnavailable()
            }
            isBLERestarting = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delays[retryIndex]) {
            guard isViewVisible else {
                isBLERestarting = false
                return
            }
            guard selectedTab == 0 else {
                isBLERestarting = false
                return
            }
            guard hasDigitalKeyAccess else {
                isBLERestarting = false
                return
            }
            guard hasAvailableDoor else {
                stopBLE()
                isBLERestarting = false
                return
            }

            guard bleManager.isBluetoothOn else {
                print("⚠️ BLE not ready yet (attempt \(retryIndex + 1)/\(delays.count)), retrying...")
                restartBLE(retryIndex: retryIndex + 1)
                return
            }

            print("✅ Restarting BLE scan (attempt \(retryIndex + 1))")

            // Bluetooth is confirmed ready — hand off to the single "how to start
            // scanning" implementation instead of duplicating it here.
            startBLE()
            isBLERestarting = false

            print("✅ BLE fully restarted")
        }
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
            if bleManager.bleState == .unauthorized {
                showBluetoothPermissionAlert = true
            } else {
                showBluetoothAlert = true
            }
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
                        Text("Phone Tap")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 0 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: { withAnimation { selectedTab = 1 } }) {
                        Text("Remote")
                            .font(.custom("Inter-Bold", size: 15))
                            .foregroundColor(selectedTab == 1 ? .white : .gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
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
                }
            }
            .padding(.top, 10)
        }
    }
    
    
    private func updateVoiceMessages(for doorName: String?) {
        let cleanName = doorName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefix: String
        if let name = cleanName, !name.isEmpty {
            prefix = "\(name). "
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
        isProcessingDoor = true   // lock new scans
        
        withAnimation(.easeInOut(duration: 0.15)) {
            ringColor = .yellow
            lockIcon = "lock.fill"
            isOpening = true
            overlayMessage = "Verifying Please Wait..."
            progress = 0.0
        }
        withAnimation(.linear(duration: 0.2)) {
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
            
            withAnimation(.easeInOut(duration: 0.15)) {
                ringColor = .red
                lockIcon = "xmark"
                overlayMessage = "No response received from the door"
                isOpening = false
                progress = 1.0
            }
            
//            // Reset after 2 seconds
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                resetOverlayState()
//            }

            // Reset after 3 seconds — tracked via animationResetTask so a new
            // attempt starting in this window cancels THIS cleanup instead of
            // this cleanup later cancelling the new attempt's own timeout.
            let cleanupTask = DispatchWorkItem {
                resetOverlayState()
            }
            animationResetTask = cleanupTask
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: cleanupTask)
        }
        
        animationResetTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0, execute: task)
    }
    
    func animateSuccess() {
        didReceiveResponse = true
        animationResetTask?.cancel()
        isRemoteUnlock = false
        withAnimation(.easeInOut(duration: 0.15)) {
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
        withAnimation(.easeInOut(duration: 0.15)) {
            ringColor = .red
            lockIcon = "xmark"
            isOpening = false
            progress = 1.0
            
        }
        scheduleReset()
    }
    
    func animateFailureOutSideTime() {
        animationResetTask?.cancel()
        isRemoteUnlock = false
        withAnimation(.easeInOut(duration: 0.15)) {
            ringColor = .red
            lockIcon = "clock.badge.exclamationmark"
            isOpening = false
            progress = 1.0
            
        }
        scheduleReset()
    }
    
    func unauthorised() {
        animationResetTask?.cancel()
        isUnauthorise = true
        withAnimation(.easeInOut(duration: 0.15)) {
            ringColor = .orange
            lockIcon = "lock.fill"
            isOpening = false
            progress = 1.0
            overlayMessage = accessUnAuthorizedMessage
            
            
        }
        scheduleReset()
    }
    
    
    private func speakAndReset(_ text: String, onComplete: (() -> Void)? = nil) {
        speakText(text) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animationResetTask?.cancel()
                self.resetOverlayState()
                onComplete?()
            }
        }
    }

    func scheduleReset() {
        // Cancel any previous reset
        animationResetTask?.cancel()
        
        let task = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.15)) {
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
            // 🔓 allow next BLE scan
            isProcessingDoor = false
        }
        
        animationResetTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: task)
    }
    
    
    
    
    
    func monitorAndAutoOpenNearbyDoor() {
        AceesMessage = "Walk closer to the door"
        rssiTimer?.invalidate()
        rssiTimer = nil
        
        let bleManager = self.bleManager
        let doorStorage = self.doorStorage
        
        
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak bleManager, weak doorStorage] timer in
            
            guard
                isViewVisible,
                let bleManager = bleManager,
                let doorStorage = doorStorage
            else {
                timer.invalidate()
                return
            }
            guard doorStorage.hasResolvedDoors && doorStorage.hasDoor else {
                timer.invalidate()
                stopBLE()
                return
            }
            
            //  wait until current process finishes
            guard !isProcessingDoor else { return }
            let nearbyDevices = bleManager.devices.compactMap { peripheral -> (peripheral: CBPeripheral, rssi: Int)? in
                let rssi = bleManager.monitoredDeviceRSSI ?? bleManager.deviceLastRSSI[peripheral.identifier] ?? -100
                
                return (peripheral, rssi)
            }
            
            // Sort by strongest RSSI (closest)
            guard let closest = nearbyDevices.max(by: { $0.rssi < $1.rssi }) else { return }
            
            let name = closest.peripheral.name ?? ""
            let rssi = closest.rssi
            
            print("🎯 Closest device: \(name) with RSSI: \(rssi)")
            
            // Only act if RSSI is strong
            guard rssi > -37 && rssi < 0 else { return }
            
            if let door = doorStorage.doors.first(where: { name.contains($0.devSn) }) {
                // Authorized door
                print("🚪 Door nearby! Opening \(door.name)...")
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isScanningActive = false
                stopBLE()
                
                guard isWithinAccessWindow(accessGroups: door.accessGroups) else {
                    print("⛔ Outside allowed time window")
                    DispatchQueue.main.async {
                        overlayMessage = door.name + ". " + deniedBase
                        AceesMessage = deniedBase
                        animateFailureOutSideTime()
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        speakAndReset(door.name + ". " + deniedBase + ". Time Restricted") {
                            guard !isScanningActive else { return }
                            startBLE()
                        }
                    }
                    return
                }
                
                doorManager.openSelectedDoor(door)
                DoorManager.shared.activateMQTTWindow()

                // Fallback: restart if MQTT never fires (voice-completion path handles the normal case)
                DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
                    guard !isScanningActive else { return }
                    startBLE()
                }
            }
            else {
                //  Unauthorized Thimmo device
                print("🚫 Unauthorized Thimmo device nearby: \(name)")
                stopBLE()
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
                    speakAndReset(accessUnAuthorizedMessage) {
                        guard !isScanningActive else { return }
                        startBLE()
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

struct TimeSyncOverlayView: View {
    
    var retryAction: () -> Void
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(1.0)
            
            VStack(spacing: 18) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Time Sync Required")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)
                
                Text("Please connect to the internet to synchronize server time. Door access will remain disabled until time is synced.")
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("RETRY")
                            .font(.custom("Inter-Bold", size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,12)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 50)
            }
        }
    }
}
