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
    @State private var isPasswordReset = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                
            } else {
                NavigationStack {
                   // LoginView()
                    
                    
//                    if isLoggedIn {
//                        if isAdmin {
//                           // HomeViewAdmin()
//                            
//                            if isPasswordReset{
//                                HomeViewEndUser()
//                                      .navigationBarBackButtonHidden(true)
//                                      .navigationBarHidden(true)
//                            }else{
//                                CreateNewPasswordView(userType: UserDefaults.standard.string(forKey: "user_type") ?? "", userName:  UserDefaults.standard.string(forKey: "username") ?? "")
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                            }
//                            
//                         
//                        } else {
//                            if isPasswordReset {
//                                HomeViewEndUser()
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                            }else{
//                                CreateNewPasswordView(userType: UserDefaults.standard.string(forKey: "user_type") ?? "", userName:  UserDefaults.standard.string(forKey: "username") ?? "")
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                            }
//                            
//                        }
//                    } else {
//                        LoginView()
//                            .navigationBarBackButtonHidden(true)
//                            .navigationBarHidden(true)
//                    }
                    
                    
                    
                    HomeViewEndUser()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    
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
            isPasswordReset = UserDefaults.standard.bool(forKey: "isPssswordReset")

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



