import SwiftUI
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var devices: [CBPeripheral] = []
     var shouldAutoScan = false
    @Published var isBluetoothOn: Bool = false

    @Published var isScanning = false
    @Published var bluetoothStateMessage: String = ""
    @Published var connectedPeripheral: CBPeripheral?
    @Published var availableWiFiList: [String] = []



    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            bluetoothStateMessage = "Bluetooth is not powered on or not supported."
            stopScanning()
            return
        }

        devices.removeAll()
        bluetoothStateMessage = ""
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)

        // Stop after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.stopScanning()
        }
    }

   


    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
        connectedPeripheral = peripheral
        peripheral.delegate = self
    }


    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "device")")
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "unknown error")")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        for service in peripheral.services ?? [] {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        for char in service.characteristics ?? [] {
            print("Found characteristic: \(char.uuid)")
        }
    }


    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
//        case .poweredOn:
//            bluetoothStateMessage = "Bluetooth is ON"
//            startScanning()
        case .poweredOn:
            bluetoothStateMessage = "Bluetooth is ON"
                   isBluetoothOn = true
                   if shouldAutoScan {
                       startScanning()
                       shouldAutoScan = false
                   }
        case .poweredOff:
            bluetoothStateMessage = "Bluetooth is OFF. Please turn it ON."
            stopScanning()
        case .unauthorized:
            bluetoothStateMessage = "Bluetooth access unauthorized."
            stopScanning()
        case .unsupported:
            bluetoothStateMessage = "This device does not support Bluetooth."
            stopScanning()
        case .resetting:
            bluetoothStateMessage = "Bluetooth is resetting..."
            stopScanning()
        default:
            bluetoothStateMessage = "Unknown Bluetooth state."
            stopScanning()
        }

        print(bluetoothStateMessage)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)
        }
    }
}



//// MARK: - Wi-Fi Scanning via BLE
//
//extension BLEManager {
//    func requestWiFiList() {
//        guard let peripheral = connectedPeripheral else {
//            print("⚠️ No connected peripheral to request Wi-Fi list from.")
//            return
//        }
//
//        // Example: find the characteristic that supports Wi-Fi command
//        guard let wifiCharacteristic = findWiFiCharacteristic(for: peripheral) else {
//            print("⚠️ Wi-Fi characteristic not found.")
//            return
//        }
//
//        // Send scan command
//        let command = "SCAN_WIFI".data(using: .utf8)!
//        peripheral.writeValue(command, for: wifiCharacteristic, type: .withResponse)
//
//        // Set to notify for updates
//        peripheral.setNotifyValue(true, for: wifiCharacteristic)
//    }
//
//    private func findWiFiCharacteristic(for peripheral: CBPeripheral) -> CBCharacteristic? {
//        // Replace with your actual characteristic UUID
//        let wifiUUID = CBUUID(string: "YOUR_WIFI_LIST_CHARACTERISTIC_UUID")
//        for service in peripheral.services ?? [] {
//            for characteristic in service.characteristics ?? [] {
//                if characteristic.uuid == wifiUUID {
//                    return characteristic
//                }
//            }
//        }
//        return nil
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let data = characteristic.value, let message = String(data: data, encoding: .utf8) {
//            // Example: BLE device sends "Home,Office,MyWiFi"
//            let ssids = message.components(separatedBy: ",").filter { !$0.isEmpty }
//            DispatchQueue.main.async {
//                self.availableWiFiList = ssids
//            }
//        }
//    }
//}
