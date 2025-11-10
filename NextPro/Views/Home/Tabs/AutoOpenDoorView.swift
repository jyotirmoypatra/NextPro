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
    @State private var rssiThreshold = -40 // Configurable RSSI threshold (dBm)
    @State private var hasTriggeredInCurrentProximity = false // Track if we've already opened in this approach

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

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
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
                .padding(.top,40)
                .background(Color.white.opacity(0.08))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.horizontal, 20)

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
                    .padding(.top,30)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20)

                    // RSSI Monitoring Card
                    VStack(alignment: .leading, spacing: 16) {
                       

                        

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

                    

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }.frame(maxWidth: .infinity)
                .clipped()
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
            // Proximity-based logic: open when close, reset when far
            if isMonitoring {
                handleProximityChange(rssi: rssi)
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

    // MARK: - Proximity-Based Auto-Open Logic
    private func handleProximityChange(rssi: Int?) {
        guard let currentRSSI = rssi else {
            // No signal - reset for next approach
            if hasTriggeredInCurrentProximity {
                print("📡 Signal lost - resetting for next approach")
                hasTriggeredInCurrentProximity = false
                doorManager.resetState()
            }
            return
        }
        
        // Check if signal is STRONG (>= threshold, e.g., -40 dBm or better)
        if currentRSSI >= rssiThreshold {
            // User is CLOSE - trigger door open if we haven't already
            if !hasTriggeredInCurrentProximity && !doorManager.isProcessing {
                print("🚪 ✅ PROXIMITY DETECTED! RSSI: \(currentRSSI) dBm (≥ \(rssiThreshold) dBm)")
                print("🔥 FIRING door open command NOW!")
                
                hasTriggeredInCurrentProximity = true
                lastOpenAttempt = Date()
                
                // Fire door open immediately
                doorManager.openSelectedDoor(selectedDoor)
            }
        } else {
            // Signal is WEAK (< threshold) - user moved away
            if hasTriggeredInCurrentProximity {
                print("📉 RSSI dropped to \(currentRSSI) dBm (< \(rssiThreshold) dBm)")
                print("🔄 User moved away - AUTO RESET for next approach")
                
                // Reset state - ready for next proximity event
                hasTriggeredInCurrentProximity = false
                doorManager.resetState()
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

