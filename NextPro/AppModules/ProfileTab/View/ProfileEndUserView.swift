//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct ProfileEndUserView: View {
    @State private var notificationsEnabled = true
    @State private var navigateToUpdatePass = false
    @State private var navigateToEditProfile = false
    @State private var navigateToUserManagement = false
    @State private var username = ""
    @State private var usertype = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var showWebView = false
   
    //@State private var webViewURL = ""
    //@State private var webViewTitle = ""
    @State private var webViewType = ""
    
    @StateObject private var viewModel = UserProfileDetailsViewModel()

    
    @Environment(\.dismiss) var dismiss
    @State private var goToLogin = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var navigate_Webview_PrivacyTerms = false
    @State private var navigate_voice_message = false
    @State private var showFailedAlert = false
    
    
    @State private var showFullImage = false
    
    @State private var isAdmin = false
    
   
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
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: - Scroll Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // MARK: - Profile Info Section
                        VStack(spacing: 12) {


                            ProfileImageView(imageUrl: viewModel.image_url)
                                .onTapGesture {
                                    showFullImage = true
                                }

                            
                            // Full Name
                            if viewModel.isLoading {
                                ShimmerTextView(width: 120, height: 16)
                            } else {
                                Text(viewModel.fullName)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }

                            // Phone Number
                            if viewModel.isLoading {
                                ShimmerTextView(width: 90, height: 13)
                            } else {
                                Text(viewModel.phoneNumber.formattedUSPhone())
                                    .font(.custom("Inter-Regular", size: 13))
                                    .foregroundColor(.gray)
                            }

                            

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
                                if username != "" {
                                    navigateToUpdatePass = true
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            if viewModel.canReadUserManagement || viewModel.canWriteUserManagement {
                                
                                UserProfileRow(title: "User Management" , textColor: .white) {
                                    navigateToUserManagement = true
                                }
                                
                                Divider().background(Color.white.opacity(0.15))
                                    .padding(.horizontal,20)
                            }
                            
                            UserProfileRow(title: "Voice Message" , textColor: .white) {
                                // Handle support action
                                navigate_voice_message = true
                            }

                           

//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//
//                            // Notifications Toggle
//                            HStack {
//                                Text("Notifications")
//                                    .font(.custom("Inter-Medium", size: 16))
//                                    .foregroundColor(.white)
//                                Spacer()
//                                Toggle("", isOn: $notificationsEnabled)
//                                    .labelsHidden()
//                            }
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 30) // consistent with other rows
                            
                           
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Privacy Policy" , textColor: .white) {
                                
                                navigate_Webview_PrivacyTerms = true
                                webViewType = "privacy"
 
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Terms and Conditon" , textColor: .white) {
                                
                                navigate_Webview_PrivacyTerms = true
                                webViewType = "terms"

                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)

                            // Support
                            UserProfileRow(title: "Support",textColor: .white) {
                                // Handle support action
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Delete Account" , textColor: .red) {
                                showDeleteAccountAlert = true
                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Logout" , textColor: .orange) {
                                showLogoutAlert = true
                            }

                           
                        }
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                       
                    }
                    .padding(.bottom, 30)
                }
                .refreshable{
                    Task {
                        loadUserData()
                        await viewModel.fetchUserProfile()
                    }
                }
            }.padding(.horizontal,10)
            
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
        .internetOverlay() 
        .background(Color.black.opacity(0.4))
        
        .navigationDestination(isPresented: $navigateToUpdatePass) {
            CreateNewPasswordView(userName: username, comingFrom: "user_profile")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        
        .navigationDestination(isPresented: $navigate_Webview_PrivacyTerms) {
            PrivacyAndTermsView(WebViewType:webViewType)
        }
        
        .navigationDestination(isPresented: $navigateToEditProfile) {
            EditProfileView(
                fullName: viewModel.fullName,
                phoneNumber: viewModel.phoneNumber,
                email : viewModel.email,
                profileImgUrl: viewModel.image_url
                
            )
        }
        .navigationDestination(isPresented: $showFullImage) {
            FullScreenImageView(url: viewModel.image_url, isPresented: $showFullImage)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        
        .navigationDestination(isPresented: $navigate_voice_message) {
            VoiceAnnouncementsDoor()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        
        .navigationDestination(isPresented: $navigateToUserManagement) {
           UserManagementView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
//        .onReceive(NetworkManager.shared.$hasInternet) { internet in
//            if internet == true {
//                Task {
//                    await viewModel.fetchUserProfile()
//                }
//            }
//        }
        
        .onReceive(NetworkManager.shared.$hasInternet) { hasInternet in
            guard hasInternet else { return }

            // Retry ONLY if previous failure was due to no internet
            if viewModel.isFailedDueToNoInternet {
                Task {
                    await viewModel.fetchUserProfile()
                }
            }
        }

        .onChange(of: navigateToEditProfile) { newValue in
            // Refresh data when returning from Edit Profile
            if !newValue {
                loadUserData()
            }
        }
        .onAppear {
            Task {
                loadUserData()
                await viewModel.fetchUserProfile()
//                if !viewModel.isSuccess{
//                    showFailedAlert = true
//                }
                
                if !viewModel.isSuccess && !viewModel.isFailedDueToNoInternet {
                            showFailedAlert = true
                        }
            }
        }
        
        
        //Alert is visible only when: showFailedAlert == true ANd viewModel.isFailedDueToNoInternet == false

        .modernAlert(
                isPresented: Binding(
                    get: { showFailedAlert && !viewModel.isFailedDueToNoInternet },
                    set: { showFailedAlert = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: viewModel.errorMessage,
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showFailedAlert = false
                }
            }
        
        .sheet(isPresented: $showLogoutAlert) {
            LogoutSheetView()
        }
        .sheet(isPresented: $showDeleteAccountAlert) {
            DeleteConfirmationSheet()
        }

    }
    
    func loadUserData() {
       // usertype = UserDefaults.standard.string(forKey: "user_type") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""

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
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(textColor)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 30) // 
            .contentShape(Rectangle()) // makes the entire row tappable
        }
    }
}



struct LogoutSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoggingOut = false
    var body: some View {
        
        ZStack {
            VStack(spacing: 20) {
                
                // Drag indicator
                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.3))
                    .frame(width: 40, height: 5)
                
                Text("Logout")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Are you sure you want to logout from your account?")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Divider().background(Color.white.opacity(0.2))
                
                Button(action: {
                    KeychainManager.shared.clearUserDefaultsAndKeychainData()
                    UserDefaults.standard.set(false, forKey: "is_logged_in")
                   // KeychainManager.shared.resetToLogin()
                   // dismiss()
                }) {
                    Text("YES, LOGOUT")
                        .font(.custom("Inter-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
//                Button(action: {
//                    isLoggingOut = true
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                        KeychainManager.shared.clearUserDefaultsAndKeychainData()
//                        UserDefaults.standard.set(false, forKey: "is_logged_in")
//                    }
//
//                }) {
//                    ZStack {
//                        if isLoggingOut {
//                            ProgressView()
//                                .tint(colorScheme == .dark ? .black : .white)
//                        } else {
//                            Text("YES, LOGOUT")
//                                .font(.custom("Inter-Bold", size: 16))
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(colorScheme == .dark ? .white : .black)
//                    .foregroundColor(colorScheme == .dark ? .black : .white)
//                    .cornerRadius(10)
//                }
//                .disabled(isLoggingOut)
//                .padding(.horizontal)
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.custom("Inter-Bold", size: 15))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.8))
                        .padding(.top,10)
                }
                
                
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .cornerRadius(24)
            .padding(.horizontal, 10)
            
        }
        .presentationDetents([.height(270)])

    }

}



