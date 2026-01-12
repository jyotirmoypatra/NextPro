//
//  InternetOverlayModifier.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/01/26.
//
import Foundation
import SwiftUI

struct InternetOverlayModifier: ViewModifier {
    @ObservedObject var network = NetworkManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if network.didCheckInternet && !network.hasInternet {
                NoInternetOverlayView(retryAction: {
                    network.checkInternet()
                })
                .transition(.opacity)
                .animation(.easeInOut, value: network.hasInternet)
                .zIndex(9999)
            }
        }
    }
}


struct NoInternetOverlayView: View {
    var retryAction: () -> Void

    var body: some View {
        ZStack {
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                //.frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
            
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Image(systemName: "wifi.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.white)

                Text("No Internet Connection")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)

                Text("Please check your internet and try again.")
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button(action: retryAction) {
                    HStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        Text("RETRY")
                            .font(.custom("Inter-Bold", size: 16))
                            
                       }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,12)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                    
                }
                .padding(.horizontal, 50)
            }
        }
    }
}


extension View {
    func internetOverlay() -> some View {
        self.modifier(InternetOverlayModifier())
    }
}

// add .internetOverlay to view for full screen no internet overaly


struct GlobalNetworkBanner: ViewModifier {
    @ObservedObject var network = NetworkManager.shared
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if network.didCheckInternet && !network.hasInternet {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("No Internet Connection")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: network.hasInternet)
            }
        }
    }
}

extension View {
    func networkBanner() -> some View {
        self.modifier(GlobalNetworkBanner())
    }
}

// add .networkBanner to view for banner no internet overaly
