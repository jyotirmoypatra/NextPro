//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI

struct OnboardPageWiFiListView: View {
    var selectedDeviceSN: String
    @State private var availableWiFiList: [String] = []
    @State private var navigateToWifiPassword = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWiFiIndex: Int? = nil
    @State private var isLoadingWiFi = true

    // Sample WiFi list (will be populated with actual connected WiFi)
    let wifi = [
        "GYM 5G",
        "GYM 2.4G",
        "GUEST HOUSE 5G"
    ]
    
    var body: some View {
        ZStack {
            // Background image
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
          

            // Black translucent overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                // Header Text
                VStack(spacing: 15) {
                    
                    
                    Image("wifi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                    
                    
                    Text("STEP 3 of 3")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("Connect to Wi-Fi, view available networks")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Go to the settings page and make sure your phone is connected to a 2.4ghz password-protected network on your phone")
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
              
  

                
                // Wi-Fi list / loader
                   if isLoadingWiFi {
                       VStack(spacing: 12) {
                           ProgressView("Scanning for Wi-Fi...")
                               .progressViewStyle(CircularProgressViewStyle(tint: .white))
                               .foregroundColor(.white)
                               .padding(.top, 30)
                       }
                       .frame(maxWidth: .infinity)
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
                   }


                Spacer() // pushes content to bottom
               
                // Bottom section
                HStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                       dismiss()
                    }) {
                        Text("Prev")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        
                    }
                
                    Spacer()
                    
                    // Page indicator dots
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                        }
                    
                    Spacer()
                    Button(action: {
                        navigateToWifiPassword = true
                    }) {
                        Text("Next")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()

                    }
                    .disabled(selectedWiFiIndex == nil)
                    .navigationDestination(isPresented: $navigateToWifiPassword) {
                        if let index = selectedWiFiIndex {
                            OnboardPageWifiPasswordView(
                                selectedDeviceSN: selectedDeviceSN,
                                selectedWiFiNetwork: availableWiFiList[index]
                            )
                        }
                    }

                   
                }
                .padding(.bottom, 30)
                
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            loadConnectedWiFi()
        }

        .navigationBarBackButtonHidden(true)
    }

    // MARK: - WiFi Loading

    private func loadConnectedWiFi() {
        // Simulate loading delay for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let connectedSSID = getWiFiSSID() {
                // Populate the list with the connected WiFi network
                self.availableWiFiList = [connectedSSID]
                print("✅ Connected to WiFi: \(connectedSSID)")
            } else {
                // If no WiFi detected, show a message
                self.availableWiFiList = []
                print("⚠️ No WiFi connection detected")
            }
            self.isLoadingWiFi = false
        }
    }

    private func getWiFiSSID() -> String? {
        #if canImport(SystemConfiguration)
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }

        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject],
                  let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            return ssid
        }
        #endif
        return nil
    }
}

#Preview {
    OnboardPageWiFiListView(selectedDeviceSN: "TEST_DEVICE_001")
}

