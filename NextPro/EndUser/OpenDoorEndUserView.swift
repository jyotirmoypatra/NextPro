//  OpenDoorEndUserView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct OpenDoorEndUserView: View {
    @State private var doors = [
        DoorModelUser(name: "Iron Hive Gym: Gate", duration: "For 5 Second"),
        DoorModelUser(name: "Iron Hive Gym: DOOR 1", duration: "For 5 Second"),
        DoorModelUser(name: "Iron Hive Gym: DOOR 2", duration: "For 5 Second")
    ]
    
    var body: some View {
        ZStack {
        
            VStack(spacing: 0) {
                // ✅ Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome!")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                        Text("James Arthur")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.black)
                .zIndex(1)
                
                
             
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(doors, id: \.name) { door in
                            DoorCardView(door: door)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color.black.opacity(0.4))
    }
}


struct DoorCardView: View {
    let door: DoorModelUser
    var progress: CGFloat = 0.8   // 🔹 Static 80% progress ring (0.0 → 1.0)
    
    var body: some View {
        HStack {
            // Left icon
          
            
            // Door details
            VStack(alignment: .leading, spacing: 5) {
                Image("dooricon")
                    .frame(width: 52, height: 48)
                
                Text(door.name)
                    .font(.headline)
                    .font(.custom("Inter-SemiBold", size: 16))
                
                Text(door.duration)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            
            // ✅ Lock Circle with static ring
            ZStack {
                // Black background circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 48, height: 48)
                
                // Static white progress ring (no animation)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90)) // start from top
                
                // Lock icon
                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(Color.white.opacity(0.09))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}


struct DoorModelUser {
    let name: String
    let duration: String
}

#Preview {
    OpenDoorEndUserView()
}
