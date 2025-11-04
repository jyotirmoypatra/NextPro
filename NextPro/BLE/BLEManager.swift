//import SwiftUI
//import CoreBluetooth
//import Combine
//
//class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
//    @Published var devices: [CBPeripheral] = []
//     var shouldAutoScan = false
//    @Published var isBluetoothOn: Bool = false
//
//    @Published var isScanning = false
//    @Published var bluetoothStateMessage: String = ""
//    @Published var connectedPeripheral: CBPeripheral?
//    @Published var availableWiFiList: [String] = []
//
//
//
//    private var centralManager: CBCentralManager!
//
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//
//    func startScanning() {
//        guard centralManager.state == .poweredOn else {
//            bluetoothStateMessage = "Bluetooth is not powered on or not supported."
//            stopScanning()
//            return
//        }
//
//        devices.removeAll()
//        bluetoothStateMessage = ""
//        isScanning = true
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
//
//        // Stop after 8 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//            self.stopScanning()
//        }
//    }
//
//   
//
//
//    
//    func stopScanning() {
//        centralManager.stopScan()
//        isScanning = false
//    }
//    
//    
//    func connect(to peripheral: CBPeripheral) {
//        centralManager.connect(peripheral, options: nil)
//        connectedPeripheral = peripheral
//        peripheral.delegate = self
//    }
//
//
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("✅ Connected to \(peripheral.name ?? "device")")
//        peripheral.discoverServices(nil)
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("❌ Failed to connect: \(error?.localizedDescription ?? "unknown error")")
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard error == nil else { return }
//        for service in peripheral.services ?? [] {
//            print("Discovered service: \(service.uuid)")
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard error == nil else { return }
//        for char in service.characteristics ?? [] {
//            print("Found characteristic: \(char.uuid)")
//        }
//    }
//
//
//    // MARK: - CBCentralManagerDelegate
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
////        case .poweredOn:
////            bluetoothStateMessage = "Bluetooth is ON"
////            startScanning()
//        case .poweredOn:
//            bluetoothStateMessage = "Bluetooth is ON"
//                   isBluetoothOn = true
//                   if shouldAutoScan {
//                       startScanning()
//                       shouldAutoScan = false
//                   }
//        case .poweredOff:
//            bluetoothStateMessage = "Bluetooth is OFF. Please turn it ON."
//            stopScanning()
//        case .unauthorized:
//            bluetoothStateMessage = "Bluetooth access unauthorized."
//            stopScanning()
//        case .unsupported:
//            bluetoothStateMessage = "This device does not support Bluetooth."
//            stopScanning()
//        case .resetting:
//            bluetoothStateMessage = "Bluetooth is resetting..."
//            stopScanning()
//        default:
//            bluetoothStateMessage = "Unknown Bluetooth state."
//            stopScanning()
//        }
//
//        print(bluetoothStateMessage)
//    }
//
//    func centralManager(
//        _ central: CBCentralManager,
//        didDiscover peripheral: CBPeripheral,
//        advertisementData: [String: Any],
//        rssi RSSI: NSNumber
//    ) {
//        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
//            devices.append(peripheral)
//        }
//    }
//}
//

import SwiftUI
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Published properties for UI binding
    @Published var devices: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var isBluetoothOn = false
    @Published var bluetoothStateMessage = ""
    @Published var connectedPeripheral: CBPeripheral?

    private var centralManager: CBCentralManager!
    private var connectionCompletion: ((Bool, String) -> Void)?

    // MARK: - Init
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Scan Methods
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            bluetoothStateMessage = "⚠️ Bluetooth is not powered on."
            return
        }

        print("🔍 Starting BLE scan...")
        devices.removeAll()
        isScanning = true
        bluetoothStateMessage = "Scanning for nearby devices..."
        centralManager.scanForPeripherals(withServices: nil, options: nil)

        // Stop scanning after 6 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.stopScanning()
        }
    }

    func stopScanning() {
        guard isScanning else { return }
        centralManager.stopScan()
        isScanning = false
        print("🛑 Stopped BLE scan.")
        if devices.isEmpty {
            bluetoothStateMessage = "No devices found nearby."
        }
    }

    // MARK: - Connect Methods
    func connect(to peripheral: CBPeripheral, completion: @escaping (Bool, String) -> Void) {
        print("🔗 Attempting to connect to \(peripheral.name ?? "Unknown Device")...")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        connectionCompletion = completion
        centralManager.connect(peripheral, options: nil)

        // Timeout protection
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if self.connectedPeripheral != peripheral {
                self.bluetoothStateMessage = "⏰ Connection timeout."
                completion(false, "Connection timeout.")
                self.connectionCompletion = nil
            }
        }
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
            bluetoothStateMessage = "🔌 Disconnected manually."
            print("🔌 Disconnected from peripheral.")
        }
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothOn = true
            bluetoothStateMessage = "Bluetooth is ON."
        case .poweredOff:
            isBluetoothOn = false
            bluetoothStateMessage = "Bluetooth is OFF. Please turn it ON."
        case .unauthorized:
            bluetoothStateMessage = "App not authorized to use Bluetooth."
        case .unsupported:
            bluetoothStateMessage = "This device does not support Bluetooth."
        case .resetting:
            bluetoothStateMessage = "Bluetooth is resetting..."
        default:
            bluetoothStateMessage = "Bluetooth state unknown."
        }
        print("📡 State: \(bluetoothStateMessage)")
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)

            // Enhanced logging for debugging DoorMaster SDK compatibility
            print("📱 Found device: \(peripheral.name ?? "Unknown")")
            print("   UUID: \(peripheral.identifier.uuidString.prefix(8))...")
            print("   RSSI: \(RSSI)")
            print("   Services: \(advertisementData[CBAdvertisementDataServiceUUIDsKey] ?? "None")")
            print("   Manufacturer: \(advertisementData[CBAdvertisementDataManufacturerDataKey] != nil ? "Present" : "None")")
            print("   Local Name: \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "None")")
            print("   TX Power: \(advertisementData[CBAdvertisementDataTxPowerLevelKey] ?? "None")")
            print("   Is Connectable: \(advertisementData[CBAdvertisementDataIsConnectable] ?? "Unknown")")

            // Check for patterns that DoorMaster SDK might look for
            if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                let serviceStrings = services.map { $0.uuidString }
                print("   Service UUIDs: \(serviceStrings)")

                // Check for common BLE door lock service patterns
                let hasLockServices = serviceStrings.contains { uuid in
                    uuid.lowercased().contains("180f") || // Battery service
                    uuid.lowercased().contains("180a") || // Device info
                    uuid.lowercased().contains("ffe0") || // Common for door locks
                    uuid.lowercased().starts(with: "0000") // Standard services
                }
                if hasLockServices {
                    print("   🎯 Potentially DoorMaster-compatible services detected")
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "device")")
        bluetoothStateMessage = "✅ Connected to \(peripheral.name ?? "device")"
        connectionCompletion?(true, "Connected successfully.")
        connectionCompletion = nil
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let msg = "❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")"
        print(msg)
        bluetoothStateMessage = msg
        connectionCompletion?(false, msg)
        connectionCompletion = nil
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bluetoothStateMessage = "🔌 Disconnected from \(peripheral.name ?? "device")"
        connectedPeripheral = nil
        print(bluetoothStateMessage)
    }

    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("⚠️ Error discovering services: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            print("🔧 Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("⚠️ Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        for char in service.characteristics ?? [] {
            print("🔹 Characteristic: \(char.uuid)")
        }
    }
}
