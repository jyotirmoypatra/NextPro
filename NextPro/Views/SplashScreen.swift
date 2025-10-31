//
//  SplashScreen.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        GeometryReader { geometry in
            Image("Splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height) // match screen exactly
                .clipped() // ensures nothing overflows
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

