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
                     // NFC-Style RSSI Display with Live Animation
                     VStack(spacing: 20) {
                         ZStack {
                             // Outer pulsing rings (NFC effect)
                             if isMonitoring {
                                 ForEach(0..<3, id: \.self) { index in
                                     Circle()
                                         .stroke(rssiColor.opacity(0.3), lineWidth: 2)
                                         .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                                         .scaleEffect(isMonitoring ? 1.2 : 0.8)
                                         .opacity(isMonitoring ? 0 : 0.6)
                                         .animation(
                                             Animation.easeOut(duration: 1.5)
                                                 .repeatForever(autoreverses: false)
                                                 .delay(Double(index) * 0.5),
                                             value: isMonitoring
                                         )
                                 }
                             }
                             
                             // Main NFC circle background
                             Circle()
                                 .fill(
                                     RadialGradient(
                                         colors: [rssiColor.opacity(0.3), rssiColor.opacity(0.1), Color.clear],
                                         center: .center,
                                         startRadius: 0,
                                         endRadius: 100
                                     )
                                 )
                                 .frame(width: 200, height: 200)
                                 .blur(radius: 10)
                             
                             // Progress ring
                             Circle()
                                 .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                 .frame(width: 160, height: 160)
                             
                             if let rssi = bleManager.monitoredDeviceRSSI {
                                 // Animated progress ring
                                 Circle()
                                     .trim(from: 0, to: rssiStrength)
                                     .stroke(
                                         LinearGradient(
                                             colors: [rssiColor, rssiColor.opacity(0.6)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing
                                         ),
                                         style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                     )
                                     .frame(width: 160, height: 160)
                                     .rotationEffect(.degrees(-90))
                                     .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rssiStrength)
                                 
                                 // Inner content
                                 VStack(spacing: 8) {
                                     // NFC Icon
                                     Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                         .font(.system(size: 24))
                                         .foregroundColor(rssiColor)
                                         .scaleEffect(doorManager.isProcessing ? 1.2 : 1.0)
                                         .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: doorManager.isProcessing)
                                     
                                     // Live RSSI Value
                                     Text("\(rssi)")
                                         .font(.system(size: 42, weight: .bold, design: .rounded))
                                         .foregroundColor(.white)
                                         .shadow(color: rssiColor.opacity(0.5), radius: 10)
                                         .transition(.scale.combined(with: .opacity))
                                         .id("rssi-\(rssi)")
                                     
                                     Text("dBm")
                                         .font(.system(size: 14, weight: .medium))
                                         .foregroundColor(.gray)
                                 }
                             } else {
                                 // No Signal State
                                 VStack(spacing: 12) {
                                     Image(systemName: "wifi.slash")
                                         .font(.system(size: 40))
                                         .foregroundColor(.gray.opacity(0.5))
                                     
                                     Text("Searching...")
                                         .font(.system(size: 14, weight: .medium))
                                         .foregroundColor(.gray)
                                 }
                                 .opacity(isMonitoring ? 1 : 0.3)
                             }
                         }
                         .frame(height: 200)

                         // Live Status Bar
                         HStack(spacing: 12) {
                             // Status indicator dot
                             Circle()
                                 .fill(rssiColor)
                                 .frame(width: 10, height: 10)
                                 .shadow(color: rssiColor, radius: 4)
                                 .scaleEffect(isMonitoring ? 1.0 : 0.8)
                                 .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isMonitoring)

                             VStack(alignment: .leading, spacing: 2) {
                                 Text(rssiStatusText)
                                     .font(.system(size: 15, weight: .semibold))
                                     .foregroundColor(.white)
                                 
                                 if doorManager.isProcessing {
                                     HStack(spacing: 4) {
                                         ProgressView()
                                             .scaleEffect(0.7)
                                             .tint(.blue)
                                         Text("Opening door...")
                                             .font(.caption)
                                             .foregroundColor(.blue)
                                     }
                                 }
                             }
                             
                             Spacer()
                             
                             // Signal strength indicator bars
                             if let rssi = bleManager.monitoredDeviceRSSI {
                                 HStack(spacing: 3) {
                                     ForEach(0..<5, id: \.self) { index in
                                         RoundedRectangle(cornerRadius: 2)
                                             .fill(signalBarColor(for: index, rssi: rssi))
                                             .frame(width: 4, height: CGFloat(8 + index * 4))
                                             .opacity(signalBarOpacity(for: index, rssi: rssi))
                                             .animation(.spring(response: 0.3).delay(Double(index) * 0.05), value: rssi)
                                     }
                                 }
                             }
                         }
                         .padding(.horizontal, 20)
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
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
            print("📱 AutoOpenDoorView disappeared")
        }
        .onReceive(bleManager.$isBluetoothOn) { isOn in
            // Start monitoring when Bluetooth becomes available
            if isOn && isMonitoring && bleManager.monitoredDeviceRSSI == nil {
                print("📡 Bluetooth state changed to ON - starting monitoring")
                bleManager.startMonitoringDeviceByName(deviceBLEName)
            }
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

        // Check if Bluetooth is ready, if not, retry after delay
        if bleManager.isBluetoothOn {
            // Bluetooth ready - start immediately
            bleManager.startMonitoringDeviceByName(deviceName)
        } else {
            // Bluetooth not ready yet - wait and retry
            print("⏳ Bluetooth not ready yet, waiting 0.5s...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak bleManager] in
                if let bleManager = bleManager, bleManager.isBluetoothOn {
                    print("✅ Bluetooth now ready, starting monitoring...")
                    bleManager.startMonitoringDeviceByName(deviceName)
                } else {
                    print("⚠️ Bluetooth still not ready after delay")
                    // Try one more time after another delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak bleManager] in
                        if let bleManager = bleManager {
                            print("🔄 Final retry...")
                            bleManager.startMonitoringDeviceByName(deviceName)
                        }
                    }
                }
            }
        }
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
    
    // MARK: - Signal Bar Helpers
    private func signalBarColor(for index: Int, rssi: Int) -> Color {
        let barThreshold = rssiThreshold + (index * 10)
        return rssi >= barThreshold ? rssiColor : Color.gray.opacity(0.3)
    }
    
    private func signalBarOpacity(for index: Int, rssi: Int) -> Double {
        let barThreshold = rssiThreshold + (index * 10)
        return rssi >= barThreshold ? 1.0 : 0.3
    }
    
    // MARK: - NFC Animation Helpers
    private var nfcSignalText: String {
        guard let rssi = bleManager.monitoredDeviceRSSI else { return "Searching..." }
        
        if doorManager.isProcessing {
            return "✓ OPENING"
        } else if rssi >= rssiThreshold {
            return "✓ READY"
        } else if rssi >= rssiThreshold - 15 {
            return "MOVE CLOSER"
        } else {
            return "OUT OF RANGE"
        }
    }
    
    private func nfcWaveScale(for index: Int) -> CGFloat {
        return isMonitoring ? 1.0 + CGFloat(index) * 0.15 : 0.8
    }
    
    private func nfcWaveOpacity(for index: Int) -> Double {
        let baseOpacity = isMonitoring ? 0.6 : 0.0
        return baseOpacity - (Double(index) * 0.15)
    }
    
    private func scanningDotScale(for index: Int) -> CGFloat {
        return doorManager.isProcessing ? 1.5 : 1.0
    }
    
    private func searchingDotOpacity(for index: Int) -> Double {
        return isMonitoring ? (0.3 + Double(index) * 0.3) : 0.3
    }
    
    private func nfcBarColor(for index: Int, rssi: Int) -> Color {
        let barThreshold = rssiThreshold + (index * 8)
        if rssi >= barThreshold {
            return rssiColor
        }
        return Color.gray.opacity(0.3)
    }
    
    private func nfcBarOpacity(for index: Int, rssi: Int) -> Double {
        let barThreshold = rssiThreshold + (index * 8)
        return rssi >= barThreshold ? 1.0 : 0.4
    }
    
    private func nfcBarScale(for index: Int, rssi: Int) -> CGFloat {
        let barThreshold = rssiThreshold + (index * 8)
        return rssi >= barThreshold ? 1.0 : 0.5
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

