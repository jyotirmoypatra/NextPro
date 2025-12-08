//
//  HotspotWaveExact.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 03/12/25.
//


import SwiftUI

//struct HotspotWaveExact: View {
//    @Binding var isActive: Bool
//    @State private var animateWaves = false
//    
//    var waveColor: Color {
//        isActive ? .blue : .red
//    }
//    
//    var body: some View {
//        ZStack {
//            // Left waves
//            ForEach(0..<3) { index in
//                WaveArc(side: .left, radius: 8 + CGFloat(index) * 5)
//                    .stroke(waveColor, lineWidth: 2)
//                    .opacity(isActive ? (animateWaves ? 0.0 : 1.0) : 1.0)
//                    .scaleEffect(isActive ? (animateWaves ? 1.15 : 0.95) : 1.0)
//                    .animation(
//                        isActive ? .easeOut(duration: 2)
//                            .repeatForever(autoreverses: false)
//                            .delay(Double(index) * 0.4) : .default,
//                        value: animateWaves
//                    )
//            }
//
//            // Center dot
//            Circle()
//                .fill(waveColor)
//                .frame(width: 6, height: 6)
//
//            // Right waves
//            ForEach(0..<3) { index in
//                WaveArc(side: .right, radius: 8 + CGFloat(index) * 5)
//                    .stroke(waveColor, lineWidth: 2)
//                    .opacity(isActive ? (animateWaves ? 0.0 : 1.0) : 1.0)
//                    .scaleEffect(isActive ? (animateWaves ? 1.15 : 0.95) : 1.0)
//                    .animation(
//                        isActive ? .easeOut(duration: 2)
//                            .repeatForever(autoreverses: false)
//                            .delay(Double(index) * 0.4) : .default,
//                        value: animateWaves
//                    )
//            }
//        }
//        .frame(width: 60, height: 24)
//        .fixedSize()
//        .rotationEffect(.degrees(0))
//        .onAppear {
//            if isActive {
//                animateWaves = true
//            }
//        }
//        .onChange(of: isActive) { newValue in
//            if newValue {
//                animateWaves = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    animateWaves = true
//                }
//            } else {
//                animateWaves = false
//            }
//        }
//    }
//}




// MARK: - Wave Arc Shape
//struct WaveArc: Shape {
//    enum Side {
//        case left, right
//    }
//    
//    let side: Side
//    let radius: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        
//        if side == .left {
//            // Left curved arc (opening to the left)
//            path.addArc(
//                center: center,
//                radius: radius,
//                startAngle: .degrees(135),
//                endAngle: .degrees(225),
//                clockwise: false
//            )
//        } else {
//            // Right curved arc (opening to the right)
//            path.addArc(
//                center: center,
//                radius: radius,
//                startAngle: .degrees(-45),
//                endAngle: .degrees(45),
//                clockwise: false
//            )
//        }
//        
//        return path
//    }
//}






//------------WiFi like wave------------------------------

struct HotspotWaveExact: View {
    @Binding var isActive: Bool

    @State private var visibleWave: Int = 0
    @State private var resetWaves: Bool = false

    var waveColor: Color { isActive ? .blue : .red }

    var body: some View {
        ZStack {

            // --- Waves ---
            ForEach(1...3, id: \.self) { index in
                
                let shouldShow = isActive ? (visibleWave >= index && !resetWaves) : true
                let opacity: CGFloat = shouldShow ? 1.0 : 0.0
                let scale: CGFloat = isActive
                    ? (shouldShow ? 1.0 : 0.4)
                    : 1.0

                // Increase radius so first wave doesn't match dot height
                let radius = CGFloat(index * 5 + 3)

                WaveArc(side: .left, radius: radius)
                    .stroke(waveColor.opacity(opacity), lineWidth: 1.4)
                    .scaleEffect(scale)
                    .animation(isActive ? .easeOut(duration: 0.3) : .none,
                               value: visibleWave)

                WaveArc(side: .right, radius: radius)
                    .stroke(waveColor.opacity(opacity), lineWidth: 1.4)
                    .scaleEffect(scale)
                    .animation(isActive ? .easeOut(duration: 0.3) : .none,
                               value: visibleWave)
            }


            // --- Center dot ---
            Circle()
                .fill(waveColor)
                .frame(width: 5, height: 5)
        }
        .frame(width: 60, height: 30)
        .onAppear {
            if isActive { startLoop() }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startLoop()
            } else {
                stopLoop()
            }
        }
    }

    // MARK: - Animation Loop
    func startLoop() {
        visibleWave = 0
        resetWaves = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            run()
        }
    }

    func stopLoop() {
        visibleWave = 3       // <-- Show all waves
        resetWaves = false    // <-- Do NOT hide them
    }

    func run() {
        guard isActive else { return }

        visibleWave = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard isActive else { return }
            visibleWave = 2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            guard isActive else { return }
            visibleWave = 3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            resetWaves = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            guard isActive else { return }
            resetWaves = false
            visibleWave = 0
            run()
        }
    }
}

struct WaveArc: Shape {
    enum Side { case left, right }
    let side: Side
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)

        switch side {
        case .left:
            p.addArc(center: c,
                     radius: radius,
                     startAngle: .degrees(140),
                     endAngle: .degrees(220),
                     clockwise: false)

        case .right:
            p.addArc(center: c,
                     radius: radius,
                     startAngle: .degrees(-40),
                     endAngle: .degrees(40),
                     clockwise: false)
        }

        return p
    }
}



//------------WiFi like wave end------------------------------//
