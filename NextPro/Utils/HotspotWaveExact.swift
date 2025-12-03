//
//  HotspotWaveExact.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 03/12/25.
//


import SwiftUI

struct HotspotWaveExact: View {
    @Binding var isActive: Bool
    @State private var animateWaves = false
    
    var waveColor: Color {
        isActive ? .blue : .red
    }
    
    var body: some View {
        ZStack {
            // Left waves
            ForEach(0..<3) { index in
                WaveArc(side: .left, radius: 8 + CGFloat(index) * 5)
                    .stroke(waveColor, lineWidth: 2)
                    .opacity(isActive ? (animateWaves ? 0.0 : 1.0) : 1.0)
                    .scaleEffect(isActive ? (animateWaves ? 1.15 : 0.95) : 1.0)
                    .animation(
                        isActive ? .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4) : .default,
                        value: animateWaves
                    )
            }

            // Center dot
            Circle()
                .fill(waveColor)
                .frame(width: 6, height: 6)

            // Right waves
            ForEach(0..<3) { index in
                WaveArc(side: .right, radius: 8 + CGFloat(index) * 5)
                    .stroke(waveColor, lineWidth: 2)
                    .opacity(isActive ? (animateWaves ? 0.0 : 1.0) : 1.0)
                    .scaleEffect(isActive ? (animateWaves ? 1.15 : 0.95) : 1.0)
                    .animation(
                        isActive ? .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4) : .default,
                        value: animateWaves
                    )
            }
        }
        .frame(width: 60, height: 24)
        .fixedSize()
        .rotationEffect(.degrees(0))
        .onAppear {
            if isActive {
                animateWaves = true
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                animateWaves = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateWaves = true
                }
            } else {
                animateWaves = false
            }
        }
    }
}


// MARK: - Wave Arc Shape
struct WaveArc: Shape {
    enum Side {
        case left, right
    }
    
    let side: Side
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        if side == .left {
            // Left curved arc (opening to the left)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(135),
                endAngle: .degrees(225),
                clockwise: false
            )
        } else {
            // Right curved arc (opening to the right)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-45),
                endAngle: .degrees(45),
                clockwise: false
            )
        }
        
        return path
    }
}

