

import SwiftUI
import CoreBluetooth
import CoreLocation
import Combine

struct DoorLocationAlertPayload: Identifiable {
    let id = UUID()
    let message: String
    var onPrimaryAction: (() -> Void)? = nil
}

struct RemoteMQTTResult: Equatable {
    let doorKey: String
    let isSuccess: Bool
    let message: String
}

/// Identifies the door action currently in flight (remote Wi-Fi, remote BLE, or
/// digital/BLE tap-to-open) so MQTT responses can be matched back to it without
/// juggling several separate "which door is active" state variables.
struct PendingDoorAction: Equatable {
    enum Source {
        case remoteWiFi
        case remoteBLE
        case digitalBLE
    }

    let source: Source
    let doorKey: String
    let serial: String
    let doorId: Int
    let doorName: String
}


struct RemoteDoorCardView: View {
    @Environment(\.scenePhase) private var scenePhase
    let door: RemoteDoorItem
    var isLocationCheckEnabled: Bool = false
    @Binding var pendingDoorAction: PendingDoorAction?
    @Binding var mqttResult: RemoteMQTTResult?
    @Binding var isBluetoothOn: Bool
    @Binding var isBluetoothPermissionDenied: Bool
    @Binding var showBluetoothAlert: Bool
    @Binding var showBluetoothPermissionAlert: Bool
    @Binding var showDeviceOfflineAlert: Bool
    let onRemoteOpen: () -> Void
    let onBleOpen: () -> Void
    let onNoInternet: () -> Void
    var onRemoteTimeout: () -> Void = {}
    
    let canOpenDoor: () -> Bool
    @State private var deniedBase = ""
    @State private var isDeniedVoiceEnabled = true

    // MARK: - Device power check (BLE proximity scan for door.serial)
    @StateObject private var deviceCheckBleManager = BLEManager()
    @State private var isCheckingDevice = false
    @State private var deviceScanTask: Task<Void, Never>?
    @State private var deviceScanTimeoutTask: Task<Void, Never>?
    @State private var deviceFound = false

    @State private var isResultSuccess: Bool = false
    @State private var statusMessage: String = ""

    
    @State private var wifiWaiting = false
    @State private var bleWaiting = false
    
    @State private var wifiSuccess = false
    @State private var bleSuccess = false
    
    
    @State private var wifiWaitTask: DispatchWorkItem?
    @State private var bleWaitTask: DispatchWorkItem?
    
    @State private var wifiSuccessTask: DispatchWorkItem?
    @State private var bleSuccessTask: DispatchWorkItem?

    // MARK: - Location check (Wi-Fi unlock only, same manager/flow as SetWiFiPassword)
    @StateObject private var locationManager = LocationManager()
    @Binding var locationAlertPayload: DoorLocationAlertPayload?
    @Binding var tooFarAlertPayload: DoorLocationAlertPayload?

    private var isAdmin: Bool {
       UserDefaults.standard.bool(forKey: "is_admin")
      //  true
    }
    
    private var hasWIFIAccess: Bool {
        UserDefaults.standard.bool(forKey: "remote_wifi")
       // true
    }
    private var hasBleAccess: Bool {
         UserDefaults.standard.bool(forKey: "remote_ble")
        //true
    }
    
    //
    
    // MARK: - Button State Helpers

    private var isWifiActive: Bool {
        wifiWaiting || wifiSuccess
    }

    private var isBleActive: Bool {
        bleWaiting || bleSuccess || isCheckingDevice
    }

    private var wifiOpacity: Double {
        if isWifiActive { return 0.7 }
        if isBleActive { return 0.2 }
        return 1.0
    }

    private var bleOpacity: Double {
        if isBleActive { return 0.7 }
        if isWifiActive { return 0.2 }
        return 1.0
    }

    private var wifiHitTesting: Bool {
        !(isWifiActive || isBleActive)
    }

    private var bleHitTesting: Bool {
        !(isBleActive || isWifiActive)
    }
    
    private var wifiBorderOpacity: Double {
        if isWifiActive { return 0.3 }   // active
        if isBleActive { return 0.11 }   // disabled by BLE
        return 0.3                       // idle
    }

