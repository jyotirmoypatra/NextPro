//
//  DeviceInformationView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI
import CoreBluetooth
import Combine

struct DeviceInformationView: View {
    let selectedDevice:AssignDevice
    @ObservedObject private var doorManager = DoorManager.shared
    @State private var showDeviceInfo = false
    @StateObject private var bleManager = BLEManager()
    @State private var showDeviceOfflineAlert = false
    @Environment(\.dismiss) private var dismiss
    @State private var tcScanTask: Task<Void, Never>?
    @State private var tcScanTimeoutTask: Task<Void, Never>?
    @State private var tcDeviceFound = false
    @State private var isCheckingDevice = false
    @State private var alertMessage = ""
    @State private var icon = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack(spacing: 15) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .overlay(
                        Text("\(selectedDevice.modelName) (\(selectedDevice.serial))")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.top, 10)
                    .padding(.bottom,10)
                    
                    
                    ScrollView(showsIndicators: false) {
                        //device information
                        Spacer(minLength: 10)
                        VStack(spacing: 20){
                            HStack(){
                                Text("Device SN")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.serial)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Model")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.modelName)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Mac")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.mac)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
//                            Divider().background(Color.gray.opacity(0.3))
                            
//                            HStack{
//                                Text("Device eKey")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Text(selectedDevice.key)
//                                    .foregroundColor(Color(hex: "#6D717F"))
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .multilineTextAlignment(.trailing)
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                
//                            }
//                            
//                            Divider().background(Color.gray.opacity(0.3))
                            
//                            HStack{
//                                Text("Device Dev Type")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Text(String(selectedDevice.devType ?? 14))
//                                    .foregroundColor(Color(hex: "#6D717F"))
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .multilineTextAlignment(.trailing)
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                
//                            }
//                            
//                            Divider().background(Color.gray.opacity(0.3))
//                            
//                            HStack{
//                                Text("Device Open Type")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Text(String(selectedDevice.openType ?? 2))
//                                    .foregroundColor(Color(hex: "#6D717F"))
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .multilineTextAlignment(.trailing)
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                
//                            }
                        }
                        .padding(15)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        
                        //
                        Spacer(minLength: 30)
                        HStack(){
                            Text("DEVICE SETTINGS")
                                .foregroundColor(.white)
                                .font(.custom("Inter-Medium", size: 16))
                                .padding(.trailing,10)
                                .padding(.trailing,5)
                            
                            Spacer()
                            
                        }
                        
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 20){
//                            HStack(){
//                                Text("Get Device Information")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 15, weight: .medium))
//                                
//                            }
                            
                            Button {
                                
                                
                                
                                fetchDeviceInfo()
                            } label: {
                                HStack {
                                    Text("Get Device Information")
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Medium", size: 16))

                                    Spacer()

                                    if doorManager.isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                }
                            }
                            .disabled(doorManager.isProcessing || isCheckingDevice)


                            
//                            Divider().background(Color.gray.opacity(0.3))
//                            
//                            HStack(){
//                                Text("Configure Wifi")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 15, weight: .medium))
//                                
//                            }
//                            
//                            Divider().background(Color.gray.opacity(0.3))
//                            
//                            HStack{
//                                Text("Upgrade Bluetooth Firmware")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 15, weight: .medium))
//                            }
//                            
//                            Divider().background(Color.gray.opacity(0.3))
//                            
//                            HStack{
//                                Text("Reset Device Configurations")
//                                    .foregroundColor(.white)
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .padding(.trailing,10)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 15, weight: .medium))
//                                
//                            }
                            
                        }
                        .padding(15)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        
                        Spacer(minLength: 30)
                    }
                   
                }
                .padding(.horizontal,10)
                
                
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
                
                if isCheckingDevice || doorManager.isProcessing{
                    ZStack {
                        Color.black.opacity(0.8)
                            .ignoresSafeArea()

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
        .onAppear {
            doorManager.isProcessing = false
                doorManager.deviceConfig = nil
                bleManager.stopScanning()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationDestination(isPresented: $showDeviceInfo) {
            if let info = doorManager.deviceConfig {
                DeviceInfoDetailView(deviceInfo: info)
            }
        }
        .onReceive(doorManager.$deviceConfig) { config in
            if config != nil {
                showDeviceInfo = true
            }
        }

    }
    
    private var isBluetoothOff: Bool {
        bleManager.bleState == .poweredOff
    }
    
    private func fetchDeviceInfo() {
        
        if isBluetoothOff {
            icon = "bluetooth-red"
            alertMessage = "Bluetooth is turned off.\nPlease enable Bluetooth to proceed."
            showDeviceOfflineAlert = true
            return
        }
        
        startDeviceScan(serial: selectedDevice.serial)
        
        
        
    }

    
    
    private func startDeviceScan(serial: String) {
        isCheckingDevice = true
        tcDeviceFound = false

        // Cancel old tasks
        tcScanTask?.cancel()
        tcScanTimeoutTask?.cancel()

        bleManager.startScanning()

        // 🔍 Scan task
        tcScanTask = Task { @MainActor in
            for await devices in bleManager.$devices.values {
                for peripheral in devices {
                    let name = (peripheral.name ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if name.contains(serial) {
                        print("TC434 detected via BLE:", name)

                        tcDeviceFound = true
                        stopTCScan()

                        doorManager.getDeviceInfo(
                            for: DoorModelUser(
                                name: selectedDevice.modelName,
                                devSn: selectedDevice.serial,
                                devMac: selectedDevice.mac,
                                devType: Int32(selectedDevice.devType ?? 14),
                                doorID: 0,
                                eKey: selectedDevice.key,
                                cardno: ""
                            )
                        )
                        
                        

                        // Observe result and navigate once data arrives
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            waitForDeviceInfo()
//                        }

                        return
                    }
                }
            }
        }

        // ⏱ Timeout task (ONLY if not found)
        tcScanTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 15_000_000_000)

            guard !tcDeviceFound else {
                return   // device already found → do nothing
            }

            stopTCScan()

            icon = "power-off"
            alertMessage =
            "The selected device is currently not powered on.\nPlease turn on the device to proceed."
            showDeviceOfflineAlert = true
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
    
    private func waitForDeviceInfo() {
        if doorManager.deviceConfig != nil {
            showDeviceInfo = true
        } else if doorManager.isProcessing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                waitForDeviceInfo()
            }
        }
    }

}

#Preview {
    SuccessConnctionView()
}

