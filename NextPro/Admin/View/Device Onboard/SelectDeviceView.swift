//
//  OnboardPageDeviceScanView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI
import CoreBluetooth

struct SelectDeviceView: View {
    let devices: [AssignDevice]
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToWiFiListView = false
    @State private var selectedDevice: AssignDevice? = nil
    
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
                
                VStack(spacing: 25) {
                    HStack {
                        // LEFT: Back Button
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
                        
                        // RIGHT: Info Icon
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .overlay(
                        Text("Configure Device")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 5)
                    
                    VStack(spacing: 15) {
                        Image("socket-plug")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        
                        Text("Power on your device")
                            .font(.custom("Inter-Medium", size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Ensure the device is turned on before selecting it and tapping Next.")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color(hex: "#6D717F"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)   
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.11))
                    )
                    
                    // Device list (scrollable)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                          
                            if devices.isEmpty {
                                VStack(spacing: 14) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 44))
                                        .foregroundColor(.gray.opacity(0.8))

                                    Text("No Devices Found")
                                            .font(.custom("Inter-SemiBold", size: 18))
                                            .foregroundColor(.white)

                                        Text("No devices have been assigned to your account yet.\nPlease contact your administrator or try again later.")
                                            .font(.custom("Inter-Regular", size: 14))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 32)
                                }
                                .padding(.top,60)

                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .transition(.opacity)
                            } else {
                                ForEach(devices) { item in
                                    DeviceItemCardView(
                                        device: item,
                                        isSelected: selectedDevice?.serial == item.serial
                                    ) {
                                        // ✅ Store FULL DEVICE
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedDevice = item
                                        }
                                    }
                                }


                                
                            }
                        }
                      
                    }
                    
            
                    // Next button
                    Button(action: {
                        guard selectedDevice != nil else { return }
                        navigateToWiFiListView = true
                    }) {
                        Text("Next")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(selectedDevice == nil ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .disabled(selectedDevice == nil)
                    .padding(.bottom, 20)

                    
                    
                    
                    
                }
                .padding(.horizontal, 10)
            }
        }

        .navigationDestination(isPresented: $navigateToWiFiListView) {
            if let selectedDevice {
                SelectWiFiView(selectedDevice: selectedDevice)
            }
        }

        .navigationBarBackButtonHidden(true)
    }
}




struct DeviceItemCardView: View {
    let device: AssignDevice
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack(spacing: 16) {
                Image("smartphone")
                    .resizable()
                    .frame(width: 33, height: 33)

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.modelName)
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text("Serial No : \(device.serial)")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer()

                // ✅ CHECKBOX / RADIO
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(20)
            .background(
                isSelected
                ? Color.white.opacity(0.15)
                : Color.white.opacity(0.08)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                         Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
