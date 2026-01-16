//
//  RemoteDoorCardView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 22/12/25.
//
import SwiftUI


struct RemoteMQTTResult: Equatable {
    let doorKey: String
    let isSuccess: Bool
    let message: String
}


struct RemoteDoorCardView: View {
    let door: RemoteDoorItem
    @Binding var activeDoorKey: String?
    @Binding var mqttResult: RemoteMQTTResult?
    @Binding var isBluetoothOn: Bool
    @Binding var showBluetoothAlert: Bool
    let onRemoteOpen: () -> Void
    let onBleOpen: () -> Void

    @State private var isResultSuccess: Bool = false
    @State private var statusMessage: String = ""

    
    @State private var wifiWaiting = false
    @State private var bleWaiting = false
    
    @State private var wifiSuccess = false
    @State private var bleSuccess = false
    
    
    @State private var wifiWaitTask: DispatchWorkItem?
    @State private var bleWaitTask: DispatchWorkItem?
    
    @State private var wifiSuccessTask: DispatchWorkItem?
    @State private var bleSuccessTask: DispatchWorkItem?
    
    
    private var isAdmin: Bool {
       UserDefaults.standard.bool(forKey: "is_admin")
      //  true
    }
    
    private var hasWIFIAccess: Bool {
        UserDefaults.standard.bool(forKey: "remote_wifi")
       // true
    }
    private var hasBleAccess: Bool {
         UserDefaults.standard.bool(forKey: "remote_ble")
        //true
    }
    
    //
    
    // MARK: - Button State Helpers

    private var isWifiActive: Bool {
        wifiWaiting || wifiSuccess
    }

    private var isBleActive: Bool {
        bleWaiting || bleSuccess
    }

    private var wifiOpacity: Double {
        if isWifiActive { return 0.7 }
        if isBleActive { return 0.2 }
        return 1.0
    }

    private var bleOpacity: Double {
        if isBleActive { return 0.7 }
        if isWifiActive { return 0.2 }
        return 1.0
    }

    private var wifiHitTesting: Bool {
        !(isWifiActive || isBleActive)
    }

    private var bleHitTesting: Bool {
        !(isBleActive || isWifiActive)
    }
    
    private var wifiBorderOpacity: Double {
        if isWifiActive { return 0.3 }   // active
        if isBleActive { return 0.11 }   // disabled by BLE
        return 0.3                       // idle
    }

    private var bleBorderOpacity: Double {
        if isBleActive { return 0.3 }    // active
        if isWifiActive { return 0.11 }  // disabled by WiFi
        return 0.3                       // idle
    }

    private var isStandAloneControllerTC434: Bool {
        door.doorType == "standalone_controller" && door.doorControllerType == "TC434"
    }
    
    
    var body: some View {
        HStack(spacing: 16) {
            
            // LEFT : Door name
            VStack{
                Text(door.doorName)
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                if wifiWaiting || bleWaiting {
                    HStack {
                        RingSpinner(
                            ringColor: .yellow,
                            lineWidth: 1.5,
                            size: 13
                        )
                        Text("Verifying Please Wait...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.yellow)
                            .padding(.top, 3)
                    }
                }
                
                if wifiSuccess || bleSuccess {
                    HStack {
                        if isResultSuccess{
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .frame(width: 12, height: 12)
                            
                            Text(statusMessage)
                                .font(.custom("Inter-SemiBold", size: 13))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }else{
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .frame(width: 12, height: 12)
                            
                            Text(statusMessage)
                                .font(.custom("Inter-SemiBold", size: 13))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    }
                }
                
            }
            
            
            // RIGHT : Action buttons
            // RIGHT : Action buttons (fixed layout)
            HStack(spacing: 18) {
                
                
                if isAdmin {
//====================================Admin Part==================================================================//
                    if hasWIFIAccess || isStandAloneControllerTC434 {
                        ZStack {
                          //  if !wifiWaiting {
                                Button {
                                    resetBleState()
                                    startWifiWaiting()
                                    onRemoteOpen()
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: "wifi")
                                            .font(.system(size: 18))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess && isResultSuccess ? .green : wifiSuccess && !isResultSuccess ? .red : .white)
                                        
                                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess && isResultSuccess ? .green : wifiSuccess && !isResultSuccess ? .red : .white)
                                    }
                                }
                           // }
                            
                        }
                        .frame(width: 68, height: 58)
                        .opacity(wifiOpacity)
                        .allowsHitTesting(wifiHitTesting)

                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    wifiWaiting ? .yellow.opacity(wifiBorderOpacity) : wifiSuccess && isResultSuccess ? .green.opacity(wifiBorderOpacity) : wifiSuccess && !isResultSuccess ? .red.opacity(wifiBorderOpacity) : .white.opacity(wifiBorderOpacity),
                                   
                                    lineWidth: 1
                                )
                        )
                        
                    }
                    
