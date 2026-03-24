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
    @State private var previousIsAdmin: Bool
    @StateObject private var profileRefreshViewModel = UserProfileDetailsViewModel()
    private let tabBarHeight: CGFloat = 55
    @State private var openDoorsRefreshID = UUID()
    @State private var devicesRefreshID = UUID()
    @State private var profileRefreshID = UUID()
    
    init(isAdmin: Bool, initialTab: Int = 0) {
           self.isAdmin = isAdmin
           _selectedTab = State(initialValue: initialTab)
           _previousIsAdmin = State(initialValue: isAdmin)
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
                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                if isAdmin {
                    
                    VStack(spacing: 0) {
                        
                        
                        // MARK: - Dynamic Page Content
                        
                        VStack {
                            switch selectedTab {
                            case 0:
                                DoorOpenView()
                                    .id(openDoorsRefreshID)
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true)
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity
                                    )
                                
                                
                            case 1:
                                DeviceAdminTabView()
                                    .id(devicesRefreshID)
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true)
                                    .frame(height: geo.size.height - tabBarHeight)
                            case 2:
                                
                                ProfileEndUserView()
                                    .id(profileRefreshID)
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
                                .onTapGesture { selectTab(0) }
                                
                                Spacer()
                                
                                TabBarItemUser(
                                    title: "Devices",
                                    activeIcon: "multi-window-active",
                                    inactiveIcon: "multi-window-inactive",
                                    isSelected: selectedTab == 1
                                )
                                .onTapGesture { selectTab(1) }
                                
                                Spacer()
                                
                                TabBarItemUser(
                                    title: "Profile",
                                    activeIcon: "profile-circle-active",
                                    inactiveIcon: "profile-circle-inactive",
                                    isSelected: selectedTab == 2
                                )
                                .onTapGesture { selectTab(2) }
                            }
                            .padding(.horizontal, 30)
                        }
                        .frame(height: tabBarHeight)
                        .background(Color.black.opacity(0.9))
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }else{

                    VStack(spacing: 0) {
                           
                            VStack {
                                switch selectedTab {
                                case 0:
                                    DoorOpenView()
                                        .id(openDoorsRefreshID)
                                        .navigationBarBackButtonHidden(true)
                                        .navigationBarHidden(true)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                                case 1:
                                    ProfileEndUserView()
                                        .id(profileRefreshID)
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
                                    .onTapGesture { selectTab(0) }
                                    
                                    Spacer()
                                    
                                    TabBarItemUser(
                                        title: "Profile",
                                        activeIcon: "profile-circle-active",
                                        inactiveIcon: "profile-circle-inactive",
                                        isSelected: selectedTab == 1
                                    )
                                    .onTapGesture { selectTab(1) }
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
        .onChange(of: isAdmin) { newValue in
            let oldValue = previousIsAdmin
            let oldProfileTab = oldValue ? 2 : 1
            let newProfileTab = newValue ? 2 : 1
            
            if selectedTab == oldProfileTab {
                selectedTab = newProfileTab
            } else if oldValue && !newValue && selectedTab == 1 {
                selectedTab = 0
            }
            
            previousIsAdmin = newValue
        }
    }
    
    private func selectTab(_ tab: Int) {
          silentlyRefreshProfile()
        
          if selectedTab == tab {
              refreshCurrentTab(tab)
              return
          }
          
          selectedTab = tab

      }
    
    private func refreshCurrentTab(_ tab: Int) {
          switch tab {
          case 0:
              openDoorsRefreshID = UUID()
          case 1:
              if isAdmin {
                  devicesRefreshID = UUID()
              } else {
                  profileRefreshID = UUID()
              }
          case 2:
              profileRefreshID = UUID()
          default:
              break
          }
      }
    
    private func silentlyRefreshProfile() {
            Task {
                await profileRefreshViewModel.fetchUserProfile()
            }
        }
}
