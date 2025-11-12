//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//
import SwiftUI

struct ProfileEndUserView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        ZStack {
           

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("Profile")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: - Scroll Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // MARK: - Profile Info Section
                        VStack(spacing: 12) {
                            Image("person") // Replace with your actual asset name
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .shadow(radius: 6)

                            Text("James Arthur")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)

                            Text("+8353753535")
                                .font(.custom("Inter-Regular", size: 13))
                                .foregroundColor(.gray)

                            Button(action: {
                                // Edit profile action
                            }) {
                                Text("Edit Profile")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Settings Section
                        VStack(spacing: 0) {
                            // Update Password
                            UserProfileRow(title: "Update Password") {
                                // Handle password update
                            }

                            Divider().background(Color.white.opacity(0.15))

                            // Support
                            UserProfileRow(title: "Support") {
                                // Handle support action
                            }

                            Divider().background(Color.white.opacity(0.15))

                            // Notifications Toggle
                            HStack {
                                Text("Notifications")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30) // consistent with other rows
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            UserProfileRow(title: "Add Card") {
                                // Handle support action
                            }

                           
                        }
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.black.opacity(0.4))
    }
}

// MARK: - Uniform Profile Row
struct UserProfileRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30) // ⬅️ consistent padding top/bottom
            .contentShape(Rectangle()) // makes the entire row tappable
        }
    }
}
