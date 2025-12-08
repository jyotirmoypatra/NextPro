//
//  PrivacyAndTermsView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 01/12/25.
//

import Foundation
import SwiftUI

struct  PrivacyAndTermsView: View {
    let webViewURL : String
    let webViewTitle : String
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                
                // Full-screen semi-transparent background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                           // .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Spacer()
                    
                    Text(webViewTitle)
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                   
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .top)
                .zIndex(1)
                
               
                    
                ZStack {
                    WebView(url: webViewURL, isLoading: $isLoading)
                        .background(Color.black)   // FIX gray line issue

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.5)
                    }
                }
                .offset(y: 70)
                .ignoresSafeArea(edges: .bottom)

                
            
            }
            .navigationBarBackButtonHidden()
            
        }
    }
}
