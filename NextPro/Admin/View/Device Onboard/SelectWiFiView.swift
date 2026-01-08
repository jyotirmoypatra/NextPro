////
////  OnboardPageWiFiListView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 29/10/25.
////
//


import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension


struct SelectWiFiView: View {
    var selectedDevice: AssignDevice
    @State private var availableWiFiList: [String] = []
    @State private var navigateToWifiPassword = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWiFiIndex: Int? = nil
    @State private var isLoadingWiFi = true
    @State private var locationManager = CLLocationManager()
    @State private var locationDelegate: CLLocationDelegate?

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
                    } else if availableWiFiList.isEmpty {
                        Text("No Wi-Fi networks found.")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 20)
                    } else {
                        ScrollView(showsIndicators: false) {
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
                                            .onTapGesture {
                                                selectedWiFiIndex = index
                                            }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                }
                            }
                           
                            .padding(.vertical, 10)
                        }
                        .refreshable {
                            checkLocationPermissionAndFetchWiFi() // 🔄 Refresh Wi-Fi list on swipe down
                        }
                    }
                    
                    Spacer()
                    
                    
                    
                    Button {
                        navigateToWifiPassword = true
                    } label: {
                        Text("Next")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(selectedWiFiIndex == nil ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .disabled(selectedWiFiIndex == nil)
                    .padding(.bottom, 10)
                    .navigationDestination(isPresented: $navigateToWifiPassword) {
                        if let index = selectedWiFiIndex {
                            SetWiFiPassword(
                                selectedDevice: selectedDevice,
                                selectedWiFiNetwork: availableWiFiList[index]
                            )
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 10)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)

        .onAppear {
            // Create delegate
            locationDelegate = CLLocationDelegate { status in
                handleLocationAuthStatus(status)
            }

            // Set delegate
            locationManager.delegate = locationDelegate

            // Check permission and load Wi-Fi if already authorized
            checkLocationPermissionAndFetchWiFi()
        }

        .navigationBarBackButtonHidden(true)
    }

    private func handleLocationAuthStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            loadConnectedWiFi() // ✅ Only called after user grants permission
        default:
            break
        }
    }

    private func checkLocationPermissionAndFetchWiFi() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // Ask user for permission
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted → load Wi-Fi
            loadConnectedWiFi()
        case .denied, .restricted:
            // No permission → show empty or message
            availableWiFiList = []
            isLoadingWiFi = false
        @unknown default:
            availableWiFiList = []
            isLoadingWiFi = false
        }
    }

    
    private func loadConnectedWiFi() {
        // Show loader briefly
        self.isLoadingWiFi = true
        
        NEHotspotNetwork.fetchCurrent { network in
            DispatchQueue.main.async {
                if let ssid = network?.ssid {
                    print("✅ Connected to WiFi via NEHotspotNetwork:", ssid)
                    self.availableWiFiList = [ssid]
                } else {
                    print("⚠️ No Wi-Fi network detected via NEHotspotNetwork")
                    self.availableWiFiList = []
                }
                self.isLoadingWiFi = false
            }
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
