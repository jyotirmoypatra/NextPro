//
//  ScanDeviceListView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct SuccessConnctionView: View {
    @State private var navigateToHome = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            // Background image
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Black translucent overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 25) {
                    // Success title
                    Text("SUCCESS")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // Message
                    Text("Your device has been successfully connected!")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Continue button
                    Button(action: {
                        // Navigate to home
                        navigateToHome = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Continue to Home")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.black)

                            Image("arrow-right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10) // Rounded corners
                    }
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.12))
                )

                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    SuccessConnctionView()
}

