//
//  GetStartedView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI



struct GetStartedView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToFirstView = false
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
                VStack(spacing: 5) {
                    Text("WELCOME TO ACCESS CONTROL!")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                    Text("There are 3 steps you need to take in order to get started.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.11))
                )
              

                

           

                Spacer() // pushes content to bottom

                // Bottom section
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        navigateToFirstView = true
                    }) {
                        Text("GET STARTED")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $navigateToFirstView) {
                        OnboardPageFirstView()
                    }

                   
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    GetStartedView()
}
