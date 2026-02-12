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
    @State private var isUserInitialSetupDone = false
    
    @StateObject private var networkManager = NetworkManager.shared
    
    init(skipSplash: Bool = false) {
            _showSplash = State(initialValue: !skipSplash)
        
        let initialSetup = UserDefaults.standard.bool(forKey: "isUserInitialSetupCompleted")
              _isUserInitialSetupDone = State(initialValue: initialSetup)
        
        print("isUserInitialSetupDone init =", initialSetup)
    }
    
    var body: some View {
        NavigationStack {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                
            } else {
               
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
                        LoginView(isUserInitialSetupCompleted: isUserInitialSetupDone)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    }
               
                }
                
            }
        }.transition(.move(edge: .trailing))

        .onAppear {
                    checkLoginStatus()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
        }
        
        .modernAlert(isPresented: $networkManager.showSessionExpiredAlert) {
            ModernAlertView(
                title: "Session Expired!",
                message:  "Your session has expired. Please login again.",
                isSuccess: false,
                buttonTitle: "OK"
            ) {
                KeychainManager.shared.clearUserDefaultsAndKeychainData()
                KeychainManager.shared.resetToLogin()
            }
        }

    }
    private func checkLoginStatus() {
            let access = KeychainManager.shared.get("access_token")
            let userId = UserDefaults.standard.string(forKey: "user_id")
            let is_admin = UserDefaults.standard.bool(forKey: "is_admin")
            isUserInitialSetupDone = UserDefaults.standard.bool(forKey: "isUserInitialSetupCompleted")

            print("isUserInitialSetupDone onapear =", isUserInitialSetupDone)

        
            if access != nil, userId != nil {
                isLoggedIn = true
                isAdmin = is_admin
            } else {
                isLoggedIn = false
            }
       
        
        }
}

#Preview {
    ContentView()
}



