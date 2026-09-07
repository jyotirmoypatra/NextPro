//
//  SetWiFiPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI
import CoreLocation

private struct LocationAlertPayload: Identifiable {
    let id = UUID()
    let message: String
}

struct SetWiFiPassword: View {
    var selectedDevice: AssignDevice
    var selectedWiFiNetwork: String
    
    @StateObject private var successVM = SuccessConfigViewModel()
    @State private var navigateToSuccessView = false
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var port = "6010"
    @State private var isConfiguring = false
    @State private var showPassword = false
    @State private var showError = false
    @State private var statusMessage = ""
    @State private var locationAlertPayload: LocationAlertPayload?
    @State private var loadingMessage = ""
    @StateObject private var locationManager = LocationManager()
    @State private var showInfo = false


    var body: some View {
        // Use GeometryReader to define a fixed, full-screen container
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background layers (fixed)
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        Text("Enter WiFi Password")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    VStack(spacing: 15) {
                        Image("key-active")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)

                        Text("Enter Wi-Fi Password")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Enter the password for the selected Wi-Fi network to allow your device to connect securely.")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color.white.opacity(0.6))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 6) {
                            Image(systemName: "wifi")
                                .foregroundColor(.white)

                            Text(selectedWiFiNetwork)
                                .font(.custom("Inter-SemiBold", size: 15))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.11))
                    )
                    // Password section
                    VStack(alignment: .leading, spacing: 6) {
                        // ... (Your password input code here)
                       
                        ZStack(alignment: .trailing) {
                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("Enter Password")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.leading, 14)
                                }
                                
                                if showPassword {
                                    TextField("", text: $password)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 14)
                                        .frame(height: 50)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("", text: $password)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 14)
                                        .frame(height: 50)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                            }
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(10)
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.trailing, 14)
                        }
                    }
                    .padding(.top, 10)
                    
                    
                    
                    // Loading / Status Message
                    if isConfiguring {
                        VStack{
                            RingSpinner(
                                ringColor: loaderColor,
                                lineWidth: 3,
                                size: 50
                            )
                            Text(loadingMessage)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }.padding(.top,20)
                    }
                    
                    Spacer() // Pushes everything above it to the top
                    
                    
                    Button {
                        configureWiFi()
                    } label: {
                        Text("Next")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(isConfiguring || password.isEmpty ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .padding(.bottom, 10)
                    .disabled(isConfiguring || password.isEmpty)
                    .navigationDestination(isPresented: $navigateToSuccessView) {
                         // Assuming SuccessConnctionView is defined elsewhere
                          SuccessConnctionView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .interactiveDismissDisabled(true)
                    }
                    
                } .padding(.horizontal, 10)
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .onAppear{
                
                locationManager.requestLocationAccess()
                
                print("WIFI-> \(selectedWiFiNetwork)")
                print("Device Serial-> \(selectedDevice)")
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom) // The key to stop resize
        .internetOverlay()
        .modernAlert(isPresented: $showError) {
            ModernAlertView(
                title: "Error!",
                message: statusMessage,
                isSuccess: false,
                buttonTitle: "OK"
            ) { showError = false }
        }
        .modernAlert(item: $locationAlertPayload) { payload in
            ModernAlertView(
                title: "Location Required",
                message: payload.message,
                isSuccess: false,
                buttonTitle: "Cancel",
                action: {
                    locationAlertPayload = nil
                },
                secondaryButtonTitle: "Open Settings",
                secondaryAction: {
                    openAppSettings()
                }
            )
        }
        .fullScreenCover(isPresented: $showInfo) {
            InfoScreenView(infoType: "device_config_info")
        }
    }
    /// Green while confirming the device is online, yellow for every other in-progress step.
    private var loaderColor: Color {
        loadingMessage == "Device is online." ? .green : .yellow
    }

    // MARK: - WiFi Configuration
    private func configureWiFi() {
        guard !password.isEmpty else {
            statusMessage = "Please enter Wi-Fi password."
            return
        }

        guard validateLocationRequirements() else { return }
        
        isConfiguring = true
        statusMessage = ""
        loadingMessage = "Getting your location..."
        
        
        // FLOW CONTROLLER
        locationManager.onLocationReady = {
            Task { @MainActor in

                // STEP 1: set location
                successVM.lat = locationManager.latitude
                successVM.long = locationManager.longitude
                successVM.address = locationManager.address

                await performConfigureAttempt(retriesLeft: 2)
            }
        }

        locationManager.onLocationError = { message in
            Task { @MainActor in
                isConfiguring = false
                loadingMessage = ""
                presentLocationAlert(
                    message.isEmpty ? "Unable to access location. Please check your settings and try again." : message
                )
            }
        }
        
        // 🚀 START LOCATION ONLY AFTER CLICK
        locationManager.startLocation()
    }

    @MainActor
    private func performConfigureAttempt(retriesLeft: Int) async {
        loadingMessage = "Configuring device..."

        let (wifiSuccess, wifiMessage): (Bool, String) = await withCheckedContinuation { continuation in
            WiFiConfigureManager.configureDeviceWiFi(
                device: selectedDevice,
                wifiName: selectedWiFiNetwork,
                wifiPassword: password
            ) { success, message in
                continuation.resume(returning: (success, message))
            }
        }

        statusMessage = wifiMessage
        loadingMessage = wifiMessage
        // ⏱ 1 second delay HERE
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        guard wifiSuccess else {
            if retriesLeft > 0 {
                await performConfigureAttempt(retriesLeft: retriesLeft - 1)
            } else {
                isConfiguring = false
                loadingMessage = ""
                statusMessage = wifiMessage
                showError = true
            }
            return
        }

        // WiFi configured → now call API
        loadingMessage = "Saving Device Configuration to Cloud..."

        await successVM.successConfig(
            isSuccess: true,
            deviceSerial: selectedDevice.serial,
            wifiSSid: selectedWiFiNetwork,
            wifiPass: password
        )

        guard successVM.success && successVM.errorMessage == nil else {
            if retriesLeft > 0 {
                await performConfigureAttempt(retriesLeft: retriesLeft - 1)
            } else {
                isConfiguring = false
                loadingMessage = ""
                statusMessage = successVM.errorMessage ?? "Something went wrong"
                showError = true
            }
            return
        }

        // SDK config + API call both succeeded → independently wait for the device to come
        // online. This step is NOT part of the SDK/API retry loop above — it runs once.
        loadingMessage = "Device is trying to connect to Wi-Fi..."

        let heartbeatReceived = await waitForDeviceHeartbeat(serial: selectedDevice.serial, timeout: 30)

        guard heartbeatReceived else {
            isConfiguring = false
            loadingMessage = ""
            statusMessage = "Unable to connect the device to Wi-Fi. Please verify the Wi-Fi password and ensure that the device’s Wi-Fi adapter and wiring are properly connected"
            showError = true
            return
        }

        loadingMessage = "Device is online."
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        isConfiguring = false
        loadingMessage = ""
        navigateToSuccessView = true
    }

    /// Waits (up to `timeout` seconds) for a `.deviceHeartbeatReceived` notification for `serial`,
    /// re-sending the heartbeat request every 7 seconds — the same polling frequency
    /// `AssignedDeviceViewModel.startHeartbeatLoop()` uses on the Device tab. Returns `true` if a
    /// heartbeat for this device arrived in time, `false` on timeout.
    private func waitForDeviceHeartbeat(serial: String, timeout: TimeInterval) async -> Bool {
        let pollInterval: TimeInterval = 7

        MQTTManager.shared.subscribeIfNeeded(sn: serial)

        return await withCheckedContinuation { continuation in
            let lock = NSLock()
            var hasResumed = false
            var observer: NSObjectProtocol?
            var pollTimer: Timer?
            var timeoutTimer: Timer?

            func finish(_ result: Bool) {
                lock.lock()
                let alreadyResumed = hasResumed
                hasResumed = true
                lock.unlock()

                guard !alreadyResumed else { return }
                if let observer {
                    NotificationCenter.default.removeObserver(observer)
                }
                pollTimer?.invalidate()
                timeoutTimer?.invalidate()
                continuation.resume(returning: result)
            }

            observer = NotificationCenter.default.addObserver(
                forName: .deviceHeartbeatReceived,
                object: nil,
                queue: .main
            ) { notification in
                guard let sn = notification.userInfo?["sn"] as? String, sn == serial else { return }
                finish(true)
            }

            // Initial send, then re-send every 7s until we get a heartbeat or hit the timeout.
            MQTTManager.shared.sendHeartbeatCheck(to: serial)

            pollTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { _ in
                MQTTManager.shared.sendHeartbeatCheck(to: serial)
            }

            timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
                finish(false)
            }
        }
    }

    private func validateLocationRequirements() -> Bool {
        guard locationManager.isLocationServicesEnabled else {
            presentLocationAlert(
                """
                Location Services are OFF
                
                Go to:
                Settings → Privacy & Security → Location Services → Turn ON
                """
            )
            return false
        }

        let status = locationManager.currentAuthorizationStatus

        if status == .notDetermined {
            locationManager.requestLocationAccess()
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            presentLocationAlert(
                """
                Location permission required
                
                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """
            )
            return false
        }

        guard locationManager.isPreciseLocationEnabled else {
            
            presentLocationAlert(
                """
                Precise Location is OFF
                
                Go to:
                Settings → Apps → Zlyx → Location → Turn ON Precise Location
                """
            )
            return false
        }

        return true
    }

    private func presentLocationAlert(_ message: String) {
        locationAlertPayload = LocationAlertPayload(message: message)
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
}
