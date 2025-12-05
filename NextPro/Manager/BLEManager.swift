

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
    @Published var monitoredDeviceRSSI: Int? = nil

    // RSSI monitoring properties
    private var centralManager: CBCentralManager!
    private var connectionCompletion: ((Bool, String) -> Void)?
    private var monitoredDeviceIdentifier: UUID?
    private var monitoredDeviceName: String? // Track by device name (e.g., "XM-4280125893")
    private var rssiUpdateTimer: Timer?
    private var continuousScanTimer: Timer?

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
        // Filter: Only process Thimmo devices (same as DoorMasterSDK does)
        let validPrefixes = ["M2", "TC", "BC", "AC", "DM", "M23", "M22", "XM"]
        let deviceName = peripheral.name ?? ""
        let isThimmoDevice = validPrefixes.contains { prefix in 
            deviceName.uppercased().hasPrefix(prefix) 
        }
        
        // Skip non-Thimmo devices
        guard isThimmoDevice else { 
            return 
        }
        
        // Store RSSI for this device
        deviceLastRSSI[peripheral.identifier] = RSSI.intValue

        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)

            // Enhanced logging for debugging DoorMaster SDK compatibility
            print("📱 Found Thimmo device: \(peripheral.name ?? "Unknown")")
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
        } else {
            // Device already in list, just update RSSI
            deviceLastRSSI[peripheral.identifier] = RSSI.intValue
            // print("📊 Updated RSSI for \(peripheral.name ?? "Unknown"): \(RSSI) dBm")
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

    // MARK: - RSSI Monitoring Methods
    func startMonitoringDevice(identifier: UUID) {
        print("🔍 Starting RSSI monitoring for device: \(identifier)")
        monitoredDeviceIdentifier = identifier
        monitoredDeviceRSSI = nil

        // Start continuous scanning if not already scanning
        if !isScanning {
            startContinuousScanning()
        }

        // Start RSSI update timer (every 500ms)
        rssiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMonitoredDeviceRSSI()
        }
    }
    
    // New method: Monitor by device name (more reliable for door devices)
    func startMonitoringDeviceByName(_ deviceName: String) {
        print("🔍 Starting RSSI monitoring for device name: \(deviceName)")
        monitoredDeviceName = deviceName
        monitoredDeviceRSSI = nil

        // Start continuous scanning if not already scanning
        if !isScanning {
            startContinuousScanning()
        }

        // Start RSSI update timer (every 500ms)
        rssiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMonitoredDeviceRSSI()
        }
    }

    func stopMonitoringDevice() {
        print("🛑 Stopping RSSI monitoring")
        monitoredDeviceIdentifier = nil
        monitoredDeviceName = nil
        monitoredDeviceRSSI = nil
        rssiUpdateTimer?.invalidate()
        rssiUpdateTimer = nil
        stopContinuousScanning()
    }

     func startContinuousScanning() {
        guard centralManager.state == .poweredOn else {
            print("⚠️ Cannot start continuous scanning - Bluetooth not powered on")
            return
        }

        print("🔄 Starting continuous BLE scanning...")
        isScanning = true
        bluetoothStateMessage = "Monitoring for device..."

        // Continuous scanning with shorter intervals
        continuousScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isScanning else { return }
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)

            // Stop scan after 0.8 seconds, then restart
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if self.isScanning {
                    self.centralManager.stopScan()
                }
            }
        }

        // Start first scan immediately
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if self.isScanning {
                self.centralManager.stopScan()
            }
        }
    }

     func stopContinuousScanning() {
        continuousScanTimer?.invalidate()
        continuousScanTimer = nil
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            print("🛑 Stopped continuous scanning")
        }
    }

     func updateMonitoredDeviceRSSI() {
        // Check if monitoring by name (preferred for door devices)
        if let monitoredName = monitoredDeviceName {
            // Find device by name
            if let device = devices.first(where: { $0.name == monitoredName }),
               let lastRSSI = deviceLastRSSI[device.identifier] {
                DispatchQueue.main.async {
                    self.monitoredDeviceRSSI = lastRSSI
                }
                print("📊 RSSI update for \(monitoredName): \(lastRSSI) dBm")
            } else {
                // Device not currently visible
                DispatchQueue.main.async {
                    self.monitoredDeviceRSSI = nil
                }
            }
            return
        }
        
        // Fallback: Check by UUID
        guard let monitoredID = monitoredDeviceIdentifier else { return }

        // Find the monitored device in current devices list
        if let device = devices.first(where: { $0.identifier == monitoredID }),
           let lastRSSI = deviceLastRSSI[device.identifier] {
            DispatchQueue.main.async {
                self.monitoredDeviceRSSI = lastRSSI
            }
            print("📊 RSSI update for \(device.name ?? "Unknown"): \(lastRSSI) dBm")
        } else {
            // Device not currently visible
            DispatchQueue.main.async {
                self.monitoredDeviceRSSI = nil
            }
        }
    }

    // Dictionary to store last known RSSI for each device
     var deviceLastRSSI: [UUID: Int] = [:]
}
