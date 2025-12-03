//
//  HomeViewAdmin.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct HomeViewAdmin: View {
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Image
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()

                // Black translucent overlay
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Top Bar
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

                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                            
                                .background(Color.black.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5) // ✅ fixed padding instead of safeAreaInsets.top



                    // MARK: - Dynamic Page Content
                    VStack {
                        switch selectedTab {
                        case 0:
                            AdminFacilityListView()
                        case 1:
                            DeviceAdminTabView()
                        case 2:
                            AdminProfileTabView()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)

                    // MARK: - Custom Bottom Tab Bar
                    Divider()
                        .background(Color.white.opacity(0.15))
                    HStack {
                        TabBarItemUser(
                            title: "Home",
                            activeIcon: "home-active",
                            inactiveIcon: "home-inactive",
                            isSelected: selectedTab == 0
                        )
                        .onTapGesture { selectedTab = 0 }

                        Spacer()

                        TabBarItemUser(
                            title: "Devices",
                            activeIcon: "user-star-active",
                            inactiveIcon: "user-star-inactive",
                            isSelected: selectedTab == 1
                        )
                        .onTapGesture { selectedTab = 1 }

                        Spacer()

                        TabBarItemUser(
                            title: "Profile",
                            activeIcon: "profile-circle-active",
                            inactiveIcon: "profile-circle-inactive",
                            isSelected: selectedTab == 2
                        )
                        .onTapGesture { selectedTab = 2 }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(Color.black.opacity(0.9))
                    .ignoresSafeArea(edges: .bottom)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
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

struct TabBarItemAdmin: View {
    var title: String
    var activeIcon: String
    var inactiveIcon: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(isSelected ? activeIcon : inactiveIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}


#Preview {
    HomeViewAdmin()
}
