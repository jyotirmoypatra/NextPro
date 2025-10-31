//
//  HomeView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Background Image
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Black translucent overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack {
                // MARK: - Top Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UTL")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("UTL")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    Button(action: {
                        // Notification tap action
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)

                Spacer()

                // MARK: - Dynamic Page Content
                Group {
                    switch selectedTab {
                    case 0:
                        HomeTabContent()
                    case 1:
                        OpenDoorsTabContent()
                    case 2:
                        ProfileTabContent()
                    default:
                        EmptyView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: selectedTab)

                Spacer()

                // MARK: - Custom Bottom Tab Bar
                HStack {
                    TabBarItem(title: "Home", icon: "house", isSelected: selectedTab == 0)
                        .onTapGesture { selectedTab = 0 }

                    Spacer()

                    TabBarItem(title: "Open Doors", icon: "key.horizontal", isSelected: selectedTab == 1)
                        .onTapGesture { selectedTab = 1 }

                    Spacer()

                    TabBarItem(title: "Profile", icon: "person", isSelected: selectedTab == 2)
                        .onTapGesture { selectedTab = 2 }
                }
                .padding(.horizontal, 35)
                .padding(.top, 10)
                .padding(.bottom, 25)
                .background(Color.black.opacity(0.9).ignoresSafeArea(edges: .bottom))
            }
        }
    }
}

// MARK: - Home Tab Content
struct HomeTabContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("WELCOME JAMES!")
                .font(.headline)
                .foregroundColor(.white)

            Text("Looks like you do not have a facility yet.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: {
                // Add Facility Action
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Facility")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 30)
        .padding(.horizontal)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Open Doors Tab Content
struct OpenDoorsTabContent: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Open Doors")
                .font(.headline)
                .foregroundColor(.white)
            Text("Here you can manage and open doors.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Profile Tab Content
struct ProfileTabContent: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Profile")
                .font(.headline)
                .foregroundColor(.white)
            Text("Your account details and settings go here.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    var title: String
    var icon: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .white : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}

#Preview {
    HomeView()
}
