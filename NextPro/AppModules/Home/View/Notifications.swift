//
//  Notifications.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    var isUnread: Bool
}

struct Notifications: View {
    @Environment(\.dismiss) private var dismiss

    private let notificationIcon = "bell.fill"
    private let notificationIconColor: Color = .white

    @State private var notifications: [AppNotification] = [
        AppNotification(
            title: "Door Unlocked",
            message: "Main Entrance was unlocked using Digital Card.",
            time: "2 min ago",
            isUnread: true
        ),
        AppNotification(
            title: "Access Denied",
            message: "An unauthorized attempt was made at Back Door.",
            time: "15 min ago",
            isUnread: true
        ),
        AppNotification(
            title: "Remote Unlock",
            message: "Warehouse Gate was opened remotely via Wi-Fi.",
            time: "1 hr ago",
            isUnread: true
        ),
        AppNotification(
            title: "New Device Assigned",
            message: "A new device has been assigned to your account.",
            time: "3 hr ago",
            isUnread: false
        ),
        AppNotification(
            title: "Time Sync Required",
            message: "Please connect to the internet to sync server time.",
            time: "Yesterday",
            isUnread: false
        ),
        AppNotification(
            title: "System Update",
            message: "NextPro has been updated to the latest version.",
            time: "2 days ago",
            isUnread: false
        )
    ]

    private var hasUnread: Bool {
        notifications.contains(where: { $0.isUnread })
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                VStack(spacing: 10){

                    HStack {
                        // LEFT: Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }

                        Spacer()

                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .overlay(
                        Text("Notifications")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    // MARK: - Read All button
                    HStack {
                        Spacer()

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                for index in notifications.indices {
                                    notifications[index].isUnread = false
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13, weight: .semibold))

                                Text("Read all")
                                    .font(.custom("Inter-SemiBold", size: 13))
                            }
                            .foregroundColor(hasUnread ? .white : .gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(hasUnread ? 0.16 : 0.06),
                                        Color.white.opacity(hasUnread ? 0.08 : 0.03)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(hasUnread ? 0.25 : 0.1), lineWidth: 1)
                            )
                        }
                        .disabled(!hasUnread)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)

                    // MARK: - Notification List
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(notifications) { notification in
                                NotificationRowView(
                                    notification: notification,
                                    icon: notificationIcon,
                                    iconColor: notificationIconColor
                                )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                                notifications[index].isUnread = false
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct NotificationRowView: View {
    let notification: AppNotification
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(.white)

                    Spacer()

                    Text(notification.time)
                        .font(.custom("Inter-Regular", size: 11))
                        .foregroundColor(.gray)
                }

                Text(notification.message)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            if notification.isUnread {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            notification.isUnread
                ? Color.white.opacity(0.14)
                : Color.white.opacity(0.05)
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    notification.isUnread ? Color.white.opacity(0.22) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}


