

import SwiftUI
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
   
    static let doorMasterServiceUUID = CBUUID(string: "5CB8")

    // Published properties for UI binding
    @Published var devices: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var isBluetoothOn = false
    @Published var bluetoothStateMessage = ""
    @Published var connectedPeripheral: CBPeripheral?
    @Published var monitoredDeviceRSSI: Int? = nil
    @Published var bleState: CBManagerState = .unknown


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

        centralManager.scanForPeripherals(withServices: [Self.doorMasterServiceUUID], options: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
        bleState = central.state  
        switch central.state {

        case .unknown:
            // permission dialog shown → do NOT trigger any alert
            bluetoothStateMessage = "Waiting for Bluetooth authorization…"
            return

        case .resetting:
            bluetoothStateMessage = "Bluetooth resetting…"
            return

        case .poweredOff:
            isBluetoothOn = false

            // Only show alert AFTER permission is granted
            if CBCentralManager.authorization == .allowedAlways {
                bluetoothStateMessage = "Bluetooth is OFF. Please turn it ON."
            }
            return

        case .unauthorized:
            bluetoothStateMessage = "Bluetooth permission denied."
            isBluetoothOn = false
            return

        case .unsupported:
            bluetoothStateMessage = "Device does not support Bluetooth."
            isBluetoothOn = false
            return

        case .poweredOn:
            bluetoothStateMessage = "Bluetooth is ON."
            isBluetoothOn = true
            return

        @unknown default:
            bluetoothStateMessage = "Unknown Bluetooth state."
        }
    }


    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
    
        let allServiceUUIDs = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?
            .map { $0.uuidString } ?? []
        print("📡 Nearby (service-UUID matched): \(peripheral.name ?? "Unknown")  rssi=\(RSSI)  id=\(peripheral.identifier)  services=\(allServiceUUIDs)")

        // DEBUG ONLY: remembers each device's advertised services so the UI can
        // surface them for the matched door. Safe to delete this dictionary and
        // its one write site once the UI debug overlay is removed.
        deviceServiceUUIDs[peripheral.identifier] = allServiceUUIDs

        deviceLastRSSI[peripheral.identifier] = RSSI.intValue

        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)
            print("📱 Found device: \(peripheral.name ?? "Unknown") rssi=\(RSSI)")
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

        // IMPORTANT FIX
       stopContinuousScanning()

        print("🔄 Starting continuous BLE scanning...")

        devices.removeAll()
        deviceLastRSSI.removeAll()

        isScanning = true
        bluetoothStateMessage = "Monitoring for device..."

        // Start first scan immediately
        centralManager.scanForPeripherals(
            withServices: [Self.doorMasterServiceUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )

        continuousScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in

            guard let self = self else { return }
            guard self.isScanning else { return }

            print("🔄 Refreshing BLE scan session")

            self.centralManager.stopScan()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {

                guard self.isScanning else { return }

                self.centralManager.scanForPeripherals(
                    withServices: [Self.doorMasterServiceUUID],
                    options: [
                        CBCentralManagerScanOptionAllowDuplicatesKey: true
                    ]
                )
            }
        }
    }

    /// Re-evaluates Bluetooth authorization/power state. Call when the app returns to the
    /// foreground (e.g. after visiting Settings) to force a fresh read instead of waiting on
    /// centralManagerDidUpdateState, which isn't guaranteed to re-fire immediately on resume.
    func refreshAuthorizationStatus() {
        switch CBCentralManager.authorization {
        case .denied, .restricted:
            bleState = .unauthorized
            isBluetoothOn = false
        case .allowedAlways:
            bleState = centralManager.state
            isBluetoothOn = (centralManager.state == .poweredOn)
        case .notDetermined:
            break
        @unknown default:
            break
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

    // DEBUG ONLY: last known advertised service UUIDs for each device, keyed by
    // peripheral identifier. Feeds the UI debug overlay only — safe to delete
    // once that overlay is removed.
    var deviceServiceUUIDs: [UUID: [String]] = [:]
}
