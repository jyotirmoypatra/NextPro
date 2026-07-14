//
//  SplashScreen.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

struct SplashScreen: View {
        private var appVersionText: String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

            guard !version.isEmpty else { return "" }

            if APIConfig.isProduction {
                return "Version \(version)"
            } else {
                return build.isEmpty
                    ? "Version \(version)"
                    : "Version \(version) (\(build))"
            }
        }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top){
                // Background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                
                
                
                VStack(spacing: 16) {
                    if !appVersionText.isEmpty {
                        Text(appVersionText)
                            .font(.custom("Inter-Regular", size: 13))
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
                // .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                
                
                ZStack {
                    Image("zylx")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 315, height: 120)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

