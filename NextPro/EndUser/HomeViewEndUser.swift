//
//  HomeViewAdmin.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct HomeViewEndUser: View {
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
                            OpenDoorEndUserView()
                        case 1:
                            MembershipEndUserView()
                        case 2:
                            ProfileEndUserView()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)

                    // MARK: - Custom Bottom Tab Bar
                    HStack {
                        TabBarItemUser(title: "Open Doors", icon: "key.horizontal", isSelected: selectedTab == 0)
                            .onTapGesture { selectedTab = 0 }
                        
                        Spacer()

                        TabBarItemUser(title: "Membership", icon: "person.crop.circle.fill.badge.checkmark", isSelected: selectedTab == 1)
                            .onTapGesture { selectedTab = 1 }


                        Spacer()

                        TabBarItemUser(title: "Profile", icon: "person", isSelected: selectedTab == 2)
                            .onTapGesture { selectedTab = 2 }
                    }
                    .padding(.horizontal, 40)
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
struct TabBarItemUser: View {
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
    HomeViewAdmin()
}