struct  DeleteConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        ZStack {
            VStack(spacing: 20) {
                
                // Drag indicator
                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.3))
                    .frame(width: 40, height: 5)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(colorScheme == .dark ? .red : .red)
                    .padding(.top, 5)

                
                Text("Delete Account")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Are you sure you want to delete  your account?.This action cannot be undone and all your data will be permanently removed.")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Divider().background(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                
                Button(action: {
                    dismiss()
                }) {
                    Text("YES, DELETE MY ACCOUNT")
                        .font(.custom("Inter-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button {
                    dismiss()
                   // resetToLogin()
                } label: {
                    Text("Cancel")
                        .font(.custom("Inter-Bold", size: 15))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.8))
                        .padding(.top,10)
                }
                
                
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .cornerRadius(24)
            .padding(.horizontal, 10)
            
        }
        .presentationDetents([.height(360)])
    }
    
   
}


//struct ProfileImageView: View {
//    let imageUrl: String?
//    let size: CGFloat = 100
//    
//    @State private var isLoading: Bool = true
//
//    var body: some View {
//        ZStack {
//
//            // Shimmer placeholder while loading
//            if isLoading {
//                Circle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: size, height: size)
//                    .overlay(
//                        ShimmerView()
//                            .frame(width: size, height: size)
//                            .clipShape(Circle())
//                    )
//            } else {
//                // Fallback placeholder if image fails
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .scaledToFill()
//                    .foregroundColor(.gray.opacity(0.6))
//                    .frame(width: size, height: size)
//            }
//
//            // Remote image loader
//            if let urlString = imageUrl,
//               let url = URL(string: urlString) {
//
//                WebImage(url: url)
//                    .onSuccess { _, _, _ in
//                        DispatchQueue.main.async {
//                            withAnimation { isLoading = false }
//                        }
//                    }
//                    .onFailure { _ in
//                        DispatchQueue.main.async {
//                            withAnimation { isLoading = false }
//                        }
//                    }
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: size, height: size)
//                    .clipShape(Circle())
//            }
//        }
//        .clipShape(Circle())
//        .overlay(
//            Circle().stroke(Color.white.opacity(0.7), lineWidth: 1)
//        )
//        .shadow(radius: 6)
//        // Reset shimmer when URL changes
//                .onChange(of: imageUrl) { _ in
//                    isLoading = true
//                }
//    }
//}
struct ProfileImageView: View {
    let imageUrl: String?
    let size: CGFloat = 100

    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {

            // ✅ Shimmer only when loading VALID image
            if isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        ShimmerView()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    )
            } else {
                // ✅ Placeholder (invalid URL or failure)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray.opacity(0.6))
                    .frame(width: size, height: size)
            }

            // ✅ Remote image loader (only if URL valid)
            if let urlString = imageUrl,
               let url = URL(string: urlString),
               !urlString.isEmpty {

                WebImage(url: url)
                    .onSuccess { _, _, _ in
                        DispatchQueue.main.async {
                                withAnimation {
                                    isLoading = false
                                }
                            }
                    }
                    .onFailure { _ in
                        withAnimation {
                            isLoading = false
                        }
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            }
        }
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(radius: 6)
        .onAppear {
            updateLoadingState()
        }
        .onChange(of: imageUrl) { _ in
            updateLoadingState()
        }
    }

    // MARK: - URL validation
    private func updateLoadingState() {
        if let urlString = imageUrl,
           let _ = URL(string: urlString),
           !urlString.isEmpty {
            isLoading = true
        } else {
            isLoading = false
        }
    }
}



