//
//  PrivacyAndTermsView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 01/12/25.
//

import Foundation
import SwiftUI

struct  PrivacyAndTermsView: View {
    let WebViewType : String
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var  HTMLString: String = ""
    @State private var showWebContent = false
    @State private var webContentHeight: CGFloat = 0

    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                
               //  Full-screen semi-transparent background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack{
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
                        
                        Text(WebViewType == "privacy" ? "Privacy Policy" : "Terms & Conditions")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Invisible button for symmetry
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18))
                                .foregroundColor(.clear)
                                .padding(10)
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(1)
                    
                    
                    
                    
                    ScrollView {
                        WebContentView(
                            htmlString: HTMLString,
                            onContentHeightChange: { height in
                                let bufferedHeight = height + 50   // 🔥 IMPORTANT
                                let clamped = max(300, bufferedHeight)
                                
                                if abs(clamped - webContentHeight) > 1 {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        webContentHeight = clamped
                                    }
                                }
                            }
                        )
                        .background(.clear)
                        .frame(height: webContentHeight)
                        .clipped()
                    }
                    .scrollIndicators(.hidden)
                    
                    
                    
                    
                }
                
                
            }
            .navigationBarBackButtonHidden()
            
        }
        .onAppear{
            if  WebViewType == "privacy" {
                HTMLString = ""
                HTMLString = loadHTML("privacy")
            }else{
                HTMLString = ""
                HTMLString = loadHTML("terms")
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showWebContent = true
                }
            }
        }
    }
    
}
