//
//  NextProApp.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

//@main
//struct NextProApp: App {
//    init() {
//            UIRefreshControl.appearance().tintColor = .white
//        }
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//              //  .internetOverlay()   
//        }
//    }
//}


@main
struct NextProApp: App {

    @Environment(\.scenePhase) private var scenePhase

    init() {
        UIRefreshControl.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        print("☀️ App active — start server time")
                        ServerTimeService.shared.start()

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