                    if hasBleAccess {
                        if !isStandAloneControllerTC434 {
                            
                            ZStack {
                               // if !bleWaiting {
                                    Button {
                                        guard isBluetoothOn else {
                                                showBluetoothAlert = true
                                                return
                                            }
                                        resetWifiState()
                                        startBleWaiting()
                                        onBleOpen()
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(bleWaiting ? "bluetooth-yellow" : bleSuccess && isResultSuccess ? "bluetooth-green" :  bleSuccess && !isResultSuccess ? "bluetooth-red" : "bluetooth-white")
                                             .resizable()
                                             .frame(width: 22, height: 22)
                                               
                                            
                                            Text("Open Door")
                                                .font(.custom("Inter-Regular", size: 10))
                                                .foregroundColor(bleWaiting ? .yellow : bleSuccess && isResultSuccess ? .green : bleSuccess && !isResultSuccess ? .red : .white)
                                        }
                                    }
                               // }
                                
                            }
                            .frame(width: 68, height: 58)
                            .opacity(bleOpacity)
                            .allowsHitTesting(bleHitTesting)

                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        bleWaiting ? .yellow.opacity(bleBorderOpacity) : bleSuccess && isResultSuccess ? .green.opacity(bleBorderOpacity) : bleSuccess && !isResultSuccess ? .red.opacity(bleBorderOpacity) : .white.opacity(bleBorderOpacity),
                                        lineWidth: 1
                                    )
                            )
                            
                            
                        }
                    }
//====================================Admin Part End==================================================================//
                }
                
                else{
//====================================Normal user Part Start==================================================================//
                    if isStandAloneControllerTC434 {
                        ZStack {
                           // if !wifiWaiting {
                                Button {
                                    resetBleState()
                                    startWifiWaiting()
                                    onRemoteOpen()
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(wifiWaiting ? "lock-yellow" : wifiSuccess && isResultSuccess ? "lock-open-green" :  wifiSuccess && !isResultSuccess ? "lock-red" : "lock-white")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                              
                                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess && isResultSuccess ? .green : wifiSuccess && !isResultSuccess ? .red : .white)
                                    }
                                }
                           // }
                            
                        }
                        .frame(width: 68, height: 58)
                        .opacity(wifiOpacity)
                        .allowsHitTesting(wifiHitTesting)

                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    wifiWaiting ? .yellow.opacity(wifiBorderOpacity) : wifiSuccess && isResultSuccess ? .green.opacity(wifiBorderOpacity) : wifiSuccess && !isResultSuccess ? .red.opacity(wifiBorderOpacity) : .white.opacity(wifiBorderOpacity),
                                    lineWidth: 1
                                )
                        )
                        
                    }
                    
                    
                    if !isStandAloneControllerTC434 {
                        
                        ZStack {
                          //  if !bleWaiting {
                                Button {
                                    guard isBluetoothOn else {
                                            showBluetoothAlert = true
                                            return
                                        }
                                    resetWifiState()
                                    startBleWaiting()
                                    onBleOpen()
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(bleWaiting ? "lock-yellow" : bleSuccess && isResultSuccess ? "lock-open-green" :  bleSuccess && !isResultSuccess ? "lock-red" : "lock-white")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(bleWaiting ? .yellow : bleSuccess && isResultSuccess ? .green : bleSuccess && !isResultSuccess ? .red : .white)
                                    }
                                }
                            //}
                            
                        }
                        .frame(width: 68, height: 58)
                        .opacity(bleOpacity)
                        .allowsHitTesting(bleHitTesting)

                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    bleWaiting ? .yellow.opacity(bleBorderOpacity) : bleSuccess && isResultSuccess ? .green.opacity(bleBorderOpacity) : bleSuccess && !isResultSuccess ? .red.opacity(bleBorderOpacity) : .white.opacity(bleBorderOpacity),
                                    lineWidth: 1
                                )
                        )
                        
                        
                    }
