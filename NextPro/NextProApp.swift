//
//  NextProApp.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

@main
struct NextProApp: App {
    init() {
            UIRefreshControl.appearance().tintColor = .white
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
              //  .internetOverlay()   
        }
    }
}
