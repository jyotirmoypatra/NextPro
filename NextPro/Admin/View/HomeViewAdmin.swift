//
//  HomeViewAdmin.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct HomeViewAdmin: View {
    @State private var selectedTab = 0
    private let tabBarHeight: CGFloat = 55
    
    init(initialTab: Int = 0) {
           _selectedTab = State(initialValue: initialTab)
       }
    

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
                

                    // MARK: - Dynamic Page Content
                    VStack {
                        switch selectedTab {
                        case 0:
                            DoorOpenView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .frame(
                                                maxWidth: .infinity,
                                                maxHeight: .infinity
                                            )


                        case 1:
                            DeviceAdminTabView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .frame(height: geo.size.height - tabBarHeight)
                        case 2:
                         //   AdminProfileTabView()
                            ProfileEndUserView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .frame(height: geo.size.height - tabBarHeight)
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)

                    VStack(spacing: 10){
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
                                activeIcon: "multi-window-active",
                                inactiveIcon: "multi-window-inactive",
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
                    }
                    .frame(height: tabBarHeight)
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