    private var bleBorderOpacity: Double {
        if isBleActive { return 0.3 }    // active
        if isWifiActive { return 0.11 }  // disabled by WiFi
        return 0.3                       // idle
    }

    private var isStandAloneControllerTC434: Bool {
        door.doorType == "standalone_controller" && door.doorControllerType == "TC434"
    }
    
    private var isBleDisabledForDoor: Bool {
        isStandAloneControllerTC434 && door.doorNumber != 1
    }
    
    private var isStandAloneAllInOneM230: Bool {
        door.doorType == "all_in_one" && door.doorControllerType == "M230"
    }
    
    private var isStandAloneControllerBC220: Bool {
        door.doorType == "standalone_controller" && door.doorControllerType == "BC220"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            // LEFT : Door name
            VStack{
                Text(door.doorName)
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                if isCheckingDevice {
                    HStack {
                        RingSpinner(
                            ringColor: .yellow,
                            lineWidth: 1.5,
                            size: 13
                        )
                        Text("Checking device...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.yellow)
                            .padding(.top, 3)
                    }
                }

                if wifiWaiting || bleWaiting {
                    HStack {
                        RingSpinner(
                            ringColor: .yellow,
                            lineWidth: 1.5,
                            size: 13
                        )
                        Text("Verifying Please Wait...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.yellow)
                            .padding(.top, 3)
                    }
                }
                
                if wifiSuccess || bleSuccess {
                    HStack {
                        if isResultSuccess{
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .frame(width: 12, height: 12)
                            
                            Text(statusMessage)
                                .font(.custom("Inter-SemiBold", size: 13))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }else{
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .frame(width: 12, height: 12)
                            
                            Text(statusMessage)
                                .font(.custom("Inter-SemiBold", size: 13))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    }
                }
                
            }
            
            
            // RIGHT : Action buttons
            // RIGHT : Action buttons (fixed layout)
            HStack(spacing: 18) {
                
                  //  if hasWIFIAccess || isStandAloneControllerTC434 {
                    if hasWIFIAccess  {
                        ZStack {
                          //  if !wifiWaiting {
                                Button {
                                    
                                    guard NetworkManager.shared.hasInternet else {
                                        onNoInternet()
                                        return
                                    }

                                    pendingDoorAction = PendingDoorAction(
                                        source: .remoteWiFi,
                                        doorKey: door.key,
                                        serial: door.serial,
                                        doorId: door.doorNumber,
                                        doorName: door.doorName
                                    )



                                    guard canOpenDoor() else {
                                            showTimeRestrictedAndReset(isWifi: true)
                                            return
                                       }

                                    resetBleState()

                                    if isLocationCheckEnabled {
                                        startLocationCheckThenOpen()
                                    } else {
                                        startWifiWaiting()
                                        onRemoteOpen()
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: "wifi")
                                            .font(.system(size: 18))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess && isResultSuccess ? .green : wifiSuccess && !isResultSuccess ? .red : .white)
                                        
                                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess && isResultSuccess ? .green : wifiSuccess && !isResultSuccess ? .red : .white)
                                    }
                                }
                           // }
                            
                        }
                        .frame(width: 68, height: 58)
                        .opacity(wifiOpacity)
                        .allowsHitTesting(wifiHitTesting)

                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    wifiWaiting ? .yellow.opacity(wifiBorderOpacity) : wifiSuccess && isResultSuccess ? .green.opacity(wifiBorderOpacity) : wifiSuccess && !isResultSuccess ? .red.opacity(wifiBorderOpacity) : .white.opacity(wifiBorderOpacity),
                                   
                                    lineWidth: 1
                                )
                        )
                        
                    }
                    
