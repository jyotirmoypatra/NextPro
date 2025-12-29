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
    
    @State private var isWaiting = false
    @State private var isSuccess = false
    
    @State private var waitTask: DispatchWorkItem?
    @State private var successTask: DispatchWorkItem?
    
    private var hasRemoteWIFIAccess: Bool {
        UserDefaults.standard.bool(forKey: "remote_access")
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
                
                
                if isWaiting {
                    Text("Waiting for response...")
                        .font(.custom("Inter-SemiBold", size: 13))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top,3)
                }
                
                if isSuccess{
                    HStack{
                        Image(systemName:"checkmark")
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

                if hasRemoteWIFIAccess {
                    ZStack {

                        // BUTTON
                        if !isWaiting {
                            Button {
                                startWaiting()
                                onRemoteOpen()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(isSuccess ? "antena_active" : "antenna-signal")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)

                                    Text("Open Door")
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        // SPINNER (same position)
                        if isWaiting {
                            RingSpinner(
                                ringColor: .yellow,
                                lineWidth: 2.5,
                                size: 25
                            )
                        }
                    }
                    // 🔥 FIXED SIZE — KEY PART
                    .frame(width: 68, height: 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
        
        // 🔔 MQTT success — can arrive ANY time
        .onChange(of: successKey) { key in
            guard key == door.key else { return }
            
            showSuccess()
            
            // ✅ CONSUME EVENT
            DispatchQueue.main.async {
                successKey = nil
            }
        }
        
        
    }
    private var isDisabled: Bool {
        guard let active = activeDoorKey else { return false }
        return active != door.key
    }


    private func startWaiting() {
        isWaiting = true
        isSuccess = false
        
        waitTask?.cancel()
        
        let task = DispatchWorkItem {
            isWaiting = false
            DispatchQueue.main.async {
                    activeDoorKey = nil   // 👈 unlock other cards
                }
        }
        
        waitTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: task)
    }
    
    private func showSuccess() {
        waitTask?.cancel()
        
        isWaiting = false
        isSuccess = true
        
        successTask?.cancel()
        
        let task = DispatchWorkItem {
            isSuccess = false
            DispatchQueue.main.async {
                    activeDoorKey = nil   // 👈 unlock other cards
                }
        }
        
        successTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
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
