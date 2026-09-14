//
//  SelectConfigureType.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 14/09/26.
//

import SwiftUI

enum DeviceConfigureMethod {
    case wifi
    case ethernet
}

struct SelectConfigureType: View {
    @Environment(\.dismiss) private var dismiss
    var selectedDevice: AssignDevice
    @State private var showInfo = false
    @State private var selectedMethod: DeviceConfigureMethod? = nil
    @State private var navigateToWiFiListView = false
    @State private var navigateToEthernetSetupView = false

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
                        // LEFT: Back Button
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

                        // RIGHT: Info Icon
                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        Text("Select Configuration Method")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    VStack(spacing: 15) {
                        Image("smartphone")
                            .resizable()
                            .frame(width: 33, height: 33)

                        Text("\(selectedDevice.modelName) (\(selectedDevice.serial))")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)

                        Text("Choose whether to configure this device using Wi-Fi or Ethernet.")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color(hex: "#6D717F"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.11))
                    )

                    VStack(alignment: .leading, spacing: 15) {
                        Text("How do you want to configure this device?")
                            .font(.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(.white)

                        ConfigureMethodRow(
                            title: "Wi-Fi",
                            systemImage: "wifi",
                            isSelected: selectedMethod == .wifi
                        ) {
                            selectedMethod = .wifi
                        }

                        ConfigureMethodRow(
                            title: "Ethernet",
                            systemImage: "cable.connector",
                            isSelected: selectedMethod == .ethernet
                        ) {
                            selectedMethod = .ethernet
                        }
                    }
                    .padding(.top, 10)

                    Spacer()

                    // Next button
                    Button(action: {
                        switch selectedMethod {
                        case .wifi:
                            navigateToWiFiListView = true
                        case .ethernet:
                            navigateToEthernetSetupView = true
                        default:
                            break
                        }
                    }) {
                        Text("Next")
                            .font(.custom("Inter-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(selectedMethod == nil ? Color.gray : Color.white)
                    .cornerRadius(12)
                    .disabled(selectedMethod == nil)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 10)
            }
        }
        .navigationDestination(isPresented: $navigateToWiFiListView) {
            SelectWiFiView(selectedDevice: selectedDevice)
        }
        .navigationDestination(isPresented: $navigateToEthernetSetupView) {
            EthernetSetupView(selectedDevice: selectedDevice)
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showInfo) {
            InfoScreenView(infoType: "device_config_info")
        }
    }
}

private struct ConfigureMethodRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 22)

                Text(title)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white)

                Spacer()

                Image(isSelected ? "radio-checked" : "radio-unchecked")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.18 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isSelected ? 0.3 : 0.12), lineWidth: 1)
            )
        }
    }
}
