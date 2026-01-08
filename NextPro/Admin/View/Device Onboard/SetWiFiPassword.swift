//
//  OnboardPageWifiPasswordView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI

struct SetWiFiPassword: View {
    var selectedDevice: AssignDevice
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
                            Text("You are almost there!")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }.padding(.top,20)
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
                print("WIFI-> \(selectedWiFiNetwork)")
                print("Device Serial-> \(selectedDevice)")
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
        //statusMessage = "Configuring Wi-Fi for device..."

        WiFiConfigureManager.configureDeviceWiFi(
            device: selectedDevice,
            wifiName: selectedWiFiNetwork,
            wifiPassword: password,
        ) { success, message in
            isConfiguring = false
            statusMessage = message
            
            if success {
                navigateToSuccessView = true
            }
        }
    }

}

