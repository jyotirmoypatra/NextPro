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
    
    @Environment(\.dismiss) var dismiss
    @State private var goToLogin = false

   
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

                            Text(fullName.isEmpty ? "User Name" : fullName)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)

                            Text(phoneNumber.isEmpty ? "Phone Number" : phoneNumber)
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
                            UserProfileRow(title: "Update Password") {
                                // Handle password update
                                navigateToUpdatePass = true
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
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            UserProfileRow(title: "Privacy Policy") {
                                // Handle support action
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            UserProfileRow(title: "Terms and Conditon") {
                                // Handle support action
                            }

                            
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            UserProfileRow(title: "Delete Account") {
                                // Handle support action
                            }

                            
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                            
                            UserProfileRow(title: "Logout") {
                                // Handle support action
                                KeychainManager.shared.clearUserDefaultsAndKeychainData()
                                
                                resetToLogin()
                                
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
        
        .navigationDestination(isPresented: $navigateToUpdatePass) {
            if usertype != "" && username != "" {
                CreateNewPasswordView(userType: usertype, userName: username)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
           
        }
        
        .navigationDestination(isPresented: $navigateToEditProfile) {
            EditProfileView()
        }
        
        .onChange(of: navigateToEditProfile) { newValue in
            // Refresh data when returning from Edit Profile
            if !newValue {
                loadUserData()
            }
        }
        
        .onAppear{
            loadUserData()
        }
    }
    
    func loadUserData() {
        usertype = UserDefaults.standard.string(forKey: "user_type") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""
        fullName = UserDefaults.standard.string(forKey: "user_full_name") ?? "James Arthur"
        phoneNumber = UserDefaults.standard.string(forKey: "user_phone") ?? "+8353753535"
        print("username:\(username)")
        print("usertype:\(usertype)")
        print("fullName:\(fullName)")
        print("phoneNumber:\(phoneNumber)")
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
            .padding(.vertical, 30) // 
            .contentShape(Rectangle()) // makes the entire row tappable
        }
    }
}
