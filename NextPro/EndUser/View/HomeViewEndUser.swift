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
                   
                    VStack {
                        switch selectedTab {
                        case 0:
                           // OpenDoorEndUserView()
                          
                            DoorOpenView()
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

                    Divider()
                        .background(Color.white.opacity(0.15))

                    
                    //tab
                    HStack {
                        TabBarItemUser(
                            title: "Open Doors",
                            activeIcon: "key-active",
                            inactiveIcon: "key-inactive",
                            isSelected: selectedTab == 0
                        )
                        .onTapGesture { selectedTab = 0 }

                        Spacer()

                        TabBarItemUser(
                            title: "Membership",
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


struct TabBarItemUser: View {
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
