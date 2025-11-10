//
//  ContentView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI


struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                   
            } else {
                NavigationStack {
                   // LoginView()
                    //OnboardPageWiFiListView(selectedDeviceSN: "asswd3434545")
                    //SDKTestView()
                   // OnboardPageFirstView()  // Start with the first onboarding page
                  // OnboardPageDeviceScanView()  // Uncomment to start directly at device scan
                    // OnboardPageWiFiListView(selectedDeviceSN: "jjhdjhjdhjdh83787837")
                
                  HomeView()
                   // OnboardPageWifiPasswordView(selectedDeviceSN: "99222", selectedWiFiNetwork: "2323")
                }
                .transition(.move(edge: .trailing))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}



