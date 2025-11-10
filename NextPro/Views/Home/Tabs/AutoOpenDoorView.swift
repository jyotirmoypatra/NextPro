//
//  AutoOpenDoorView.swift
//  NextPro
//
//  Auto-open door functionality that works like NFC - continuously monitors BLE RSSI
//  and automatically opens the door when signal strength is good enough.
//

import SwiftUI
import CoreBluetooth
import Combine

struct AutoOpenDoorView: View {
    let selectedDoor: DoorModel

    @StateObject private var doorManager = DoorManager.shared
    @StateObject private var bleManager = BLEManager()
    @State private var isMonitoring = false
    @State private var lastOpenAttempt: Date? = nil
    @State private var rssiThreshold = -60 // Configurable RSSI threshold (dBm)

    // Create device name for BLE monitoring (matches BLE advertisement name)
    private var deviceBLEName: String {
        // Door devices advertise as "XM-<devSn>"
        return "XM-\(selectedDoor.devSn)"
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 120, height: 120)

                            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }

                        Text("NFC-Style Door Opening")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Hold near door to auto-open")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Door Information Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "door.left.hand.open")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))
                            Text("Selected Door")
                                .font(.headline)
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.white.opacity(0.2))

                        VStack(spacing: 12) {
                            infoRow(label: "Name", value: selectedDoor.name)
                            infoRow(label: "Serial", value: selectedDoor.devSn)
                            infoRow(label: "Card", value: selectedDoor.cardno)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20)

                    // RSSI Monitoring Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: isMonitoring ? "wifi" : "wifi.slash")
                                .foregroundColor(isMonitoring ? .green : .red)
                                .font(.system(size: 24))
                            Text("Signal Strength")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            if isMonitoring {
                                Button(action: stopMonitoring) {
                                    Text("Stop")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.8))
                                        .cornerRadius(12)
                                }
                            } else {
                                Button(action: startMonitoring) {
                                    Text("Start")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.8))
                                        .cornerRadius(12)
                                }
                            }
                        }

                        Divider().background(Color.white.opacity(0.2))

                        // RSSI Display
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                    .frame(width: 120, height: 120)

                                if let rssi = bleManager.monitoredDeviceRSSI {
                                    Circle()
                                        .trim(from: 0, to: rssiStrength)
                                        .stroke(rssiColor, lineWidth: 8)
                                        .frame(width: 120, height: 120)
                                        .rotationEffect(.degrees(-90))

                                    VStack {
                                        Text("\(rssi)")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("dBm")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    VStack {
                                        Image(systemName: "wifi.slash")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                        Text("No signal")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            // RSSI Status Text
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(rssiColor)
                                    .frame(width: 8, height: 8)

                                Text(rssiStatusText)
                                    .font(.subheadline)
                                    .foregroundColor(.white)

                                if isMonitoring && doorManager.isProcessing {
                                    Text("• Opening...")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }

                        // Threshold Info
                        HStack {
                            Text("Threshold: \(rssiThreshold) dBm")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: { rssiThreshold = max(rssiThreshold - 5, -90) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.gray)
                            }
                            Button(action: { rssiThreshold = min(rssiThreshold + 5, -30) }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20)

                    // Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: doorManager.isProcessing ? "arrow.clockwise" : "info.circle.fill")
                                .foregroundColor(doorManager.isProcessing ? .blue : .green)
                                .font(.system(size: 20))
                                .rotationEffect(.degrees(doorManager.isProcessing ? 360 : 0))
                                .animation(doorManager.isProcessing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: doorManager.isProcessing)

                            Text("Status")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            if let result = doorManager.lastResult {
                                Text(result)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(result == "Success" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                            }
                        }

                        Divider().background(Color.white.opacity(0.2))

                        Text(doorManager.statusMessage)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(2)

                        if let error = doorManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }

                        if let lastAttempt = lastOpenAttempt {
                            Text("Last attempt: \(lastAttempt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20)

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works:")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 8) {
                            instructionRow(number: "1", text: "Tap 'Start' to begin monitoring")
                            instructionRow(number: "2", text: "Hold device near the door")
                            instructionRow(number: "3", text: "Door will open automatically when signal is strong enough")
                            instructionRow(number: "4", text: "View resets after each attempt")
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            print("📱 AutoOpenDoorView appeared for door: \(selectedDoor.name)")
        }
        .onDisappear {
            stopMonitoring()
            print("📱 AutoOpenDoorView disappeared")
        }
        .onReceive(bleManager.$monitoredDeviceRSSI) { rssi in
            // Automatically check and attempt to open door when RSSI changes
            if isMonitoring && !doorManager.isProcessing {
                checkAndAttemptOpen()
            }
        }
    }

    // MARK: - Computed Properties
    private var rssiStrength: CGFloat {
        guard let rssi = bleManager.monitoredDeviceRSSI else { return 0 }
        // Convert RSSI (-90 to -30) to progress (0 to 1)
        let minRSSI: CGFloat = -90
        let maxRSSI: CGFloat = -30
        let normalized = (CGFloat(rssi) - minRSSI) / (maxRSSI - minRSSI)
        return max(0, min(1, normalized))
    }

    private var rssiColor: Color {
        guard let rssi = bleManager.monitoredDeviceRSSI else { return .gray }

        if rssi >= rssiThreshold {
            return .green // Good signal
        } else if rssi >= rssiThreshold - 10 {
            return .yellow // Moderate signal
        } else {
            return .red // Weak signal
        }
    }

    private var rssiStatusText: String {
        guard let rssi = bleManager.monitoredDeviceRSSI else {
            return isMonitoring ? "Scanning..." : "Not monitoring"
        }

        if rssi >= rssiThreshold {
            return "Signal strong - Ready to open"
        } else if rssi >= rssiThreshold - 10 {
            return "Signal moderate - Move closer"
        } else {
            return "Signal weak - Get closer to door"
        }
    }

    // MARK: - Methods
    private func startMonitoring() {
        let deviceName = deviceBLEName
        print("🔍 Starting RSSI monitoring for door: \(selectedDoor.name) (BLE Name: \(deviceName))")
        isMonitoring = true

        // Start BLE monitoring for this device by name
        bleManager.startMonitoringDeviceByName(deviceName)
    }

    private func stopMonitoring() {
        print("🛑 Stopping RSSI monitoring")
        isMonitoring = false
        bleManager.stopMonitoringDevice()
    }

    private func checkAndAttemptOpen() {
        guard isMonitoring,
              !doorManager.isProcessing,
              let rssi = bleManager.monitoredDeviceRSSI,
              rssi >= rssiThreshold else {
            return
        }

        // Check if we haven't attempted to open recently (prevent spam)
        if let lastAttempt = lastOpenAttempt,
           Date().timeIntervalSince(lastAttempt) < 3 { // 3 second cooldown
            return
        }

        print("🚪 RSSI threshold met (\(rssi) >= \(rssiThreshold)), attempting to open door")
        lastOpenAttempt = Date()

        // Automatically open the door
        doorManager.openSelectedDoor(selectedDoor)

        // Reset after a delay to allow for new attempts
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !self.doorManager.isProcessing {
                self.doorManager.resetState()
                // Resume monitoring if still active
                if self.isMonitoring {
                    print("🔄 Resuming RSSI monitoring after door operation")
                }
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
                .background(Color.blue.opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    let sampleDoor = DoorModel(
        name: "Sample Door",
        devSn: "1234567890",
        devMac: "AA:BB:CC:DD:EE:FF",
        devType: 2,
        eKey: "sample_key",
        cardno: "1234567890"
    )

    return AutoOpenDoorView(selectedDoor: sampleDoor)
        .background(Color.black)
}