//====================================Normal user Part End==================================================================//
                }
                
            }
            
        }
        .opacity(isDisabled ? 0.2 : 1.0)
        .allowsHitTesting(!isDisabled)
        
        
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        
        
        .onChange(of: mqttResult) { result in
            guard let result else { return }
            guard result.doorKey == door.key else { return }
            
            isResultSuccess = result.isSuccess
            statusMessage = result.message
            
            if wifiWaiting {
                showWifiSuccess()
            } else if bleWaiting {
                showBleSuccess()
            }
            
            DispatchQueue.main.async {
                mqttResult = nil
            }
        }

        
        
        
    }
    private var isDisabled: Bool {
        guard let active = activeDoorKey else { return false }
        return active != door.key
    }
    
    private func startWifiWaiting() {
        wifiWaiting = true
        wifiSuccess = false
        
        isResultSuccess = false
        statusMessage = ""
        
        wifiWaitTask?.cancel()
        
//        let task = DispatchWorkItem {
//            wifiWaiting = false
//            activeDoorKey = nil
//        }
//        
//        wifiWaitTask = task
//        DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: task)
        let task = DispatchWorkItem {
                // ⏱️ 7 sec timeout
                wifiWaiting = false
                wifiSuccess = true          // show result UI
                isResultSuccess = false     //failure
                statusMessage = "No response received from the door"

                // reset after 3 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resetWifiState()
                    activeDoorKey = nil
                }
            }

            wifiWaitTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: task)
    }
    
    private func showWifiSuccess() {
        wifiWaitTask?.cancel()
        
        wifiWaiting = false
        wifiSuccess = true
        
        wifiSuccessTask?.cancel()
        
        let task = DispatchWorkItem {
            wifiSuccess = false
            DispatchQueue.main.async {
                activeDoorKey = nil   // unlock other cards
            }
        }
        
        wifiSuccessTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    
    private func startBleWaiting() {
        bleWaiting = true
        bleSuccess = false
        isResultSuccess = false
            statusMessage = ""
        bleWaitTask?.cancel()
        
//        let task = DispatchWorkItem {
//            bleWaiting = false
//            activeDoorKey = nil
//        }
//        
//        bleWaitTask = task
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
        let task = DispatchWorkItem {
                // ⏱️ 10 sec timeout (BLE slower)
                bleWaiting = false
                bleSuccess = true           // show result UI
                isResultSuccess = false     // failure
                statusMessage = "No response received from the door"

                // reset after 3 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resetBleState()
                    activeDoorKey = nil
                }
            }

            bleWaitTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
    }
    
    private func showBleSuccess() {
        bleWaitTask?.cancel()
        
        bleWaiting = false
        bleSuccess = true
        
        bleSuccessTask?.cancel()
        
        let task = DispatchWorkItem {
            bleSuccess = false
            DispatchQueue.main.async {
                activeDoorKey = nil   // unlock other cards
            }
        }
        
        bleSuccessTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    private func resetWifiState() {
        wifiWaitTask?.cancel()
        wifiSuccessTask?.cancel()
        wifiWaiting = false
        wifiSuccess = false
        mqttResult = nil
    }
    
    private func resetBleState() {
        bleWaitTask?.cancel()
        bleSuccessTask?.cancel()
        bleWaiting = false
        bleSuccess = false
        mqttResult = nil
    }
    
    
}


