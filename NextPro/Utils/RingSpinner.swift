//
//  RingSpinner.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 08/01/26.
//

import SwiftUI

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
