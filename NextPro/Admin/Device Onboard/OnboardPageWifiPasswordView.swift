//
//  OnboardPageWifiPasswordView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI



import SwiftUI

struct OnboardPageWifiPasswordView: View {
    var selectedDeviceSN: String
    var selectedWiFiNetwork: String

    @State private var showAdvanced = true
    @State private var navigateToSuccessView = false
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var port = "6010"
    @State private var isConfiguring = false
    @State private var showPassword = false
    @State private var statusMessage = ""
   
    
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
                        Text("Add Devices")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 5)
                    
                    
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
                                Group {
                                    if showPassword {
                                        TextField("Enter Password", text: $password)
                                            .textContentType(.password)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                            .frame(height: 35)
                                            .foregroundColor(.white)
                                    } else {
                                        SecureField("Enter Password", text: $password)
                                            .textContentType(.password)
                                            .disableAutocorrection(true)
                                            .autocapitalization(.none)
                                           .frame(height: 35)
                                           .foregroundColor(.white)
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                
                                // 👁️ Eye icon toggle
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 12)
                            }
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 10)
                    
                    // Advanced Settings dropdown
                    VStack(spacing: 12) {
                        // ... (Your Advanced Settings button and content)
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
                           // ... (Your Advanced content/Port picker)
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
                                .padding(.horizontal, 10)
                                
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
                                
                            }
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.97).combined(with: .opacity).animation(.easeOut(duration: 0.18)),
                                removal: .opacity.animation(.easeIn(duration: 0.1))
                            ))
                        }
                    }
                    .padding(.horizontal, 10)
                    
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
                    .cornerRadius(12)   // ← APPLY AFTER background
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)
                    .disabled(isConfiguring || password.isEmpty)
                    .navigationDestination(isPresented: $navigateToSuccessView) {
                         // Assuming SuccessConnctionView is defined elsewhere
                          SuccessConnctionView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .interactiveDismissDisabled(true)
                    }
                    
                }
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .onAppear{
                print("WIFI-> \(selectedWiFiNetwork)")
                print("Device Serial-> \(selectedDeviceSN)")
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom) // The key to stop resize
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
            wifiPassword: password,
            deviceModel: "BC434"
        ) { success, message in
            isConfiguring = false
            statusMessage = message
            
            if success {
                navigateToSuccessView = true
            }
        }
    }

}





#Preview {
    OnboardPageWifiPasswordView(
        selectedDeviceSN: "TEST_DEVICE_001",
        selectedWiFiNetwork: "GYM 5G"
    )
}
