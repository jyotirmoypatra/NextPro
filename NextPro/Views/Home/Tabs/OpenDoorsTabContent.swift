//
//  OpenDoorsTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct OpenDoorsTabContent: View {
    @StateObject private var doorManager = DoorManager.shared
    @StateObject private var doorStorage = DoorStorageManager.shared
    @State private var showConfig = false
    
    var selectedDoor: DoorModel? {
        doorStorage.getSelectedDoor()
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                // Header with Reset Button
                HStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "door.left.hand.open")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        Text("Door Control")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.top, 30)
                .overlay(
                    // Reset Button on Top Right
                    Button(action: {
                        doorManager.resetState()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16))
                            Text("Reset")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.8))
                        .cornerRadius(20)
                    }
                        .padding(.trailing, 20)
                        .padding(.top, 30),
                    alignment: .topTrailing
                )
                
                // Status Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: doorManager.isProcessing ? "arrow.clockwise" : "info.circle.fill")
                            .foregroundColor(doorManager.isProcessing ? .blue : .green)
                            .font(.system(size: 20))
                            .rotationEffect(.degrees(doorManager.isProcessing ? 360 : 0))
                            .animation(doorManager.isProcessing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: doorManager.isProcessing)
                        
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if let result = doorManager.lastResult {
                            Text(result)
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(result == "Success" ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    Text(doorManager.statusMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if let error = doorManager.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.08))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.horizontal, 20)
                
                // Doors List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                        Text("Select Door")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 4)
                    
                    if doorStorage.doors.isEmpty {
                        Text("No doors configured")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(doorStorage.doors) { door in
                            DoorRowView(door: door, isSelected: door.isSelected) {
                                doorStorage.selectDoor(door)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Open Door Button
                Button(action: {
                    if let door = selectedDoor {
                        doorManager.openSelectedDoor(door)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: doorManager.isProcessing ? "hourglass" : "key.fill")
                            .font(.system(size: 24))
                        Text(doorManager.isProcessing ? "Opening..." : "Open Door")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(
                        LinearGradient(
                            colors: (doorManager.isProcessing || selectedDoor == nil) ? [Color.gray, Color.gray.opacity(0.7)] : [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: (doorManager.isProcessing || selectedDoor == nil) ? Color.clear : Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .disabled(doorManager.isProcessing || selectedDoor == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // Write Card Number Button
                Button(action: {
                    if let door = selectedDoor {
                        print("🎯 USER TAPPED: Write Card Number button")
                        print("🎯 Selected door: \(door.name)")
                        doorManager.writeCardNumber(door)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: doorManager.isProcessing ? "hourglass" : "creditcard.fill")
                            .font(.system(size: 20))
                        Text(doorManager.isProcessing ? "Writing..." : "Write Card Number")
                            .font(.body.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        (doorManager.isProcessing || selectedDoor == nil) ? Color.gray.opacity(0.5) : Color.green.opacity(0.7)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(doorManager.isProcessing || selectedDoor == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // Retrieve Card Info Button (Requires Admin eKey - Currently Disabled)
                // Uncomment if you have an admin eKey
                /*
                Button(action: {
                    if let door = selectedDoor {
                        print("🎯 USER TAPPED: Retrieve Card Info button")
                        print("🎯 Selected door: \(door.name)")
                        doorManager.retrieveCardNumbers(door)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: doorManager.isProcessing ? "hourglass" : "list.bullet.rectangle")
                            .font(.system(size: 20))
                        Text(doorManager.isProcessing ? "Retrieving..." : "Retrieve Card Info")
                            .font(.body.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        (doorManager.isProcessing || selectedDoor == nil) ? Color.gray.opacity(0.5) : Color.orange.opacity(0.7)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(doorManager.isProcessing || selectedDoor == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                */
                
                // Retrieved Cards Display (Hidden when retrieve button is disabled)
                /*
                if !doorManager.retrievedCards.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "list.number")
                                .foregroundColor(.green)
                            Text("Cards on Device (\(doorManager.retrievedCards.count))")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(Array(doorManager.retrievedCards.enumerated()), id: \.element) { index, cardNumber in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(width: 30, alignment: .leading)
                                        
                                        Text(cardNumber)
                                            .font(.body.monospaced())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                */
                
                // Configuration Toggle
                if let door = selectedDoor {
                    Button(action: { withAnimation { showConfig.toggle() }}) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text(showConfig ? "Hide Config" : "Show Config")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    if showConfig {
                        VStack(spacing: 6) {
                            configRow(label: "SN", value: door.devSn)
                            configRow(label: "MAC", value: door.devMac)
                            configRow(label: "Card", value: door.cardno)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                }
                
                // SDK Version Footer
                Text("SDK v\(doorManager.getSDKVersion())")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
        
    }
    
    private func configRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}

// MARK: - Door Row View
struct DoorRowView: View {
    let door: DoorModel
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 22))
                
                // Door icon and name
                VStack(alignment: .leading, spacing: 4) {
                    Text(door.name)
                        .font(.body.bold())
                        .foregroundColor(.white)
                    Text("SN: \(door.devSn)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            .padding(16)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    OpenDoorsTabContent()
        .background(Color.black)
}
