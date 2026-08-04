////
////  SelectWiFiView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 29/10/25.
////
//


import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension
import Network
import UIKit


struct SelectWiFiView: View {
    var selectedDevice: AssignDevice
    @State private var availableWiFiList: [String] = []
    @State private var navigateToWifiPassword = false
    @State private var selectedWiFiName = ""
    @State private var showLocationAlert = false
    @State private var locationAlertMessage = ""
    @State private var emptyStateMessage = "No Wi-Fi networks found."
    @State private var isEmptyStateError = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWiFiIndex: Int? = nil
    @State private var isLoadingWiFi = true
    @State private var locationManager = CLLocationManager()
    @State private var locationDelegate: CLLocationDelegate?
    @State private var willEnterForegroundObserver: NSObjectProtocol?
    @State private var showInfo = false
    @State private var pathMonitor: NWPathMonitor?
    @State private var lastWiFiConnected = false

    private var selectedWiFiNetwork: String? {
        guard let index = selectedWiFiIndex,
              availableWiFiList.indices.contains(index) else {
            return nil
        }
        return availableWiFiList[index]
    }

    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
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
                        Text("Choose Your WiFi Network")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    
                    
                    VStack(spacing: 15) {
                        Image("wifi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        
                        Text("Connect to Wi-Fi, view available networks")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Go to the settings page and make sure your phone is connected to a 2.4GHz password-protected network on your phone")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)   
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.11))
                    )
                    
                    // WiFi List or Loader
                    if isLoadingWiFi {
                        ProgressView("Scanning for Wi-Fi...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                            .frame(height: 200)
                    } else {
                        ScrollView(showsIndicators: false) {
                            if availableWiFiList.isEmpty {
                                Text(emptyStateMessage)
                                    .foregroundColor(isEmptyStateError ? .red : .white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 20)
                                    .frame(maxWidth: .infinity)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(availableWiFiList.indices, id: \.self) { index in
                                        HStack {
                                            Image("wifi")
                                                .resizable()
                                                .frame(width: 24, height: 24)

                                            Image("lock")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(availableWiFiList[index])
                                                    .font(.custom("Inter-SemiBold", size: 16))
                                                    .foregroundColor(.white)
                                            }

                                            Spacer()

                                            Image(systemName: selectedWiFiIndex == index ? "checkmark.square.fill" : "square")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(selectedWiFiIndex == index ? .white : .white.opacity(0.6))
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedWiFiIndex = index
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        .refreshable {
                            checkLocationPermissionAndFetchWiFi() // 🔄 Refresh Wi-Fi list on swipe down
                        }
                    }
                    
                    Spacer()
                    
                    
                    
                    Button {
                        guard let selectedWiFiNetwork else { return }
                        selectedWiFiName = selectedWiFiNetwork
                        navigateToWifiPassword = true
                    } label: {
                        Text("Next")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(selectedWiFiNetwork == nil ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .disabled(selectedWiFiNetwork == nil)
                    .padding(.bottom, 10)
                    .navigationDestination(isPresented: $navigateToWifiPassword) {
                        if !selectedWiFiName.isEmpty {
                            SetWiFiPassword(
                                selectedDevice: selectedDevice,
                                selectedWiFiNetwork: selectedWiFiName
                            )
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 10)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .alert("Location Required", isPresented: $showLocationAlert) {
//            Button("Open Settings") {
//                openAppSettings()
//            }
//            Button("Cancel", role: .cancel) {
//                showLocationAlert = false
//            }
//        } message: {
//            Text(locationAlertMessage)
//        }

        
        .modernAlert(isPresented: $showLocationAlert) {
            ModernAlertView(
                title: "Location Required",
                message: locationAlertMessage,
                isSuccess: false,
                buttonTitle: "Cancel",
                action: {
                    showLocationAlert = false
                },
                secondaryButtonTitle: "Open Settings",
                secondaryAction: {
                    openAppSettings()
                }
            )
        }
        
        .onAppear {
            // Create delegate
            locationDelegate = CLLocationDelegate { status in
                handleLocationAuthStatus(status)
            }

            // Set delegate
            locationManager.delegate = locationDelegate

            // Check permission and load Wi-Fi if already authorized
            checkLocationPermissionAndFetchWiFi()

            willEnterForegroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                checkLocationPermissionAndFetchWiFi()
            }

            startWiFiPathMonitor()
        }
        .onDisappear {
            if let observer = willEnterForegroundObserver {
                NotificationCenter.default.removeObserver(observer)
                willEnterForegroundObserver = nil
            }
            pathMonitor?.cancel()
            pathMonitor = nil
        }
        .onChange(of: availableWiFiList) { newValue in
            guard let selectedWiFiIndex else { return }

            if !newValue.indices.contains(selectedWiFiIndex) {
                self.selectedWiFiIndex = nil
            }
        }

        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showInfo) {
            InfoScreenView(infoType: "device_config_info")
        }
    }

    private func handleLocationAuthStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            checkLocationPermissionAndFetchWiFi()
        case .denied, .restricted:
            clearWiFiList(
                """
                Location permission required
                
                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """
            )
            presentLocationAlert(locationAlertMessage)
        default:
            break
        }
    }

    private func checkLocationPermissionAndFetchWiFi() {
        guard CLLocationManager.locationServicesEnabled() else {
            clearWiFiList(
                """
                Location Services are OFF
                
                Go to:
                Settings → Privacy & Security → Location Services → Turn ON
                """
            )
            presentLocationAlert(locationAlertMessage)
            return
        }

        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // Ask user for permission
            resetEmptyState()
            showLocationAlert = false
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            guard locationManager.accuracyAuthorization == .fullAccuracy else {
                clearWiFiList(
                    """
                    Precise Location is OFF
                    
                    Go to:
                    Settings → Apps → Zlyx → Location → Turn ON Precise Location
                    """
                )
                presentLocationAlert(locationAlertMessage)
                return
            }

            // Permission granted → load Wi-Fi
            showLocationAlert = false
            loadConnectedWiFi()
        case .denied, .restricted:
            // No permission → show empty or message
            clearWiFiList(
                """
                Location permission required
                
                Go to:
                Settings → Apps → Zlyx → Location → Allow While Using App
                """
            )
            presentLocationAlert(locationAlertMessage)
        @unknown default:
            clearWiFiList("No Wi-Fi networks found.", isError: false)
        }
    }

    
    private func loadConnectedWiFi() {
        // Show loader briefly
        self.isLoadingWiFi = true
        resetEmptyState()
        
        NEHotspotNetwork.fetchCurrent { network in
            DispatchQueue.main.async {
                if let ssid = network?.ssid {
                    print("✅ Connected to WiFi via NEHotspotNetwork:", ssid)
                    self.availableWiFiList = [ssid]
                    self.showLocationAlert = false
                    self.resetEmptyState()
                } else {
                    print("⚠️ No Wi-Fi network detected via NEHotspotNetwork")
                    self.clearWiFiList("No Wi-Fi networks found.", isError: false)
                }
                self.isLoadingWiFi = false
            }
        }
    }

    private func presentLocationAlert(_ message: String) {
        locationAlertMessage = message
        showLocationAlert = true
    }

    private func clearWiFiList(_ message: String, isError: Bool = true) {
        availableWiFiList = []
        selectedWiFiIndex = nil
        isLoadingWiFi = false
        emptyStateMessage = message
        isEmptyStateError = isError
        locationAlertMessage = message
    }

    private func resetEmptyState() {
        emptyStateMessage = "No Wi-Fi networks found."
        isEmptyStateError = false
    }

    private func startWiFiPathMonitor() {
        pathMonitor?.cancel()

        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        lastWiFiConnected = monitor.currentPath.status == .satisfied
        monitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                guard isConnected != self.lastWiFiConnected else { return }
                self.lastWiFiConnected = isConnected
                self.checkLocationPermissionAndFetchWiFi()
            }
        }
        monitor.start(queue: .main)
        pathMonitor = monitor
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }


}




class CLLocationDelegate: NSObject, CLLocationManagerDelegate {
    var onChange: (CLAuthorizationStatus) -> Void

    init(onChange: @escaping (CLAuthorizationStatus) -> Void) {
        self.onChange = onChange
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onChange(manager.authorizationStatus)
    }
}
