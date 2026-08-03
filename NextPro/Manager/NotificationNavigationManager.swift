//
//  NotificationNavigationManager.swift
//  NextPro
//

import Foundation
import Combine

/// Signals the UI to route to the Notifications screen after a push notification tap.
/// AppDelegate flips `shouldOpenNotifications` on tap; HomeView/DoorOpenView consume it
/// (switch to the Open Doors tab, push Notifications, then reset the flag).
@MainActor
final class NotificationNavigationManager: ObservableObject {

    static let shared = NotificationNavigationManager()

    private init() {}

    @Published var shouldOpenNotifications = false

    /// Bumped every time a remote notification arrives — the Notifications screen
    /// observes this (while on screen) to silently refresh its list.
    @Published var notificationsDidArrive = 0

    func triggerNotificationsScreen() {
        shouldOpenNotifications = true
    }

    func notifyNotificationsDidArrive() {
        notificationsDidArrive += 1
    }
}
