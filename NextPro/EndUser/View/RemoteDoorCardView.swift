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
                    Text("Waiting for response...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Inter-SemiBold", size: 13))
                        .foregroundColor(.yellow)
                        .padding(.top, 3)
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
                
                
              //  if hasWIFIAccess {
                if isStandAloneControllerTC434 {
                    ZStack {
                        if !wifiWaiting {
                            Button {
                                resetBleState()
                                startWifiWaiting()
                                onRemoteOpen()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(wifiSuccess ? "antena_active" : "antenna-signal")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                    
                                    Text("Open Door")
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        if wifiWaiting {
                            RingSpinner(
                                ringColor: .yellow,
                                lineWidth: 2.5,
                                size: 25
                            )
                        }
                    }
                    .frame(width: 68, height: 58)
                    .opacity(isWifiDisabled ? 0.2 : 1.0)
                    .allowsHitTesting(!isWifiDisabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.white.opacity(isWifiDisabled ? 0.11 : 0.3),
                                lineWidth: 1
                            )
                    )

                }
                
               // if hasBleAccess && !isStandAloneControllerTC434 {
                if !isStandAloneControllerTC434 {
                   
                    ZStack {
                        if !bleWaiting {
                            Button {
                                resetWifiState()
                                startBleWaiting()
                                onBleOpen()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(bleSuccess ? "bluetooth-blue" : "bluetooth-white")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                    
                                    Text("Open Door")
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        if bleWaiting {
                            RingSpinner(
                                ringColor: .yellow,
                                lineWidth: 2.5,
                                size: 25
                            )
                        }
                    }
                    .frame(width: 68, height: 58)
                    .opacity(isBleDisabled ? 0.2 : 1.0)
                    .allowsHitTesting(!isBleDisabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.white.opacity(isBleDisabled ? 0.11 : 0.3),
                                lineWidth: 1
                            )
                    )
                

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
