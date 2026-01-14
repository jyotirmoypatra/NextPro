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
                  
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
                // .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                
                
                ZStack {
                    Image("zylx")
                     .resizable()
                     .frame(width: 315, height: 120)
                     .padding(.bottom,40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

