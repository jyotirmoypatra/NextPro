//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI
//
//struct OnboardPageWifiPasswordView: View {
//    var selectedDeviceSN: String
//    var selectedWiFiNetwork: String
//    @State private var showAdvanced = false
//    @State private var navigateToSuccessView = false
//    @Environment(\.dismiss) private var dismiss
//    @State private var password = ""
//    @State private var port = "6010"
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            // Background layers
//            Image("backgroundimg")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .ignoresSafeArea()
//
//            Color.black.opacity(0.8)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 25) {
//                // Fixed password section
//                VStack(alignment: .leading, spacing: 6) {
//                    HStack(spacing: 0) {
//                        Text("Password")
//                            .font(.custom("Inter-Medium", size: 16))
//                            .foregroundColor(.white)
//                        Text(" *")
//                            .font(.system(size: 14))
//                            .foregroundColor(.red)
//                    }
//
//                    ZStack(alignment: .leading) {
//                        if password.isEmpty {
//                            Text("Enter Password")
//                                .font(.custom("Inter-Regular", size: 16))
//                                .foregroundColor(Color.white.opacity(0.5))
//                                .padding(.leading, 12)
//                        }
//
//                        SecureField("", text: $password)
//                            .padding()
//                            .background(Color.white.opacity(0.15))
//                            .cornerRadius(8)
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.top, 30)
//                .padding(.horizontal, 30)
//                
//                // Advanced Settings dropdown
//                VStack(spacing: 12) {
//                    Button(action: {
//                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
//                            showAdvanced.toggle()
//                        }
//                    }) {
//                        HStack {
//                            Text("Advanced Settings")
//                                .foregroundColor(.white)
//                                .fontWeight(.medium)
//                            Image(systemName: showAdvanced ? "chevron.down" : "chevron.right")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    
//                    if showAdvanced {
//                        VStack(spacing: 25) {
//                            // Info box
//                            VStack(alignment: .center, spacing: 8) {
//                                HStack(spacing: 5) {
//                                    Text("Info")
//                                        .foregroundColor(.white)
//                                        .font(.custom("Inter-SemiBold", size: 16))
//                                    Image("info-empty")
//                                        .foregroundColor(.gray)
//                                        
//                                        .frame(width: 18,height: 18)
//                                }
//                                
//                                Text("Small Info text that explains the process")
//                                    .foregroundColor(.gray)
//                                    .font(.custom("Inter-Regular", size: 16))
//                                    .multilineTextAlignment(.center)
//                                    .padding(.horizontal, 20) // ⬅️ Increased padding for better centering
//                            }
//                            .padding(.vertical, 16)
//                            .padding(.horizontal, 20)
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white.opacity(0.1))
//                            )
//                            
//                            // Port selection
//                            // Port selection
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Port")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-SemiBold", size: 16))
//                                
//                                ZStack(alignment: .topLeading) {
//                                    // Always-visible dropdown button
//                                    HStack {
//                                        Text(port)
//                                            .foregroundColor(.white)
//                                        Spacer()
//                                        Image(systemName: "chevron.down")
//                                            .foregroundColor(.gray)
//                                    }
//                                    .padding()
//                                    .frame(height: 50)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.black.opacity(0.3))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(Color.gray.opacity(0.4))
//                                    )
//                                    .cornerRadius(8)
//                                    
//                                    // The popup menu (still a real SwiftUI Menu)
//                                    Menu {
//                                        VStack(spacing: 0) {
//                                            Button("6010") { port = "6010" }
//                                            Divider().background(Color.gray.opacity(0.3))
//                                            Button("6011") { port = "6011" }
//                                        }
//                                        .frame(width: 250)
//                                        .background(Color.black.opacity(0.9))
//                                        .cornerRadius(10)
//                                    } label: {
//                                        // Invisible tap area exactly on top of the visible button
//                                        Color.clear
//                                            .frame(height: 45)
//                                            .frame(maxWidth: .infinity)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 10)
//
//                        }
//                        .transition(.asymmetric(
//                            insertion: .scale(scale: 0.97).combined(with: .opacity).animation(.easeOut(duration: 0.18)),
//                            removal: .opacity.animation(.easeIn(duration: 0.1))
//                        ))
//                    }
//                }
//                .padding(.horizontal, 20)
//                
//                Spacer()
//                
//                // Bottom controls
//                HStack(spacing: 16) {
//                    Button(action: { dismiss() }) {
//                        Text("Prev")
//                            .font(.custom("Inter-SemiBold", size: 16))
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    
//                    Spacer()
//                    
//                    HStack(spacing: 8) {
//                        Circle().fill(Color.white.opacity(0.4)).frame(width: 8, height: 8)
//                        Circle().fill(Color.white).frame(width: 8, height: 8)
//                        Circle().fill(Color.white.opacity(0.4)).frame(width: 8, height: 8)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: { navigateToSuccessView = true }) {
//                        Text("Next")
//                            .font(.custom("Inter-SemiBold", size: 16))
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    .navigationDestination(isPresented: $navigateToSuccessView) {
//                        SuccessConnctionView()
//                    }
//                }
//                .padding(.bottom, 30)
//                .padding(.horizontal)
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}




