//
//  ContentView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI


struct ContentView: View {
    @State private var showSplash = true
    @State private var isLoggedIn = false
    @State private var isAdmin = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                
            } else {
                NavigationStack {
                   // LoginView()
                    
                    
                    if isLoggedIn {
                        if isAdmin {
                            HomeViewAdmin()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                        } else {
                            HomeViewEndUser()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                        }
                    } else {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    }
                    
                    
                }
                .transition(.move(edge: .trailing))
            }
        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                withAnimation(.easeInOut(duration: 0.6)) {
//                    showSplash = false
//                }
//            }
//        }
        .onAppear {
                    checkLoginStatus()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                }

    }
    private func checkLoginStatus() {
            let access = KeychainManager.shared.get("access_token")
            let userId = UserDefaults.standard.string(forKey: "user_id")
            let userType = UserDefaults.standard.string(forKey: "user_type")

            if access != nil, userId != nil {
                isLoggedIn = true
                isAdmin = (userType == "facility_manager")
            } else {
                isLoggedIn = false
            }
        }
}

#Preview {
    ContentView()
}



