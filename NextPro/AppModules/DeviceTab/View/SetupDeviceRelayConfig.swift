//
//  SetupDeviceRelayConfig.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 01/07/26.
//

import SwiftUI
import CoreBluetooth
import Combine

struct SetupDeviceRelayConfig: View {
    @Environment(\.dismiss) private var dismiss
    var selectedDevice: AssignDevice

    @State private var durationText: String = ""
    @FocusState private var isFieldFocused: Bool

    // BLE — same pattern as DeviceInformationView
    @StateObject private var bleManager = BLEManager()
    @State private var showOfflineAlert = false
    @State private var isCheckingDevice = false
    @State private var alertMessage = ""
    @State private var alertIcon = ""
    @State private var tcScanTask: Task<Void, Never>?
    @State private var tcScanTimeoutTask: Task<Void, Never>?
    @State private var tcDeviceFound = false

    // pending value to pass into the SDK call once device is found
    @State private var pendingOpenTime: Int = 0

    @State private var showSuccessAlert = false
    @State private var successMessage = ""

    private var isValidInput: Bool {
        guard let value = Int(durationText), value >= 1, value <= 254 else { return false }
        return true
    }

    private var isBluetoothOff: Bool {
        bleManager.bleState == .poweredOff
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {

                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    HeaderView
                        .padding(.horizontal, 10)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            NoteCard
                            InputCard
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }

                    SaveButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .padding(.top, 12)
                }

                if showOfflineAlert {
                    DeviceOfflineAlertView(
                        message: alertMessage,
                        icon: alertIcon
                    ) {
                        withAnimation { showOfflineAlert = false }
                    }
                    .zIndex(10)
                }

                if isCheckingDevice {
                    ZStack {
                        Color.black.opacity(0.8).ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture { isFieldFocused = false }
        .onAppear {
            bleManager.stopScanning()
        }
        .onDisappear {
            stopTCScan()
        }
        .modernAlert(isPresented: $showSuccessAlert) {
            ModernAlertView(
                title: "Success!",
                message: successMessage,
                isSuccess: true,
                buttonTitle: "OK"
            ) {
                showSuccessAlert = false
                durationText = ""
                dismiss()
            }
        }
    }

    // MARK: - Header
    private var HeaderView: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Back")
                        .font(.custom("Inter-SemiBold", size: 16))
                }
                .foregroundColor(.white)
            }
            Spacer()
        }
        .overlay(
            Text("Set Device Unlock Duration")
                .foregroundColor(.white)
                .font(.custom("Inter-Bold", size: 16))
        )
        .padding(.top, 10)
        .padding(.bottom, 10)
    }

    // MARK: - Note Card
    private var NoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16))
                Text("Note")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 8) {
                noteRow("The unlock duration controls how long the door relay stays open after a successful access event.")
                noteRow("Value range: 1 – 254 (in seconds).")
                noteRow("Setting a value of 1 means the relay opens for 1 second; 254 means 254 seconds.")
                noteRow("Changes are applied to the device over Bluetooth. Ensure the device is nearby before saving.")
            }
        }
        .padding(16)
        .background(Color.yellow.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.35), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private func noteRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Input Card
    private var InputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Unlock Duration (seconds)")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white)

            HStack {
                TextField("Enter value (1 – 254)", text: $durationText)
                    .keyboardType(.numberPad)
                    .focused($isFieldFocused)
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .onChange(of: durationText) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let num = Int(filtered), num > 254 {
                            durationText = "254"
                        } else {
                            durationText = filtered
                        }
                    }

                if !durationText.isEmpty {
                    Button { durationText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFieldFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.25),
                        lineWidth: 1
                    )
            )
            .cornerRadius(10)

            if !durationText.isEmpty && !isValidInput {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.8))
                    Text("Value must be between 1 and 254")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    // MARK: - Save Button
    private var SaveButton: some View {
        Button {
            isFieldFocused = false
            handleSave()
        } label: {
            Text("Save Configuration")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(isValidInput ? .black : .white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isValidInput ? Color.white : Color.white.opacity(0.12))
                .cornerRadius(12)
        }
        .disabled(!isValidInput || isCheckingDevice)
    }

    // MARK: - Save Logic
    private func handleSave() {
        guard let openTime = Int(durationText), openTime >= 1, openTime <= 254 else { return }

        if isBluetoothOff {
            alertIcon = "bluetooth-red"
            alertMessage = "Bluetooth is turned off.\nPlease enable Bluetooth to proceed."
            showOfflineAlert = true
            return
        }

        startDeviceScan(openTime: openTime)
    }

    // MARK: - BLE Scan (identical to DeviceInformationView)
    private func startDeviceScan(openTime: Int) {
        pendingOpenTime = openTime
        isCheckingDevice = true
        tcDeviceFound = false

        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()

        bleManager.startScanning()

        tcScanTask = Task { @MainActor in
            for await devices in bleManager.$devices.values {
                for peripheral in devices {
                    let name = (peripheral.name ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if name.contains(selectedDevice.serial) {
                        print("Device detected via BLE:", name)

                        tcDeviceFound = true
                        stopTCScan()
                        sendSetDeviceConfig(openTime: pendingOpenTime)
                        return
                    }
                }
            }
        }

        tcScanTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 15_000_000_000)

            guard !tcDeviceFound else { return }

            stopTCScan()
            alertIcon = "power-off"
            alertMessage = "The selected device is currently not powered on.\nPlease turn on the device to proceed."
            showOfflineAlert = true
        }
    }

    private func stopTCScan() {
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()
        tcScanTask = nil
        tcScanTimeoutTask = nil
        bleManager.stopScanning()
        isCheckingDevice = false
    }

    // MARK: - SDK setDeviceConfig (4.11)
    private func sendSetDeviceConfig(openTime: Int) {
        isCheckingDevice = true

        let devModel = LibDevModel()
        devModel.devSn = selectedDevice.serial
        devModel.devMac = selectedDevice.mac
        devModel.devType = Int32(selectedDevice.devType ?? 14)
        devModel.eKey = selectedDevice.key

        let ret = LibDevModel.setDeviceConfig(
            devModel,
            andWGFmt: 34,
            andOpenTime: Int32(openTime),
            andLockSwitch: 0
        )

        if ret != 0 {
            isCheckingDevice = false
            alertIcon = "power-off"
            alertMessage = "Failed to send command to device.\nSDK error code: \(ret)"
            showOfflineAlert = true
            return
        }

        LibDevModel.onControlOver { retCode, _ in
            DispatchQueue.main.async {
                isCheckingDevice = false
                if retCode == 0 {
                    successMessage = "Unlock duration set to \(openTime)s successfully."
                    showSuccessAlert = true
                } else {
                    alertIcon = "power-off"
                    alertMessage = "Device configuration failed.\nSDK error code: \(retCode)"
                    showOfflineAlert = true
                }
            }
        }
    }
}
