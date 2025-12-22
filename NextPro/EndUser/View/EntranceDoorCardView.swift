//
//  EntranceDoorCardView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 22/12/25.
//
import SwiftUI

struct RemoteDoorCardView: View {
    let door: DoorModelUser
    let onRemoteOpen: () -> Void
    let onBLEOpen: () -> Void
    
    private var hasRemoteBLEAccess: Bool {
            UserDefaults.standard.bool(forKey: "remote_ble")
        }
        private var hasRemoteWIFIAccess: Bool {
            UserDefaults.standard.bool(forKey: "remote_wifi")
    }

    var body: some View {
        HStack(spacing: 16) {

            // Door name
            Text(door.name)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasRemoteWIFIAccess {
                // Remote Open
                Button(action: onRemoteOpen) {
                    VStack(spacing: 4) {
                        Image("antenna-signal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Remote Open")
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // BLE Open
            if hasRemoteBLEAccess {
                Button(action: onBLEOpen) {
                    VStack(spacing: 4) {
                        Image("bluetooth-white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("BLE Open")
                            .font(.custom("Inter-SemiBold", size: 13))
                            .foregroundColor(.white)
                    }
                }
                
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
