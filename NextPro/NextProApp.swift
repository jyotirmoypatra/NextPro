//
//  NextProApp.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

@main
struct NextProApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("is_logged_in") private var isLoggedIn = false

    init() {
        UIRefreshControl.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        if isLoggedIn {
                            print("☀️ App active — start server time")
                            ServerTimeService.shared.start(forceImmediate: true)
                        } else {
                            print("☀️ App active — user logged out, stop server time")
                            ServerTimeService.shared.stop()
                            NetworkManager.shared.resetSessionExpirationState()
                        }

                    case .background:
                        print("🌙 App background — stop server time")
                        ServerTimeService.shared.stop()

                    case .inactive:
                        break

                    @unknown default:
                        break
                    }
                }
        }
    }
}