#Preview {
    OnboardPageWifiPasswordView(
        selectedDeviceSN: "TEST_DEVICE_001",
        selectedWiFiNetwork: "GYM 5G"
    )
}


import SwiftUI

struct OnboardPageWifiPasswordView: View {
    var selectedDeviceSN: String
    var selectedWiFiNetwork: String

    @State private var showAdvanced = false
    @State private var navigateToSuccessView = false
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var port = "6010"
    @State private var isConfiguring = false
    @State private var statusMessage = ""

    var body: some View {
        ZStack(alignment: .top) {
            // Background layers
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Fixed password section
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text("Password")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                        Text(" *")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("Enter Password")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.white.opacity(0.5))
                                .padding(.leading, 12)
                        }

                        SecureField("", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                
                // Advanced Settings dropdown
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            showAdvanced.toggle()
                        }
                    }) {
                        HStack {
                            Text("Advanced Settings")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                            Image(systemName: showAdvanced ? "chevron.down" : "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if showAdvanced {
                        VStack(spacing: 25) {
                            VStack(alignment: .center, spacing: 8) {
                                HStack(spacing: 5) {
                                    Text("Info")
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-SemiBold", size: 16))
                                    Image("info-empty")
                                        .foregroundColor(.gray)
                                        .frame(width: 18,height: 18)
                                }
                                
                                Text("Small Info text that explains the process")
                                    .foregroundColor(.gray)
                                    .font(.custom("Inter-Regular", size: 16))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Port")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                                
                                ZStack(alignment: .topLeading) {
                                    HStack {
                                        Text(port)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.4))
                                    )
                                    .cornerRadius(8)
                                    
                                    Menu {
                                        VStack(spacing: 0) {
                                            Button("6010") { port = "6010" }
                                            Divider().background(Color.gray.opacity(0.3))
                                            Button("6011") { port = "6011" }
                                        }
                                    } label: {
                                        Color.clear
                                            .frame(height: 45)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.97).combined(with: .opacity).animation(.easeOut(duration: 0.18)),
                            removal: .opacity.animation(.easeIn(duration: 0.1))
                        ))
                    }
                }
                .padding(.horizontal, 20)
                
                // Loading / Status Message
                if isConfiguring {
                    ProgressView("Configuring Wi-Fi...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                
                // Bottom controls
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Text("Prev")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Circle().fill(Color.white.opacity(0.4)).frame(width: 8, height: 8)
                        Circle().fill(Color.white).frame(width: 8, height: 8)
                        Circle().fill(Color.white.opacity(0.4)).frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                    
                    Button(action: configureWiFi) {
                        Text(isConfiguring ? "Configuring..." : "Next")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .disabled(isConfiguring || password.isEmpty)
                    .navigationDestination(isPresented: $navigateToSuccessView) {
                        SuccessConnctionView()
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - WiFi Configuration
    private func configureWiFi() {
        guard !password.isEmpty else {
            statusMessage = "Please enter Wi-Fi password."
            return
        }

        isConfiguring = true
        statusMessage = "Configuring Wi-Fi for device..."

        WiFiConfigurator.configureDeviceWiFi(
            deviceSN: selectedDeviceSN,
            wifiName: selectedWiFiNetwork,
            wifiPassword: password
        ) { success, message in
            isConfiguring = false
            statusMessage = message
            
            if success {
                navigateToSuccessView = true
            }
        }
    }

}
