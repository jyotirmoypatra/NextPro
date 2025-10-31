//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI



struct OnboardPageFirstView: View {
    @State private var navigateToDeviceScanView = false
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

            VStack(spacing: 25) {
                Spacer()

                // Header Text
                VStack(spacing: 15) {
                    
                    
                    Image("ev-plug-charging")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("STEP 1 of 3")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                    Text("Make sure your device is plugged in and turned on!")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.11))
                )
              

                

           

                Spacer() // pushes content to bottom

                // Bottom section
                HStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                       dismiss()
                    }) {
                        Text("Prev")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        
                    }
//                    .navigationDestination(isPresented: $navigateToGetStarted) {
//                        GetStartedView()
//                    }
                    Spacer()
                    
                    // Page indicator dots
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    
                    Spacer()
                    Button(action: {
                        navigateToDeviceScanView = true
                    }) {
                        Text("Next")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        
                    }
                    .navigationDestination(isPresented: $navigateToDeviceScanView) {
                        OnboardPageDeviceScanView()
                    }

                   
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    OnboardPageFirstView()
}
