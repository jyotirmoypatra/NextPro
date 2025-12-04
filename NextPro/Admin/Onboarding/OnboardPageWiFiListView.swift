////
////  GetStartedView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 29/10/25.
////
//


import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension


struct OnboardPageWiFiListView: View {
    var selectedDeviceSN: String
    @State private var availableWiFiList: [String] = []
    @State private var navigateToWifiPassword = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWiFiIndex: Int? = nil
    @State private var isLoadingWiFi = true
    @State private var locationManager = CLLocationManager()

    var body: some View {
        ZStack {
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 25,) {

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
                    Text("Add Devices")
                        .foregroundColor(.white)
                        .font(.custom("Inter-Bold", size: 16))
                )
                .padding(.horizontal, 5)
                .padding(.top, 5)
                
               
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
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
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
                        .padding(.horizontal, 10)
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
                .cornerRadius(12)   // ← APPLY AFTER background
                .padding(.horizontal, 10)
                .disabled(selectedWiFiIndex == nil)
                .padding(.bottom, 30)
                .navigationDestination(isPresented: $navigateToWifiPassword) {
                    if let index = selectedWiFiIndex {
                        OnboardPageWifiPasswordView(
                            selectedDeviceSN: selectedDeviceSN,
                            selectedWiFiNetwork: availableWiFiList[index]
                        )
                    }
                }

               
            }
            .padding(.horizontal, 20)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)

        .onAppear {
            checkLocationPermissionAndFetchWiFi()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Wi-Fi Access
    private func checkLocationPermissionAndFetchWiFi() {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            loadConnectedWiFi()
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

#Preview {
    OnboardPageWiFiListView(selectedDeviceSN: "TEST_DEVICE_001")
}
