//
//  HomeView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 25/02/26.
//


import SwiftUI

struct HomeView: View {
    let isAdmin: Bool
    @State private var selectedTab = 0
    private let tabBarHeight: CGFloat = 55
    
    init(isAdmin: Bool, initialTab: Int = 0) {
           self.isAdmin = isAdmin
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

                if isAdmin {
                    
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
                                    title: "Open Doors",
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
                }else{
//                    VStack(spacing: 0) {
//                       
//                        VStack {
//                            switch selectedTab {
//                            case 0:
//                                DoorOpenView()
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                                    .frame(
//                                                    maxWidth: .infinity,
//                                                    maxHeight: .infinity
//                                                )
//                            case 1:
//                                MembershipEndUserView()
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                                    .frame(height: geo.size.height - tabBarHeight)
//
//                            case 2:
//                                ProfileEndUserView()
//                                    .navigationBarBackButtonHidden(true)
//                                    .navigationBarHidden(true)
//                                    .frame(height: geo.size.height - tabBarHeight)
//
//                            default:
//                                EmptyView()
//                            }
//                        }
//                        //.frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .transition(.opacity)
//                        .animation(.easeInOut(duration: 0.25), value: selectedTab)
//
//                        
//                        //tabv
//                        VStack(spacing: 10){
//                            Divider()
//                                .background(Color.white.opacity(0.15))
//                            HStack {
//                                TabBarItemUser(
//                                    title: "Open Doors",
//                                    activeIcon: "key-active",
//                                    inactiveIcon: "key-inactive",
//                                    isSelected: selectedTab == 0
//                                )
//                                .onTapGesture { selectedTab = 0 }
//                                
//                                Spacer()
//                                
//                                TabBarItemUser(
//                                    title: "Membership",
//                                    activeIcon: "user-star-active",
//                                    inactiveIcon: "user-star-inactive",
//                                    isSelected: selectedTab == 1
//                                )
//                                .onTapGesture { selectedTab = 1 }
//                                
//                                Spacer()
//                                
//                                TabBarItemUser(
//                                    title: "Profile",
//                                    activeIcon: "profile-circle-active",
//                                    inactiveIcon: "profile-circle-inactive",
//                                    isSelected: selectedTab == 2
//                                )
//                                .onTapGesture { selectedTab = 2 }
//                            }
//                            .padding(.horizontal, 30)
//                        }
//                        .frame(height: tabBarHeight)
//                        .background(Color.black.opacity(0.9))
//                        .ignoresSafeArea(edges: .bottom)
//                       
//                    }
                   // .frame(width: geo.size.width, height: geo.size.height)
                    
                    
                    
                    
                    VStack(spacing: 0) {
                           
                            VStack {
                                switch selectedTab {
                                case 0:
                                    DoorOpenView()
                                        .navigationBarBackButtonHidden(true)
                                        .navigationBarHidden(true)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                                case 1:
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

                            // MARK: - Bottom Tab (2 tabs now)
                            VStack(spacing: 10){
                                Divider()
                                    .background(Color.white.opacity(0.15))
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
                                        title: "Profile",
                                        activeIcon: "profile-circle-active",
                                        inactiveIcon: "profile-circle-inactive",
                                        isSelected: selectedTab == 1
                                    )
                                    .onTapGesture { selectedTab = 1 }
                                }
                                .padding(.horizontal, 60)
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
}