                    if hasBleAccess {
                       // if !isStandAloneControllerTC434 {
                            
                            ZStack {
                               // if !bleWaiting {
                                    Button {

                                        guard !isBleDisabledForDoor else { return }
                                        
                                        // Priority: permission → power state → BLE operation.
                                        if isBluetoothPermissionDenied {
                                            showBluetoothPermissionAlert = true
                                            return
                                        }
                                        guard isBluetoothOn else {
                                                showBluetoothAlert = true
                                                return
                                            }
                                        pendingDoorAction = PendingDoorAction(
                                            source: .remoteBLE,
                                            doorKey: door.key,
                                            serial: door.serial,
                                            doorId: door.doorNumber,
                                            doorName: door.doorName
                                        )

                                        guard canOpenDoor() else {
                                            showTimeRestrictedAndReset(isWifi: false)
                                            return
                                        }

                                        checkDeviceSignalAndProceed()
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image((bleWaiting || isCheckingDevice) ? "bluetooth-yellow" : bleSuccess && isResultSuccess ? "bluetooth-green" :  bleSuccess && !isResultSuccess ? "bluetooth-red" : "bluetooth-white")
                                             .resizable()
                                             .frame(width: 22, height: 22)


                                            Text("Open Door")
                                                .font(.custom("Inter-Regular", size: 10))
                                                .foregroundColor((bleWaiting || isCheckingDevice) ? .yellow : bleSuccess && isResultSuccess ? .green : bleSuccess && !isResultSuccess ? .red : .white)
                                        }
                                    }
                               // }
                                
                            }
                            .frame(width: 68, height: 58)
//                            .opacity(bleOpacity)
//                            .allowsHitTesting(bleHitTesting)
                        
                        
                            .opacity(
                                isBleDisabledForDoor
                                    ? 0.0
                                    : bleOpacity
                            )
                            .allowsHitTesting(
                                !isBleDisabledForDoor && bleHitTesting
                            )
                            .disabled(isBleDisabledForDoor)
//                            .overlay {
//                                if isBleDisabledForDoor {
//                                    Image(systemName: "xmark")
//                                        .font(.system(size: 28, weight: .regular))
//                                        .foregroundColor(.red.opacity(0.2))
//                                }
//                            }

                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isBleDisabledForDoor
                                                        ? Color.white.opacity(0.0)
                                                        : bleWaiting ? .yellow.opacity(bleBorderOpacity) : bleSuccess && isResultSuccess ? .green.opacity(bleBorderOpacity) : bleSuccess && !isResultSuccess ? .red.opacity(bleBorderOpacity) : .white.opacity(bleBorderOpacity),
                                        lineWidth: 1
                                    )
                            )
                            
                            
                       // }
                    }
                
                
            }
            
        }
        .opacity(isDisabled ? 0.2 : 1.0)
        .allowsHitTesting(!isDisabled)
        
        
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        
        
        .onChange(of: mqttResult) { result in
            guard let result else { return }
            guard result.doorKey == door.key else { return }
            
            isResultSuccess = result.isSuccess
            statusMessage = result.message
            
            if wifiWaiting {
                showWifiSuccess()
            } else if bleWaiting {
                showBleSuccess()
            }
            
            DispatchQueue.main.async {
                mqttResult = nil
            }
        }
        .onAppear{
            deniedBase =
            UserDefaults.standard.string(forKey: "voice_denied")
            ?? "Access denied"

            isDeniedVoiceEnabled =
            UserDefaults.standard.object(forKey: "voice_enabled_denied") as? Bool ?? true
        }
        .onChange(of: scenePhase) { newPhase in
            guard newPhase == .background else { return }
            forceFinishOnBackground()
        }
    }
    private var isDisabled: Bool {
        guard let active = pendingDoorAction?.doorKey else { return false }
        return active != door.key
    }
    
    private func startWifiWaiting() {
        wifiWaiting = true
        wifiSuccess = false
        
        isResultSuccess = false
        statusMessage = ""
        
        wifiWaitTask?.cancel()
        
//        let task = DispatchWorkItem {
//            wifiWaiting = false
//            pendingDoorAction = nil
//        }
//
//        wifiWaitTask = task
//        DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: task)
        let task = DispatchWorkItem {
                // ⏱️ 7 sec timeout
                wifiWaiting = false
                wifiSuccess = true          // show result UI
                isResultSuccess = false     //failure
                statusMessage = "No response received from the door"
                onRemoteTimeout()

                // reset after 3 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resetWifiState()
                    pendingDoorAction = nil
                }
            }

            wifiWaitTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: task)
    }
    
    private func showWifiSuccess() {
        wifiWaitTask?.cancel()
        
        wifiWaiting = false
        wifiSuccess = true
        
        wifiSuccessTask?.cancel()
        
        let task = DispatchWorkItem {
            wifiSuccess = false
            DispatchQueue.main.async {
                pendingDoorAction = nil   // unlock other cards
            }
        }
        
        wifiSuccessTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    
    private func startBleWaiting() {
        bleWaiting = true
        bleSuccess = false
        isResultSuccess = false
            statusMessage = ""
        bleWaitTask?.cancel()
        
//        let task = DispatchWorkItem {
//            bleWaiting = false
//            pendingDoorAction = nil
//        }
//
//        bleWaitTask = task
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
        let task = DispatchWorkItem {
                // ⏱️ 10 sec timeout (BLE slower)
                bleWaiting = false
                bleSuccess = true           // show result UI
                isResultSuccess = false     // failure
                statusMessage = "No response received from the door"
                onRemoteTimeout()

                // reset after 3 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resetBleState()
                    pendingDoorAction = nil
                }
            }

            bleWaitTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
    }
    
    private func showBleSuccess() {
        bleWaitTask?.cancel()
        
        bleWaiting = false
        bleSuccess = true
        
        bleSuccessTask?.cancel()
        
        let task = DispatchWorkItem {
            bleSuccess = false
            DispatchQueue.main.async {
                pendingDoorAction = nil   // unlock other cards
            }
        }
        
        bleSuccessTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    private func resetWifiState() {
        wifiWaitTask?.cancel()
        wifiSuccessTask?.cancel()
        wifiWaiting = false
        wifiSuccess = false
        mqttResult = nil
    }
    
    private func resetBleState() {
        bleWaitTask?.cancel()
        bleSuccessTask?.cancel()
        bleWaiting = false
        bleSuccess = false
        mqttResult = nil
    }

    // MARK: - Location check (Wi-Fi unlock)

    private func startLocationCheckThenOpen() {
        guard validateLocationRequirements() else {
            pendingDoorAction = nil
            return
        }

        wifiWaiting = true
        wifiSuccess = false
        isResultSuccess = false
        statusMessage = ""

        locationManager.onLocationReady = {
            Task { @MainActor in
                proceedAfterLocationReady()
            }
        }

        locationManager.onLocationError = { message in
            Task { @MainActor in
                wifiWaiting = false
                pendingDoorAction = nil
                locationAlertPayload = DoorLocationAlertPayload(
                    message: message.isEmpty ? "Unable to access location. Please check your settings and try again." : message
                )
            }
        }

        locationManager.startLocation()
    }

    private func proceedAfterLocationReady() {
        guard
            let doorLat = door.latitude,
            let doorLong = door.longitude,
            let userLat = Double(locationManager.latitude),
            let userLong = Double(locationManager.longitude)
        else {
            startWifiWaiting()
            onRemoteOpen()
            return
        }

        let doorLocation = CLLocation(latitude: doorLat, longitude: doorLong)
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)
        let distance = userLocation.distance(from: doorLocation)

        guard distance <= 10 else {
            wifiWaiting = false
            wifiSuccess = true
            isResultSuccess = false
            statusMessage = "You are too far from the door"

            tooFarAlertPayload = DoorLocationAlertPayload(
                message: "You are too far from the door to unlock it.\nYou are \(Int(distance)) meters away — please move within 10 meters and try again.",
                onPrimaryAction: {
                    resetWifiState()
                    pendingDoorAction = nil
                }
            )
            return
        }

        startWifiWaiting()
        onRemoteOpen()
    }

    private func validateLocationRequirements() -> Bool {
        guard locationManager.isLocationServicesEnabled else {
            locationAlertPayload = DoorLocationAlertPayload(message: """
                Location Services are OFF

                Go to:
                Settings → Privacy & Security → Location Services → Turn ON
                """)
            return false
        }

        let status = locationManager.currentAuthorizationStatus

        if status == .notDetermined {
            locationManager.requestLocationAccess()
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            locationAlertPayload = DoorLocationAlertPayload(message: """
                Location permission required

                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """)
            return false
        }

        guard locationManager.isPreciseLocationEnabled else {
            locationAlertPayload = DoorLocationAlertPayload(message: """
                Precise Location is OFF

                Go to:
                Settings → Apps → Zlyx → Location → Turn ON Precise Location
                """)
            return false
        }

        return true
    }

    private func showTimeRestrictedAndReset(isWifi: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)

        statusMessage = deniedBase
        isResultSuccess = false

        if isWifi {
            wifiWaiting = false
            wifiSuccess = true
        } else {
            bleWaiting = false
            bleSuccess = true
        }

        speakAndReset(door.doorName + ". " + deniedBase + ". " + "Time Restricted", isWifi: isWifi)
    }

    private func speakAndReset(_ text: String, isWifi: Bool) {
        guard isDeniedVoiceEnabled else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if isWifi {
                    resetWifiState()
                } else {
                    resetBleState()
                }
                pendingDoorAction = nil
            }
            return
        }

        speakText(text) {
            if isWifi {
                resetWifiState()
            } else {
                resetBleState()
            }
            pendingDoorAction = nil
        }
    }

    // MARK: - Device power check (same pattern as SelectDeviceView)

    private func checkDeviceSignalAndProceed() {
        // Defense in depth: this manager's own state could still lag the outer
        // permission gate — never misreport a permission denial as a powered-off device.
        if deviceCheckBleManager.bleState == .unauthorized {
            showBluetoothPermissionAlert = true
            resetDeviceCheckState()
            return
        }
        if deviceCheckBleManager.bleState == .poweredOff {
            showBluetoothAlert = true
            resetDeviceCheckState()
            return
        }

        startDeviceScan(serial: door.serial)
    }

    private func startDeviceScan(serial: String) {
        isCheckingDevice = true
        deviceFound = false

        deviceScanTask?.cancel()
        deviceScanTimeoutTask?.cancel()

        deviceCheckBleManager.startScanning()

        deviceScanTask = Task { @MainActor in
            for await devices in deviceCheckBleManager.$devices.values {
                for peripheral in devices {
                    let name = (peripheral.name ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if name.contains(serial) {
                        deviceFound = true
                        stopDeviceScan()
                        openBleDoor()
                        return
                    }
                }
            }
        }

        deviceScanTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 6_000_000_000)

            guard !deviceFound else { return }

            stopDeviceScan()
            showDeviceOfflineAlert = true
            resetDeviceCheckState()
        }
    }

    private func stopDeviceScan() {
        deviceScanTask?.cancel()
        deviceScanTimeoutTask?.cancel()
        deviceScanTask = nil
        deviceScanTimeoutTask = nil

        deviceCheckBleManager.stopScanning()
        isCheckingDevice = false
    }

    /// Clears this card's transient checking/waiting state and releases the
    /// list-wide `pendingDoorAction` lock so other cards become tappable again
    /// as soon as the device-offline alert is shown.
    private func resetDeviceCheckState() {
        isCheckingDevice = false
        deviceFound = false
        resetWifiState()
        resetBleState()
        pendingDoorAction = nil
    }

    private func openBleDoor() {
        resetWifiState()
        startBleWaiting()
        onBleOpen()
    }

    /// Don't let a pending speech-completion or reset timer fire late once the app
    /// returns to foreground — that replayed this card's previous waiting/success UI
    /// and voice line. Finish everything immediately instead.
    private func forceFinishOnBackground() {
        guard wifiWaiting || bleWaiting || wifiSuccess || bleSuccess || isCheckingDevice else { return }

        let wasAwaitingResponse = wifiWaiting || bleWaiting

        SpeechManager.shared.stop()

        stopDeviceScan()
        resetWifiState()
        resetBleState()

        if pendingDoorAction?.doorKey == door.key {
            pendingDoorAction = nil
        }

        if wasAwaitingResponse {
            onRemoteTimeout()
        }
    }

}