struct SpinnerView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.gray, lineWidth: 3)
            .frame(width: 30, height: 30)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}


struct FullScreenImageView: View {
    let url: String
    @Binding var isPresented: Bool

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            WebImage(url: URL(string: url))
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        // Pinch Zoom
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastScale * value
                                scale = max(1.0, min(newScale, 4.0)) // limit zoom
                            }
                            .onEnded { _ in
                                lastScale = scale
                                adjustOffsetIfNeeded()
                            },

                        // Drag to move
                        DragGesture()
                            .onChanged { gesture in
                                if scale > 1.0 {
                                    offset = CGSize(
                                        width: lastOffset.width + gesture.translation.width,
                                        height: lastOffset.height + gesture.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                adjustOffsetIfNeeded()
                                lastOffset = offset
                            }
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeOut(duration: 0.25), value: offset)

            // Close Button
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }

    // Prevent image from going too far out of screen
    private func adjustOffsetIfNeeded() {
        let maxX = (scale - 1) * 200   // adjust as needed
        let maxY = (scale - 1) * 300

        var newX = offset.width
        var newY = offset.height

        newX = min(max(newX, -maxX), maxX)
        newY = min(max(newY, -maxY), maxY)

        offset = CGSize(width: newX, height: newY)
    }
}


struct ShimmerView: View {
    @State private var move: CGFloat = -0.7

    var body: some View {
        RoundedRectangle(cornerRadius: 48)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                // Moving shimmer overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: 48)
                        .fill(Color.white)
                        .rotationEffect(.degrees(20))
                        .scaleEffect(3)
                        .offset(x: move * 300)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    move = 0.7
                }
            }
    }
}

struct ShimmerTextView: View {
    var width: CGFloat
    var height: CGFloat

    @State private var phase: CGFloat = -250

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.3),
                        Color.white.opacity(0.8),
                        Color.gray.opacity(0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    phase = 250
                }
            }
            .shadow(color: .white.opacity(0.2), radius: 2) // subtle glow
    }
}

