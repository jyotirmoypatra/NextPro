//
//  RemoteDoorCardView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 22/12/25.
//
import SwiftUI


struct RemoteDoorCardView: View {
    let door: RemoteDoorItem
    let onRemoteOpen: () -> Void
    let onBLEOpen: () -> Void

    private var hasRemoteBLEAccess: Bool {
        UserDefaults.standard.bool(forKey: "digital_access")
    }

    private var hasRemoteWIFIAccess: Bool {
        UserDefaults.standard.bool(forKey: "remote_access")
    }

    var body: some View {
        HStack(spacing: 16) {

            // LEFT : Door name
            Text(door.doorName)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // RIGHT : Action buttons
            HStack(spacing: 18) {

                if hasRemoteWIFIAccess {
                    Button(action: onRemoteOpen) {
                        VStack(spacing: 6) {
                            Image("antenna-signal")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)

                            Text("Open Door")
                                .font(.custom("Inter-Regular", size: 10))
                                .foregroundColor(.white)
                        }
                        .frame(width: 68, height: 58) // ✅ fixed size
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

//                if hasRemoteBLEAccess {
//                    Button(action: onBLEOpen) {
//                        VStack(spacing: 6) {
//                            Image("bluetooth-white")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 22, height: 22)
//
//                            Text("Open Door")
//                                .font(.custom("Inter-Regular", size: 10))
//                                .foregroundColor(.white)
//                        }
//                        .frame(width: 68, height: 58) // ✅ same size
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                        )
//                    }
//                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
