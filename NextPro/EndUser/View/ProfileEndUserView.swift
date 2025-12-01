//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//
import SwiftUI

struct ProfileEndUserView: View {
    @State private var notificationsEnabled = true
    @State private var navigateToUpdatePass = false
    @State private var navigateToEditProfile = false
    @State private var username = ""
    @State private var usertype = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var showWebView = false
    @State private var webViewURL = ""
    @State private var webViewTitle = ""
    
    @StateObject private var viewModel = UserProfileDetailsViewModel()

    
    @Environment(\.dismiss) var dismiss
    @State private var goToLogin = false
    @State private var showLogoutAlert = false

   
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
                            Image(systemName: "person.circle.fill")// Replace with your actual asset name
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .foregroundColor(.gray.opacity(0.6))
                                .clipShape(Circle())
                                .shadow(radius: 6)
                                
                            
                            

                            // Full Name
                            Text(viewModel.isLoading ? "Loading..." : viewModel.fullName)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)

                            // Phone Number
                            Text(viewModel.isLoading ? "Loading..." : viewModel.phoneNumber)
                                .font(.custom("Inter-Regular", size: 13))
                                .foregroundColor(.gray)


                            Button(action: {
                                navigateToEditProfile = true
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
                            UserProfileRow(title: "Update Password",textColor: .white) {
                                // Handle password update
                                if usertype != "" && username != "" {
                                    navigateToUpdatePass = true
                                }
                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)

                            // Support
                            UserProfileRow(title: "Support",textColor: .white) {
                                // Handle support action
                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)

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
                            
//                            Divider().background(Color.white.opacity(0.15))
//                            
//                            UserProfileRow(title: "Add Card") {
//                                // Handle support action
//                            }
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Privacy Policy" , textColor: .white) {
                                openWebView(
                                    url: "https://www.lipsum.com/feed/html",
                                    title: "Privacy Policy"
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Terms and Conditon" , textColor: .white) {
                                openWebView(
                                    url: "https://www.lipsum.com/feed/html",
                                    title: "Terms and Conditions"
                                )
                            }

                            
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Delete Account" , textColor: .red) {
                                // Handle support action
                            }

                            
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Logout" , textColor: .red) {
                                showLogoutAlert = true
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
            
            // WebView Modal Overlay
            if showWebView {
                WebViewModal(
                    url: webViewURL,
                    title: webViewTitle,
                    isPresented: $showWebView
                )
                .transition(.opacity)
                .zIndex(100)
            }
            
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
        .background(Color.black.opacity(0.4))
        
        .navigationDestination(isPresented: $navigateToUpdatePass) {
         
            CreateNewPasswordView(userType: usertype, userName: username, comingFrom: "user_profile")
                    
           
        }
        
        .navigationDestination(isPresented: $navigateToEditProfile) {
            EditProfileView(
                fullName: viewModel.fullName,
                phoneNumber: viewModel.phoneNumber,
                email : viewModel.email
                
            )
        }
        
        .onChange(of: navigateToEditProfile) { newValue in
            // Refresh data when returning from Edit Profile
            if !newValue {
                loadUserData()
            }
        }
        
//        .onAppear{
//            loadUserData()
//        }
        .onAppear {
            Task {
                loadUserData()
                await viewModel.fetchUserProfile()
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("No", role: .cancel) {
                // Do nothing, just dismiss the alert
            }
            Button("Yes", role: .destructive) {
                // Proceed with logout
                KeychainManager.shared.clearUserDefaultsAndKeychainData()
                resetToLogin()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }

    }
    
    func loadUserData() {
        usertype = UserDefaults.standard.string(forKey: "user_type") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""

        
        
    }
    
    // MARK: - Open WebView Function
    func openWebView(url: String, title: String) {
        webViewURL = url
        webViewTitle = title
        withAnimation {
            showWebView = true
        }
    }
    
    func navigateToLogin() {
        goToLogin = true
    }
    
    // MARK: - Force Reset to Login
    func resetToLogin() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - Uniform Profile Row
struct UserProfileRow: View {
    let title: String
    let textColor : Color
    let action: () -> Void
    

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(textColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30) // 
            .contentShape(Rectangle()) // makes the entire row tappable
        }
    }
}
