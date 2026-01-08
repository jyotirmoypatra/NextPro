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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .overlay(
                        Text("Configure Device")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    
                    // 🟦 PERFECTLY CENTERED CARD
                    VStack(spacing: 25) {
                        Text("SUCCESS")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.white)
                        
                        Text("Your device has been successfully configured!")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button {
                            navigateToHome = true
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.black)
                                
                                Image("arrow-right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .navigationDestination(isPresented: $navigateToHome) {
                            HomeViewAdmin(initialTab: 1)
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.12))
                    )
                    Spacer()
                }
                .padding(.horizontal,10)
            }
            

        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    SuccessConnctionView()
}

