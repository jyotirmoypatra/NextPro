//
//  EthernetSetupView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 14/09/26.
//

import SwiftUI
import CoreBluetooth
import Combine

struct EthernetSetupView: View {
    @Environment(\.dismiss) private var dismiss
    var selectedDevice: AssignDevice

    @State private var showInfo = false
    @StateObject private var bleManager = BLEManager()
    @StateObject private var successVM = SuccessConfigViewModel()

    @State private var isConfiguring = false
    @State private var loadingMessage = ""

    @State private var showError = false
    @State private var statusMessage = ""
    @State private var hasError = false

    @State private var showDeviceOfflineAlert = false
    @State private var alertMessage = ""
    @State private var icon = ""

    @State private var showBluetoothPermissionAlert = false

    @State private var tcScanTask: Task<Void, Never>?
    @State private var tcScanTimeoutTask: Task<Void, Never>?
    @State private var tcDeviceFound = false

    @State private var navigateToSuccessView = false

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
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

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
                        Text("Configuring Ethernet")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    VStack(spacing: 15) {
                        Image(systemName: "cable.connector")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)

                        Text("\(selectedDevice.modelName) (\(selectedDevice.serial))")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)

                        Text("The device will be configured automatically and connected to the server over Ethernet.")
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

                    

                    Spacer()

                    // Only shown if a step failed — nothing to tap while auto-configuring.
                    // Same bottom-button style as SelectDeviceView's "Next" button.
                    if hasError {
                        Button(action: {
                            configureEthernet()
                        }) {
                            Text("Try Again")
                                .font(.custom("Inter-Bold", size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal, 10)

                if showDeviceOfflineAlert {
                    DeviceOfflineAlertView(
                        message: alertMessage,
                        icon: icon
                    ) {
                        withAnimation {
                            showDeviceOfflineAlert = false
                        }
                    }
                    .zIndex(10)
                }

                // Full-screen dim overlay (SelectDeviceView placement) with the
                // RingSpinner + dynamic text style from SetWiFiPassword.
                if isConfiguring {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack {
                            RingSpinner(
                                ringColor: loaderColor,
                                lineWidth: 3,
                                size: 50
                            )
                            Text(loadingMessage)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            configureEthernet()
        }
        .navigationDestination(isPresented: $navigateToSuccessView) {
            SuccessConnctionView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        .navigationBarBackButtonHidden(true)
        .internetOverlay()
        .fullScreenCover(isPresented: $showInfo) {
            InfoScreenView(infoType: "device_config_info")
        }
        .modernAlert(isPresented: $showError) {
            ModernAlertView(
                title: "Error!",
                message: statusMessage,
                isSuccess: false,
                buttonTitle: "Try Again",
                action: {
                    showError = false
                    configureEthernet()
                },
                secondaryButtonTitle: "Cancel",
                secondaryAction: {
                    showError = false
                }
            )
        }
        .modernAlert(isPresented: $showBluetoothPermissionAlert) {
            ModernAlertView(
                title: "Bluetooth Permission Required",
                message: "Bluetooth permission is disabled. \nPlease enable it in iPhone Settings → Apps → ZYLX → Bluetooth.",
                isSuccess: false,
                buttonTitle: "Cancel",
                action: {
                    showBluetoothPermissionAlert = false
                },
                secondaryButtonTitle: "Open Settings",
                secondaryAction: {
                    showBluetoothPermissionAlert = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }

    /// Green while confirming the device is online, yellow for every other in-progress step —
    /// same scheme as SetWiFiPassword's loaderColor.
    private var loaderColor: Color {
        loadingMessage == "Device is online." ? .green : .yellow
    }

    private var isBluetoothPermissionDenied: Bool {
        bleManager.bleState == .unauthorized
    }

    private var isBluetoothOff: Bool {
        bleManager.bleState == .poweredOff
    }

    // MARK: - Flow controller

    private func configureEthernet() {
        isConfiguring = true
        statusMessage = ""
        hasError = false
        loadingMessage = "Checking device power..."

        Task { @MainActor in
            // CBCentralManager reports its real state (.poweredOn/.poweredOff/.unauthorized)
            // asynchronously — right after the view appears it can still read `.unknown`.
            // Wait briefly for a real state instead of racing ahead and treating "unknown"
            // as "powered on", which would call startScanning() before CoreBluetooth is
            // ready and silently no-op the scan.
            await waitForBluetoothReady()

            guard isConfiguring else { return }

            if isBluetoothPermissionDenied {
                isConfiguring = false
                loadingMessage = ""
                hasError = true
                showBluetoothPermissionAlert = true
                return
            }

            if isBluetoothOff {
                isConfiguring = false
                loadingMessage = ""
                hasError = true
                icon = "bluetooth-red"
                alertMessage = "Bluetooth is turned off.\nPlease enable Bluetooth to proceed."
                showDeviceOfflineAlert = true
                return
            }

            startDeviceScan(serial: selectedDevice.serial)
        }
    }

    /// Polls `bleManager.bleState` until CoreBluetooth reports something other than
    /// `.unknown`/`.resetting`, or `timeout` elapses (whichever first).
    private func waitForBluetoothReady(timeout: TimeInterval = 3.0) async {
        let deadline = Date().addingTimeInterval(timeout)
        while bleManager.bleState == .unknown || bleManager.bleState == .resetting {
            guard Date() < deadline else { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - Step 1: Device power check (BLE, 10s timeout)

    private func startDeviceScan(serial: String) {
        tcDeviceFound = false
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()

        bleManager.startScanning()

        tcScanTask = Task { @MainActor in
            for await devices in bleManager.$devices.values {
                for peripheral in devices {
                    let name = (peripheral.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                    if name.contains(serial) {
                        tcDeviceFound = true

                        // Only stop the *timeout* task and the scan here — cancelling
                        // `tcScanTask` (the task we're currently running inside of) would
                        // mark it cancelled, and every `try? await Task.sleep` further down
                        // this same task (e.g. the "Device is online." pause) would then
                        // throw CancellationError immediately instead of actually waiting,
                        // silently skipping straight to navigation.
                        tcScanTimeoutTask?.cancel()
                        tcScanTimeoutTask = nil
                        bleManager.stopScanning()

                        await performServerIPStep()
                        return
                    }
                }
            }
        }

        tcScanTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 10_000_000_000)

            guard !tcDeviceFound else { return }

            stopTCScan()
            isConfiguring = false
            loadingMessage = ""
            hasError = true

            icon = "power-off"
            alertMessage = "The selected device is currently not powered on.\nPlease turn on the device to proceed."
            showDeviceOfflineAlert = true
        }
    }

    private func stopTCScan() {
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()
        tcScanTask = nil
        tcScanTimeoutTask = nil
        bleManager.stopScanning()
    }

    // MARK: - Step 2: Server IP setup

    @MainActor
    private func performServerIPStep() async {
        loadingMessage = "Configuring server IP..."

        // EthernetConfigureManager reads the server IP/port from Keychain itself and
        // retries the SDK call internally, so a single call here already reflects the
        // final outcome.
        let (success, message): (Bool, String) = await withCheckedContinuation { continuation in
            EthernetConfigureManager.configureServerIP(device: selectedDevice) { success, message in
                continuation.resume(returning: (success, message))
            }
        }

        guard success else {
            isConfiguring = false
            loadingMessage = ""
            hasError = true
            statusMessage = message
            showError = true
            return
        }

        await performSaveConfigStep()
    }

    // MARK: - Step 3: Save device configuration to cloud (same API as SetWiFiPassword)

    @MainActor
    private func performSaveConfigStep() async {
        loadingMessage = "Saving Device Configuration to Cloud..."

        await successVM.successConfig(
            isSuccess: true,
            deviceSerial: selectedDevice.serial,
            wifiSSid: "",
            wifiPass: ""
        )

        guard successVM.success && successVM.errorMessage == nil else {
            isConfiguring = false
            loadingMessage = ""
            hasError = true
            statusMessage = successVM.errorMessage ?? "Something went wrong"
            showError = true
            return
        }

        await performHeartbeatStep()
    }

    // MARK: - Step 4 & 5: Heartbeat check + device online confirmation

    @MainActor
    private func performHeartbeatStep() async {
        loadingMessage = "Connecting device to Ethernet..."

        let heartbeatReceived = await MQTTManager.shared.waitForHeartbeat(serial: selectedDevice.serial, timeout: 30)

        guard heartbeatReceived else {
            isConfiguring = false
            loadingMessage = ""
            hasError = true
            statusMessage = "Unable to confirm the device is online. Please verify the server IP and the Ethernet cable connection."
            showError = true
            return
        }

        loadingMessage = "Device is online."
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        isConfiguring = false
        loadingMessage = ""
        navigateToSuccessView = true
    }
}
