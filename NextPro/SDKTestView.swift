import SwiftUI

struct SDKTestView: View {
    @State private var bluetoothStatus: String = "Not initialized"
    @State private var scanResults: [String: Int] = [:]
    @State private var isScanning: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("DoorMaster SDK Test")
                .font(.title)
                .foregroundColor(.white)

            Text("Bluetooth Status: \(bluetoothStatus)")
                .foregroundColor(.white)

            Button("Init Bluetooth") {
                testInitBluetooth()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Scan Devices") {
                testScanDevices()
            }
            .padding()
            .background(isScanning ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isScanning)

            if !scanResults.isEmpty {
                Text("Scan Results:")
                    .foregroundColor(.white)
                    .font(.headline)

                ForEach(scanResults.sorted(by: { $0.value > $1.value }), id: \.key) { deviceSn, rssi in
                    Text("Device: \(deviceSn) - Signal: \(rssi)dB")
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            setupCallbacks()
        }
    }

    func setupCallbacks() {
        // Set up Bluetooth initialization callback
        LibDevModel.onInitBluetoothOver { ret in
            DispatchQueue.main.async {
                if ret == 0 {
                    self.bluetoothStatus = "Initialized successfully"
                } else {
                    self.bluetoothStatus = "Initialization failed: \(ret)"
                }
            }
        }

        // Set up scan callback
        LibDevModel.onScanOver { devDict in
            DispatchQueue.main.async {
                self.scanResults = devDict as? [String: Int] ?? [:]
                self.isScanning = false
            }
        }

        // Set up Bluetooth state change callback
        LibDevModel.onBluetoothStateOver { state in
            DispatchQueue.main.async {
                switch state {
                case 0: self.bluetoothStatus = "Unknown"
                case 1: self.bluetoothStatus = "Resetting"
                case 2: self.bluetoothStatus = "Unsupported"
                case 3: self.bluetoothStatus = "Unauthorized"
                case 4: self.bluetoothStatus = "Powered Off"
                case 5: self.bluetoothStatus = "Powered On"
                default: self.bluetoothStatus = "State: \(state)"
                }
            }
        }
    }

    func testInitBluetooth() {
        let ret = LibDevModel.initBluetooth()
        print("✅ Init Bluetooth return: \(ret)")
        if ret == 0 {
            bluetoothStatus = "Initializing..."
        } else {
            bluetoothStatus = "Init failed: \(ret)"
        }
    }

    func testScanDevices() {
        isScanning = true
        scanResults.removeAll()
        let ret = LibDevModel.scanDevice(2000) // Scan for 2 seconds
        print("✅ Scan device return: \(ret)")
        if ret != 0 {
            isScanning = false
            print("❌ Scan failed with code: \(ret)")
        }
    }
}

#Preview {
    SDKTestView()
}
