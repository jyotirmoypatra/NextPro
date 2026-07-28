//
//  ContentView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI


struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("is_admin") private var isAdmin = false
    @AppStorage("device_management_read") private var deviceManagementRead = false
    @AppStorage("device_management_write") private var deviceManagementWrite = false
    
    @AppStorage("is_logged_in") private var isLoggedIn = false
    @AppStorage("isUserInitialSetupCompleted") private var isUserInitialSetupDone = false
    @AppStorage("home_initial_tab") private var homeInitialTab = 0
    
    @StateObject private var networkManager = NetworkManager.shared
    @StateObject private var notificationCountVM = NotificationCountViewModel()

    init(skipSplash: Bool = false) {
            _showSplash = State(initialValue: !skipSplash)

    }
    
    var body: some View {
        NavigationStack {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                
            } else {
               
              
                    if isLoggedIn {

                        HomeView(
                            isAdmin: deviceManagementRead || deviceManagementWrite,
                            initialTab: homeInitialTab
                        )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    } else {
                        LoginView(isUserInitialSetupCompleted: isUserInitialSetupDone)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    }
               
                }
                
            }
        }
        .environmentObject(notificationCountVM)
        .transition(.move(edge: .trailing))

        .onAppear {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
            
            if isLoggedIn {
                ServerTimeService.shared.start(forceImmediate: true)
                notificationCountVM.refreshUnreadCount()
                FCMTokenManager.shared.registerIfNeeded()
            } else {
                ServerTimeService.shared.stop()
                networkManager.resetSessionExpirationState()
            }
        }


        .SessionExpiredAlert(isPresented: $networkManager.showSessionExpiredAlert) {
            SessionExpiredAlertView(
                title: "Session Expired!",
                message:  "Your session has expired. Please login again.",
                isSuccess: false,
                buttonTitle: "OK"
            ) {
                Task {
                    await FCMTokenManager.shared.performLogout()
                    KeychainManager.shared.resetToLogin()
                    networkManager.completeSessionExpiredLogout()
                }
            }
        }
        .onChange(of: isLoggedIn) { loggedIn in
            if loggedIn {
                networkManager.resetSessionExpirationState()
                ServerTimeService.shared.start(forceImmediate: true)
                notificationCountVM.refreshUnreadCount()
                FCMTokenManager.shared.registerIfNeeded()
            } else {
                ServerTimeService.shared.stop()
                networkManager.resetSessionExpirationState()
            }
        }

    }

}

#Preview {
    ContentView()
}
