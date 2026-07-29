//
//  Notifications.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/07/26.
//

import SwiftUI

struct Notifications: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationCountVM: NotificationCountViewModel
    @StateObject private var notificationVM = NotificationListViewModel()
    @StateObject private var readAllVM = NotificationReadAllViewModel()
    @StateObject private var singleReadVM = SingleNotificationReadViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @State private var pullToRefresh = false
    @State private var showErrorAlert = false

    private let notificationIcon = "bell.fill"
    private let notificationIconColor: Color = .white

    private var badgeText: String? {
        guard notificationCountVM.unreadCount > 0 else { return nil }
        return notificationCountVM.unreadCount > 99 ? "99+" : "\(notificationCountVM.unreadCount)"
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
                            .overlay(alignment: .topTrailing) {
                                if let badgeText {
                                    Text(badgeText)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                        .offset(x: 6, y: -6)
                                }
                            }
                    }
                    .overlay(
                        Text("Notifications")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    // MARK: - Read All button
                    if !notificationVM.sections.isEmpty {
                    HStack {
                        Spacer()

                        Button(action: {
                            Task {
                                let success = await readAllVM.markAllAsRead()
                                if success {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        notificationVM.markAllAsRead()
                                    }
                                    if let message = readAllVM.successMessage, !message.isEmpty {
                                        toastManager.show(message: message, type: .success)
                                    }
                                } else if let error = readAllVM.errorMessage, !error.isEmpty {
                                    showErrorAlert = true
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                if readAllVM.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                }

                                Text("Read all")
                                    .font(.custom("Inter-SemiBold", size: 13))
                            }
                            .foregroundColor(notificationVM.hasUnread ? .white : .gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(notificationVM.hasUnread ? 0.16 : 0.06),
                                        Color.white.opacity(notificationVM.hasUnread ? 0.08 : 0.03)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(notificationVM.hasUnread ? 0.25 : 0.1), lineWidth: 1)
                            )
                        }
                        .disabled(!notificationVM.hasUnread)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                    }

                    // MARK: - Notification List (grouped by date)
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                                Color.clear
                                    .frame(height: 1)
                                    .id("TOP")

                                ForEach(notificationVM.sections, id: \.date) { section in
                                    Section(header: DateSectionHeaderView(dateString: section.date)) {
                                        ForEach(section.notifications ?? []) { notification in
                                            NotificationRowView(
                                                notification: notification,
                                                icon: notificationIcon,
                                                iconColor: notificationIconColor
                                            )
                                            .onTapGesture {
                                                handleTap(on: notification)
                                            }
                                            .onAppear {
                                                loadMoreIfNeeded(after: notification)
                                            }
                                        }
                                    }
                                }

                                if notificationVM.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 20)
                        }
                        .refreshable {
                            pullToRefresh = true
                            await notificationVM.fetchNotificationList(reset: true)
                            pullToRefresh = false
                            if let error = notificationVM.errorMessage, !error.isEmpty {
                                showErrorAlert = true
                            }
                        }
                    }
                }

                if notificationVM.isLoading && !pullToRefresh {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }

                if notificationVM.hasLoadedOnce && !notificationVM.isLoading && notificationVM.sections.isEmpty {
                    ZStack {
                        VStack(spacing: 14) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("No Notifications Found")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.white)

                            Text("You don't have any notifications yet.")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toast()
        .onAppear {
            guard !notificationVM.hasLoadedOnce else { return }
            Task {
                await notificationVM.fetchNotificationList(reset: true)
                if let error = notificationVM.errorMessage, !error.isEmpty {
                    showErrorAlert = true
                }
            }
        }
        .onReceive(NetworkManager.shared.$hasInternet) { hasInternet in
            guard hasInternet else { return }
            if notificationVM.isFailedDueToNoInternet {
                Task {
                    await notificationVM.fetchNotificationList(reset: true)
                    if let error = notificationVM.errorMessage, !error.isEmpty {
                        showErrorAlert = true
                    }
                }
            }
        }
        .internetOverlay()
        .modernAlert(
            isPresented: Binding(
                get: { showErrorAlert && !notificationVM.isFailedDueToNoInternet },
                set: { showErrorAlert = $0 }
            )
        ) {
            ModernAlertView(
                title: "Error!",
                message: singleReadVM.errorMessage ?? readAllVM.errorMessage ?? notificationVM.errorMessage ?? "Something went wrong!",
                isSuccess: false,
                buttonTitle: "OK"
            ) {
                showErrorAlert = false
            }
        }
    }

    // MARK: - Actions

    private func handleTap(on notification: NotificationItem) {
        guard !(notification.isRead ?? false) else { return }
        guard let idString = notification.id else { return }

        Task {
            let success = await singleReadVM.markAsRead(notificationId: idString)

            if success {
                // Immediate UI feedback
                withAnimation(.easeInOut(duration: 0.25)) {
                    notificationVM.markAsRead(id: notification.id)
                }

                // Keep badge + list in sync with the server
                notificationCountVM.refreshUnreadCount()

                pullToRefresh = true
                await notificationVM.fetchNotificationList(reset: true)
                pullToRefresh = false
            } else if let error = singleReadVM.errorMessage, !error.isEmpty {
                showErrorAlert = true
            }
        }
    }

    private func loadMoreIfNeeded(after notification: NotificationItem) {
        let isLastItem = notification.id == notificationVM.lastNotificationId
        let hasMorePages = notificationVM.currentPage <= notificationVM.totalPages
        let notLoading = !notificationVM.isLoadingMore && !notificationVM.isLoading

        guard isLastItem && hasMorePages && notLoading else { return }

        Task {
            await notificationVM.fetchNotificationList()
        }
    }
}

/// Sticky section header showing a notification group's date (e.g. "23 Jul 2026").
private struct DateSectionHeaderView: View {
    let dateString: String?

    var body: some View {
        HStack {
            Text(DateSectionHeaderView.formattedDate(dateString))
                .font(.custom("Inter-SemiBold", size: 13))
                .foregroundColor(.white.opacity(0.6))
                .textCase(nil)

            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.9))
    }

    /// Converts an API date string (`yyyy-MM-dd`) into a friendly display format (`23 Jul 2026`).
    /// Falls back to the raw string if it can't be parsed.
    private static func formattedDate(_ dateString: String?) -> String {
        guard let dateString, !dateString.isEmpty else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        return outputFormatter.string(from: date)
    }
}

struct NotificationRowView: View {
    let notification: NotificationItem
    let icon: String
    let iconColor: Color

    private var isUnread: Bool {
        !(notification.isRead ?? false)
    }

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
                    Text(notification.title ?? notification.label ?? "Notification")
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(.white)

                    Spacer()

                    Text(notification.timeElapsed ?? notification.createdAt ?? "")
                        .font(.custom("Inter-Regular", size: 11))
                        .foregroundColor(.gray)
                }

                Text(notification.description ?? "")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            if isUnread {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            isUnread
                ? Color.white.opacity(0.14)
                : Color.white.opacity(0.05)
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isUnread ? Color.white.opacity(0.22) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}
