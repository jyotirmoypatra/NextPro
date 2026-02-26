//
//  DeviceInfoDetailView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 15/01/26.
//


import SwiftUI

struct DeviceInfoDetailView: View {

    let deviceInfo: DeviceInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {

                // Background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 15) {

                    // MARK: - Header
                    headerView

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 25) {

                            // MARK: - BASIC INFO
                            sectionCard(title: "DEVICE DETAILS") {
                                infoRow("Device SN", deviceInfo.devSn)
                                infoRow("Device Type", "\(deviceInfo.devType)")
                                infoRow("Door No", deviceInfo.doorNo.map(String.init))
                                infoRow("Firmware Version", deviceInfo.firmwareVersion)
                                infoRow("Device Time", deviceInfo.deviceTime)
                            }

                            // MARK: - STATUS
                            sectionCard(title: "DEVICE STATUS") {
                                infoRow("Battery", batteryText)
                                infoRow("Users", deviceInfo.userCount.map(String.init))
                                infoRow(
                                    "Cards",
                                    "\(deviceInfo.cardCount ?? 0) / \(deviceInfo.maxCardCount ?? 0)"
                                )
                            }

                            // MARK: - DOOR SETTINGS
                            sectionCard(title: "DOOR SETTINGS") {
                                infoRow("Open Time", openTimeText)
                                infoRow("Wiegand Format", deviceInfo.wiegandFormat.map(String.init))
                                infoRow("Lock Switch", deviceInfo.lockSwitch.map(String.init))
                            }

                            // MARK: - NETWORK
                            sectionCard(title: "NETWORK") {
                                infoRow("Server", serverText)


                                infoRow("Wi-Fi Name", deviceInfo.wifiName)
                                //infoRow("Wi-Fi Password", maskedPassword)
                                infoRow("Wi-Fi Password", deviceInfo.wifiPassword)
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            print("received info = \(deviceInfo)")
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Back")
                        .font(.custom("Inter-SemiBold", size: 16))
                }
                .foregroundColor(.white)
            }

            Spacer()

            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(.white)
        }
        .overlay(
            Text("Device Information")
                .foregroundColor(.white)
                .font(.custom("Inter-Bold", size: 16))
        )
        .padding(.top, 10)
        .padding(.bottom, 10)
    }

    // MARK: - Section Card
    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 18) {

            Text(title)
                .foregroundColor(.white)
                .font(.custom("Inter-Medium", size: 15))

            VStack(spacing: 14) {
                content()
            }
        }
        .padding(15)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Info Row
    private func infoRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.custom("Inter-Medium", size: 15))

            Spacer()

            Text(value ?? "-")
                .foregroundColor(Color(hex: "#6D717F"))
                .font(.custom("Inter-Medium", size: 15))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Computed Helpers
    private var batteryText: String {
        guard let battery = deviceInfo.batteryPercent else { return "-" }
        return "\(battery)%"
    }

    private var openTimeText: String {
        guard let time = deviceInfo.openTime else { return "-" }
        return "\(time) sec"
    }

    private var maskedPassword: String {
        guard let pwd = deviceInfo.wifiPassword, !pwd.isEmpty else { return "-" }
        return String(repeating: "•", count: max(4, pwd.count))
    }
    
    private var serverText: String {
        guard let ip = deviceInfo.serverIP, !ip.isEmpty else {
            return "-"
        }

        guard let port = deviceInfo.serverPort else {
            return ip
        }

        return "\(ip):\(port)"
    }



}
