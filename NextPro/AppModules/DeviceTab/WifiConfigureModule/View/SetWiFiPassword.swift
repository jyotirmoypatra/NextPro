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
                
                VStack(spacing: 25) {
                    
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .overlay(
                        Text("Configure Device")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.top, 10)
                    
                    
                    // Password section
                    VStack(alignment: .leading, spacing: 6) {
                        // ... (Your password input code here)
                        HStack(spacing: 0) {
                            Text("Password")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                            Text(" *")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        
                        
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
                    .padding(.top, 30)
                    
                    
                    
                    // Loading / Status Message
                    if isConfiguring {
                        VStack{
                            RingSpinner(
                                ringColor: .yellow,
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
                
                // STEP 2: update loader
                loadingMessage = "Configuring device..."
                
                
                WiFiConfigureManager.configureDeviceWiFi(
                    device: selectedDevice,
                    wifiName: selectedWiFiNetwork,
                    wifiPassword: password,
                ) { success, message in
                    
                    Task { @MainActor in
                        
                        statusMessage = message
                        loadingMessage = message
                        // ⏱ 1 second delay HERE
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        
                        if success {
                            // navigateToSuccessView = true
                            //WiFi configured → now call API
                            loadingMessage = "Saving Device Configuration to Cloud..."
                            
                            await successVM.successConfig(
                                isSuccess: true,
                                deviceSerial: selectedDevice.serial,
                                wifiSSid: selectedWiFiNetwork,
                                wifiPass: password
                            )
                            
                            if successVM.success && successVM.errorMessage == nil {
                                isConfiguring = false
                                loadingMessage = ""
                                navigateToSuccessView = true
                                
                            } else {
                                isConfiguring = false
                                loadingMessage = ""
                                statusMessage = successVM.errorMessage ?? "Something went wrong"
                                showError = true
                            }
                            //  }
                        }else{
                            // WiFi failed
                            
                            isConfiguring = false
                            loadingMessage = ""
                            statusMessage = message
                            showError = true
                            
                            
                            
                        }
                    }
                }
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
