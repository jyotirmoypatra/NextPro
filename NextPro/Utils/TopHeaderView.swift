//
//  TopHeaderView.swift
//  NextPro
//

import SwiftUI

enum TopHeaderType {
    case welcome(userName: String, isLoading: Bool)
    case title(String)
}

struct TopHeaderView: View {
    @EnvironmentObject private var notificationCountVM: NotificationCountViewModel

    let type: TopHeaderType
    var onBellTap: (() -> Void)? = nil

    private var badgeText: String? {
        guard notificationCountVM.unreadCount > 0 else { return nil }
        return notificationCountVM.unreadCount > 99 ? "99+" : "\(notificationCountVM.unreadCount)"
    }

    var body: some View {
        HStack {
            switch type {
            case .welcome(let userName, let isLoading):
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome!")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)

                    if isLoading {
                        ShimmerTextView(width: 100, height: 16)
                    } else {
                        Text(userName)
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.gray)
                    }
                }

            case .title(let title):
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {
                onBellTap?()
            }) {
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
        }
        .frame(maxWidth: .infinity)
    }
}
