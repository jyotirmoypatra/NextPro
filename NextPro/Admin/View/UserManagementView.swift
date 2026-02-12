//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct UserManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var fetchUserVM = FetchUserListViewModel()
    @StateObject private var getUserDetailsVM = GetUserDetailsViewModel()
    @State private var showFetchUserVMError = false
    @State private var showUserDetailsVMError = false
    @State private var navigateToAddUser = false
    @State private var pullToRefresh = false
    @State private var selectedUserForEdit: GetUserData?
    @State private var scrollToTop = false
    
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
                        
                        // RIGHT: Info Icon
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .overlay(
                        Text("User Management")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                   
                    
                    Button(action: {
                        selectedUserForEdit = nil
                        navigateToAddUser = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .fontWeight(.bold)

                            Text("Add User")
                                .font(.custom("Inter-SemiBold", size: 18))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .contentShape(Rectangle())   // ⭐ makes full area tappable
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    
                  //  if !fetchUserVM.usersList.isEmpty {
//                        HStack{
//                            Text("Added Users")
//                                .font(.custom("Inter-SemiBold", size: 16))
//                                .foregroundColor(.white)
//                            
//                        }.frame(maxWidth:.infinity, alignment: .leading)
//                            .padding(.top, 20)
                        
                    
                        HStack(spacing: 10) {
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                            ZStack(alignment: .leading){
                                
                                // Placeholder
                                if fetchUserVM.searchText.isEmpty {
                                    Text("Search User by name")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(.custom("Inter-Regular", size: 16))
                                        
                                }
                                
                                TextField("", text: $fetchUserVM.searchText)
                                    .foregroundColor(.white)
                                    .tint(.white) // cursor color
                            }
                        }
                        .padding(15)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.top,20)
                   
                        
                    //}
                    
                   
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 15) {
                                Color.clear
                                        .frame(height: 1)
                                        .id("TOP")
                                if !fetchUserVM.usersList.isEmpty {
                                    ForEach(fetchUserVM.usersList) { item in
                                        UsersCardView(user: item,
                                                      onEdit: { user in
                                            Task {
                                                getUserDetailsVM.userid = user.id
                                                await getUserDetailsVM.getUserDetails()
                                                
                                                if let fullData = getUserDetailsVM.userData {
                                                    selectedUserForEdit = fullData
                                                    navigateToAddUser = true
                                                } else if let error = getUserDetailsVM.errorMessage {
                                                    showUserDetailsVMError = true
                                                }
                                            }
                                        },
                                                      onDelete: { user in
                                            print("Delete \(user.id)")
                                        }
                                        )
                                        .onAppear {
                                            let isLastItem = item.id == fetchUserVM.usersList.last?.id
                                            let hasMorePages = fetchUserVM.currentPage <= fetchUserVM.totalPages
                                            let notLoading = !fetchUserVM.isLoadingMore && !fetchUserVM.isLoading
                                            if isLastItem && hasMorePages && notLoading {
                                                Task {
                                                    await fetchUserVM.fetchUsersList()
                                                }
                                            }
                                        }
                                    }
                                    
                                    if fetchUserVM.isLoadingMore {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                            Spacer()
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 2)
                        }
                        .onChange(of: scrollToTop) { value in
                               if value {
                                   withAnimation {
                                       proxy.scrollTo("TOP", anchor: .top)
                                   }
                                   scrollToTop = false
                               }
                           }
                        .refreshable {
                            pullToRefresh = true
                            await fetchUserVM.fetchUsersList(reset: true)
                            pullToRefresh = false
                            if let error = fetchUserVM.errorMessage, !error.isEmpty {
                                showFetchUserVMError = true
                            }
                        }
                    }
                    
                    
                    
                }
                .padding(.horizontal,10)
                
                
                if fetchUserVM.isLoading && !pullToRefresh{
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
                
                if getUserDetailsVM.isLoading{
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
                
                
               // if !fetchUserVM.isLoading && fetchUserVM.usersList.isEmpty {
                    
                    if fetchUserVM.hasLoadedOnce && !fetchUserVM.isLoading && fetchUserVM.usersList.isEmpty {
                    ZStack {
                        VStack(spacing: 14) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            
                           // Text("No User Devices Found")
                            Text(fetchUserVM.searchText.isEmpty
                                 ? "No User Found"
                                 : "No search results found")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.white)
                            
                            Text("You haven’t added any user yet.\nTap “Add User” to create user.")
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
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
//        .navigationDestination(isPresented: $navigateToAddUser) {
//            AddUserView(editUser: selectedUserForEdit)
//        }
        
        .navigationDestination(isPresented: $navigateToAddUser) {
            AddUserView(
                editUser: selectedUserForEdit,
                onDismiss: {
                    Task {
                        await fetchUserVM.refreshAfterAddOrEditUser()
                        scrollToTop = true
                    }
                }
            )
        }
        .onAppear {
            // Only run initial load when view has never loaded (avoids double fetch when returning from AddUserView)
            guard !fetchUserVM.hasLoadedOnce else { return }
            Task {
                await fetchUserVM.fetchUsersList(reset: true)
                if let error = fetchUserVM.errorMessage, !error.isEmpty {
                    showFetchUserVMError = true
                }
            }
        }
       

        .onReceive(NetworkManager.shared.$hasInternet) { hasInternet in
            guard hasInternet else { return }

            // Retry ONLY if previous failure was due to no internet
            if fetchUserVM.isFailedDueToNoInternet {
                Task {
                    await fetchUserVM.fetchUsersList(reset: true)
                    if let error = fetchUserVM.errorMessage, !error.isEmpty {
                        showFetchUserVMError = true
                    }
                }
            }
        }
        .internetOverlay()

        .modernAlert(
                isPresented: Binding(
                    get: { showFetchUserVMError && !fetchUserVM.isFailedDueToNoInternet },
                    set: { showFetchUserVMError = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: fetchUserVM.errorMessage ?? "Something went wrong!",
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showFetchUserVMError = false
                }
            }
        
            .modernAlert(
                    isPresented: Binding(
                        get: { showUserDetailsVMError && !getUserDetailsVM.isFailedDueToNoInternet },
                        set: { showUserDetailsVMError = $0 }
                    )
                ) {
                    ModernAlertView(
                        title: "Error!",
                        message: getUserDetailsVM.errorMessage ?? "Something went wrong!",
                        isSuccess: false,
                        buttonTitle: "OK"
                    ) {
                        showUserDetailsVMError = false
                    }
                }
    }
    
}

struct UsersCardView: View {
    let user: User
    
    let onEdit: (User) -> Void
    let onDelete: (User) -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Profile Icon
            Image("user-square")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 34, height: 34)

            // Name + Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)

                Text(user.creationMethod == "access_group" ? "Access Group" : "Custom Door Access" )
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            
            // Action Buttons
            HStack(spacing: 20) {

                // ✏️ Edit
                Button {
                    print("Edit tapped")
                    onEdit(user)
                } label: {
                    Image("edit-pencil")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                }

                // 🗑 Delete
                Button {
                    print("Delete tapped")
                    onDelete(user)
                } label: {
                    Image("delete-icon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
