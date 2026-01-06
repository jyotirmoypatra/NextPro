//
//  RemoteDoorCardView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 22/12/25.
//
import SwiftUI


struct RemoteDoorCardView: View {
    let door: RemoteDoorItem
    @Binding var successKey: String?
    @Binding var activeDoorKey: String?
    @Binding var isBluetoothOn: Bool
    @Binding var showBluetoothAlert: Bool
    let onRemoteOpen: () -> Void
    let onBleOpen: () -> Void
    
    
    @State private var wifiWaiting = false
    @State private var bleWaiting = false
    
    @State private var wifiSuccess = false
    @State private var bleSuccess = false
    
    
    @State private var wifiWaitTask: DispatchWorkItem?
    @State private var bleWaitTask: DispatchWorkItem?
    
    @State private var wifiSuccessTask: DispatchWorkItem?
    @State private var bleSuccessTask: DispatchWorkItem?
    
    
    private var isAdmin: Bool {
        //  UserDefaults.standard.bool(forKey: "is_admin")
        false
    }
    
    private var hasWIFIAccess: Bool {
        //  UserDefaults.standard.bool(forKey: "remote_wifi")
        true
    }
    private var hasBleAccess: Bool {
        // UserDefaults.standard.bool(forKey: "remote_ble")
        true
    }
    
    private var isWifiDisabled: Bool {
        bleWaiting || bleSuccess
    }
    
    private var isBleDisabled: Bool {
        wifiWaiting || wifiSuccess
    }
    
    private var isDisabledAll: Bool {
        wifiWaiting || wifiSuccess ||  bleWaiting || bleSuccess
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
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 12, height: 12)
                        
                        Text("Door Unlocked!")
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                                       // Image(wifiSuccess ? "wifi_active" : "wifi")
                                        Image(systemName: "wifi")
                                          //  .resizable()
                                            .font(.system(size: 18))
                                            .foregroundColor(wifiWaiting ? .yellow : wifiSuccess ? .green : .white)
                                        
                                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(.white)
                                    }
                                }
                           // }
                            
                        }
                        .frame(width: 68, height: 58)
//                        .opacity(isWifiDisabled ? 0.2 : 1.0)
//                        .allowsHitTesting(!isWifiDisabled)
                        .opacity(isDisabledAll ? 0.2 : 1.0)
                        .allowsHitTesting(!isDisabledAll)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.white.opacity(isDisabledAll ? 0.11 : 0.3),
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
                                            Image(bleWaiting ? "bluetooth-yellow" : bleSuccess ? "bluetooth-green" : "bluetooth-white")
                                             .resizable()
                                             .frame(width: 22, height: 22)
                                               
                                            
                                            Text("Open Door")
                                                .font(.custom("Inter-Regular", size: 10))
                                                .foregroundColor(.white)
                                        }
                                    }
                               // }
                                
                            }
                            .frame(width: 68, height: 58)
//                            .opacity(isBleDisabled ? 0.2 : 1.0)
//                            .allowsHitTesting(!isBleDisabled)
                            .opacity(isDisabledAll ? 0.2 : 1.0)
                            .allowsHitTesting(!isDisabledAll)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color.white.opacity(isDisabledAll ? 0.11 : 0.3),
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
                                      Image(systemName: wifiSuccess ? "lock.open" : "lock" )
                                            //.resizable()
                                            .font(.system(size: 18))
                                            .foregroundColor(bleWaiting ? .yellow : bleSuccess ? .green : .white)
                                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(.white)
                                    }
                                }
                           // }
                            
                        }
                        .frame(width: 68, height: 58)
//                        .opacity(isWifiDisabled ? 0.2 : 1.0)
//                        .allowsHitTesting(!isWifiDisabled)
                        .opacity(isDisabledAll ? 0.2 : 1.0)
                        .allowsHitTesting(!isDisabledAll)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.white.opacity(isDisabledAll ? 0.11 : 0.3),
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
                                        Image(systemName:  bleSuccess ? "lock.open" : "lock" )
                                           // .resizable()
                                            .font(.system(size: 18))
                                            .foregroundColor(bleWaiting ? .yellow : bleSuccess ? .green : .white)
                        
                                        Text("Open Door")
                                            .font(.custom("Inter-Regular", size: 10))
                                            .foregroundColor(.white)
                                    }
                                }
                            //}
                            
                        }
                        .frame(width: 68, height: 58)
//                        .opacity(isBleDisabled ? 0.2 : 1.0)
//                        .allowsHitTesting(!isBleDisabled)
                        .opacity(isDisabledAll ? 0.2 : 1.0)
                        .allowsHitTesting(!isDisabledAll)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.white.opacity(isDisabledAll ? 0.11 : 0.3),
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
        
        .onChange(of: successKey) { key in
            guard key == door.key else { return }
            
            // 🔥 Decide success type based on active waiting state
            if wifiWaiting {
                showWifiSuccess()
            } else if bleWaiting {
                showBleSuccess()
            }
            
            DispatchQueue.main.async {
                successKey = nil
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
        
        wifiWaitTask?.cancel()
        
        let task = DispatchWorkItem {
            wifiWaiting = false
            activeDoorKey = nil
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
                activeDoorKey = nil   // 👈 unlock other cards
            }
        }
        
        wifiSuccessTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    
    private func startBleWaiting() {
        bleWaiting = true
        bleSuccess = false
        
        bleWaitTask?.cancel()
        
        let task = DispatchWorkItem {
            bleWaiting = false
            activeDoorKey = nil
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
                activeDoorKey = nil   // 👈 unlock other cards
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
    }
    
    private func resetBleState() {
        bleWaitTask?.cancel()
        bleSuccessTask?.cancel()
        bleWaiting = false
        bleSuccess = false
    }
    
    
}

struct RingSpinner: View {
    var ringColor: Color = .yellow
    var lineWidth: CGFloat = 3
    var size: CGFloat = 25
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1.0)
            .stroke(
                ringColor,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 0.9)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
