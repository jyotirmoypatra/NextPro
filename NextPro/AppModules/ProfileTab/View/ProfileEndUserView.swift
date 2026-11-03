//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct ProfileEndUserView: View {
    @EnvironmentObject private var notificationCountVM: NotificationCountViewModel
    @State private var notificationsEnabled = true
    @State private var navigateToUpdatePass = false
    @State private var navigate_access_time = false
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
    @State private var navigateToSupport = false
    @State private var navigateToTheme = false
    @State private var navigate_Webview_PrivacyTerms = false
    @State private var navigate_voice_message = false
    @State private var navigate_Debug = false
    @State private var showFailedAlert = false
    @State private var showManageAccount = false
    @State private var showAddAccountLogin = false
    @State private var isSwitchingAccount = false
    @State private var switchingAccountName = ""
    @State private var isRemovingCurrentAccount = false
    @State private var accountRemovalStatus = "Removing account"
    @State private var accountPendingDeletion: StoredAccount?
    @State private var showSavedAccountDeleteAlert = false
    
    
    @State private var showFullImage = false
    
    @State private var isAdmin = false
    @State private var navigateToNotifications = false
   
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Header
                TopHeaderView(type: .title("Profile"), onBellTap: {
                    navigateToNotifications = true
                })
                .padding(.top, 12)
                .padding(.bottom, 12)

                // MARK: - Scroll Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // MARK: - Profile Info Section
                        VStack(spacing: 12) {

                            
                            ProfileImageView(imageUrl: viewModel.image_url)
                                .onTapGesture {
                                    if isValidImageURL(viewModel.image_url) {
                                        showFullImage = true
                                    }
                                }

                            
                            // Full Name
                            if viewModel.isLoading {
                                ShimmerTextView(width: 120, height: 20)
                            } else {
                                Text(viewModel.fullName)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            // MARK: - Role Capsule
                                HStack(spacing: 6) {

                                    Image(systemName: UserRole.icon)
                                        .font(.system(size: 11, weight: .semibold))

                                    Text(UserRole.title)
                                        .font(
                                            .custom(
                                                "Inter-SemiBold",
                                                size: 11
                                            )
                                        )
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(
                                    Color.blue.opacity(0.12)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            Color.blue.opacity(0.25),
                                            lineWidth: 0.8
                                        ) )
                                .clipShape(Capsule())

                            // Phone Number
                            if viewModel.isLoading {
                                ShimmerTextView(width: 90, height: 15)
                            } else if !viewModel.phoneNumber.isEmpty {

                                HStack(spacing: 6) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)

                                    Text(viewModel.phoneNumber.formattedUSPhone())
                                        .font(.custom("Inter-Regular", size: 13))
                                        .foregroundColor(.gray)
                                }
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

                            UserProfileRow(title: "Manage Account", textColor: .white) {
                                showManageAccount = true
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
                            
                            
//                            UserProfileRow(title: "Access Time" , textColor: .white) {
//                                // Handle support action
//                                navigate_access_time = true
//                            }
//                            
//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Voice Message" , textColor: .white) {
                                // Handle support action
                                navigate_voice_message = true
                            }

//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//
//                            UserProfileRow(title: "Theme" , textColor: .white) {
//                                navigateToTheme = true
//                            }



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
                                navigateToSupport = true
                            }
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            if UserRole.title != "Organization Admin" {
                                UserProfileRow(title: "Delete Account" , textColor: .red) {
                                    showDeleteAccountAlert = true
                                }

                                Divider().background(Color.white.opacity(0.15))
                                    .padding(.horizontal,20)
                            }

                            UserProfileRow(title: "Logout" , textColor: .red) {
                                showLogoutAlert = true
                            }
                            
//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//                            
//                            UserProfileRow(title: "Debug MQTT" , textColor: .white) {
//                                // Handle support action
//                                navigate_Debug = true
//                            }
                            
                            
                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            HStack {
                                Text("App Version")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(APIConfig.appVersionText)
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 25)

                           
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
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }

            if showSavedAccountDeleteAlert {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .zIndex(5)
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
                countryCode: viewModel.countryCode,
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
        
        .navigationDestination(isPresented: $navigate_access_time) {
            AccessTimeView(userData : viewModel.userProfileData)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        
        .navigationDestination(isPresented: $navigate_voice_message) {
            VoiceAnnouncementsDoor(profileViewModel: viewModel)
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
        
        .navigationDestination(isPresented: $navigate_Debug) {
           DebugMqtt()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        .navigationDestination(isPresented: $navigateToNotifications) {
            Notifications()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
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
                notificationCountVM.refreshUnreadCount()
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
        
        .navigationDestination(isPresented: $navigateToSupport) {
            SupportView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $navigateToTheme) {
            ThemeSettingsView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        }
        .sheet(isPresented: $showLogoutAlert) {
            LogoutSheetView()
        }
        .sheet(isPresented: $showDeleteAccountAlert) {
            DeleteConfirmationSheet()
        }
        .sheet(isPresented: $showManageAccount) {
            ManageAccountSheet(
                fullName: viewModel.fullName,
                email: viewModel.email,
                imageURL: viewModel.image_url,
                showDeleteConfirmation: $showSavedAccountDeleteAlert,
                accountPendingDeletion: $accountPendingDeletion,
                storedAccounts: KeychainManager.shared.storedAccounts(),
                onAddAccount: {
                    KeychainManager.shared.saveCurrentAccount(
                        fullName: viewModel.fullName,
                        imageURL: viewModel.image_url
                    )
                    showManageAccount = false
                    showAddAccountLogin = true
                },
                onSwitchAccount: { account in
                    showManageAccount = false
                    switchingAccountName = account.fullname?.isEmpty == false
                        ? account.fullname!
                        : (account.username.isEmpty ? account.email : account.username)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isSwitchingAccount = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        KeychainManager.shared.activate(account)
                        FCMTokenManager.shared.registerForCurrentAccount()
                        isSwitchingAccount = false
                        loadUserData()
                        Task {
                            await viewModel.fetchUserProfile()
                        }
                    }
                },
                onDeleteAccount: { account in
                    accountPendingDeletion = account
                    showSavedAccountDeleteAlert = true
                },
                onCurrentAccountDelete: {
                    showManageAccount = false
                    accountRemovalStatus = "Removing account"
                    isRemovingCurrentAccount = true

                    Task {
                        try? await Task.sleep(nanoseconds: 800_000_000)
                        accountRemovalStatus = "Logging out"
                        await FCMTokenManager.shared.performLogout()
                        try? await Task.sleep(nanoseconds: 800_000_000)
                        isRemovingCurrentAccount = false
                        KeychainManager.shared.resetToLogin()
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showAddAccountLogin) {
            NavigationStack {
                LoginView(
                    isUserInitialSetupCompleted: false,
                    showsCloseButton: true,
                    isAccountAddition: true,
                    onAccountAdded: {
                        showAddAccountLogin = false
                        FCMTokenManager.shared.registerForCurrentAccount()
                        loadUserData()
                        Task {
                            await viewModel.fetchUserProfile()
                        }
                    },
                    onClose: {
                        showAddAccountLogin = false
                    }
                )
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
        }
        .fullScreenCover(isPresented: $isSwitchingAccount) {
            AccountSwitchingOverlay(accountName: switchingAccountName)
                .interactiveDismissDisabled(true)
        }
        .fullScreenCover(isPresented: $isRemovingCurrentAccount) {
            AccountSwitchingOverlay(accountName: accountRemovalStatus, titlePrefix: "")
                .interactiveDismissDisabled(true)
        }

    }
    
    
    private func isValidImageURL(_ urlString: String?) -> Bool {
        guard let urlString = urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url)
        else {
            return false
        }
        return true
    }
    
    func loadUserData() {
       // usertype = UserDefaults.standard.string(forKey: "user_type") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""

    }

}

struct AccountSwitchingOverlay: View {
    let accountName: String
    var titlePrefix = "Switching to"
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.05

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.86)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Circle()
                    .trim(from: 0.08, to: 0.72)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 75, height: 75)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))

                Text(titlePrefix.isEmpty ? accountName : "\(titlePrefix) \(accountName)")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)

                Text("Please wait...")
                    .font(.custom("Inter-Regular", size: 15))
                    .foregroundColor(.white.opacity(0.65))

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))

                        Capsule()
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(width: 230, height: 5)
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 1.1)) {
                progress = 0.82
            }
        }
    }
}

struct ManageAccountSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDeleteMode = false
    @State private var deletedAccountIDs = Set<String>()

    let fullName: String
    let email: String
    let imageURL: String
    @Binding var showDeleteConfirmation: Bool
    @Binding var accountPendingDeletion: StoredAccount?
    let storedAccounts: [StoredAccount]
    let onAddAccount: () -> Void
    let onSwitchAccount: (StoredAccount) -> Void
    let onDeleteAccount: (StoredAccount) -> Void
    let onCurrentAccountDelete: () -> Void

    private func displayName(for account: StoredAccount?) -> String {
        guard let account else { return "this saved account" }
        if let fullname = account.fullname, !fullname.isEmpty { return fullname }
        if !account.username.isEmpty { return account.username }
        return account.email
    }

    private var totalAccountCount: Int {
        var accountIDs = Set(storedAccounts.map {
            $0.userID.isEmpty ? $0.email.lowercased() : $0.userID
        })
        accountIDs.insert(UserDefaults.standard.string(forKey: "user_id") ?? email.lowercased())
        return accountIDs.count
    }

    private var currentAccount: StoredAccount? {
        storedAccounts.first {
            $0.email.caseInsensitiveCompare(email) == .orderedSame
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            //            Capsule()
            //                .fill(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.3))
            //                .frame(width: 40, height: 5)
            //                .frame(maxWidth: .infinity)
            VStack(alignment: .leading,spacing: 5){
                Text("Manage Accounts")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top,20)
                
                Text("Switch between accounts signed in on this device.")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.8))
            }
           
        VStack(alignment: .leading,spacing: 8){
            
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("Saved accounts")
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(
                        colorScheme == .dark ? .white : .black
                    )
                
                Spacer()
                
                Text("\(min(totalAccountCount, 5))/5")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(
                        colorScheme == .dark ? .white : .black
                    )
            }
            .padding(.top, 4)
            
            ProgressView(
                value: Double(min(totalAccountCount, 5)),
                total: 5
            )
            .tint(totalAccountCount >= 5 ? .orange : .white)
            
            Text(
                totalAccountCount >= 5
                ? "You've reached the 5-account limit. Remove a saved account to add another."
                : "You can add up to 5 accounts on this device."
            )
            .font(.custom("Inter-Regular", size: 13))
            .foregroundColor(
                colorScheme == .dark ? .white : .black
            )
            .fixedSize(horizontal: false, vertical: true)
        }
          
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    Button {
                        if isDeleteMode, let currentAccount {
                            onDeleteAccount(currentAccount)
                        }
                    } label: {
                    HStack(spacing: 14) {
                        ProfileImageView(imageUrl: imageURL, size: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack{
                                Text(fullName.isEmpty ? email : fullName)
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if isDeleteMode {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                } else {
                                    Text("CURRENT")
                                        .font(.custom("Inter-SemiBold", size: 11))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color.green.opacity(0.75))
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Text(email)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                           
                            
                            if let organizationName = UserDefaults.standard.string(
                                forKey: "organizationName"
                            ), !organizationName.isEmpty {
                                Text(organizationName)
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(colorScheme == .dark ? .gray.opacity(0.7) : .black.opacity(0.7))
                            }
                        }
                        
                        
                        
                        
                    }
                    }
                    .padding(14)
                    .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    
                    ForEach(storedAccounts.filter {
                        $0.email.caseInsensitiveCompare(email) != .orderedSame && !deletedAccountIDs.contains($0.id)
                    }) { account in
                        Button {
                            if isDeleteMode {
                                onDeleteAccount(account)
                            } else {
                                onSwitchAccount(account)
                            }
                        } label: {
                            HStack(spacing: 12) {
                        ProfileImageView(imageUrl: account.imageURL, size: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(account.fullname?.isEmpty == false
                                         ? account.fullname!
                                         : (account.username.isEmpty ? account.email : account.username))
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .lineLimit(1)
                                    
                                    Text(account.email)
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                if isDeleteMode {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                } else {
                                    Text("SWITCH")
                                        .font(.custom("Inter-SemiBold", size: 11))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                            .padding(14)
                            .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    
                    if totalAccountCount < 5 {
//                        Button(action: onAddAccount) {
//                            Text("+ Add another account")
//                                .font(.custom("Inter-SemiBold", size: 16))
//                                .foregroundColor(colorScheme == .dark ? .white : .black)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 15)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 16)
//                                        .stroke(
//                                            colorScheme == .dark ? Color.white.opacity(0.35) : Color.black.opacity(0.35),
//                                            style: StrokeStyle(lineWidth: 1, dash: [5])
//                                        )
//                                )
//                        }
                        
                        Button(action: onAddAccount) {
                            HStack(spacing: 14) {

                                // Plus icon container
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.10))
                                        .frame(width: 46, height: 46)

                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.system(size: 23, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                                }

                                // Title and subtitle
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Add Another Account")
                                        .font(.custom("Inter-SemiBold", size: 15))
                                        .foregroundColor(
                                            colorScheme == .dark ? .white : .black
                                        )

                                    Text("Sign in with a different account")
                                        .font(.custom("Inter-Regular", size: 12))
                                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                                        .lineLimit(1)
                                }

                                Spacer(minLength: 4)

                                // Trailing arrow
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.045)
                                            : Color.black.opacity(0.1)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.14)
                                            : Color.black.opacity(0.12),
                                        lineWidth: 1
                                    )
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDeleteMode.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isDeleteMode ? "xmark.circle" : "trash")
                                .font(.system(size: 14, weight: .medium))

                            Text(isDeleteMode ? "Cancel Remove" : "Remove Account")
                                .font(.custom("Inter-Medium", size: 14))
                        }
                        .foregroundColor(
                            isDeleteMode ? .red :
                                
                                colorScheme == .dark
                                    ? Color.gray
                                    : Color.black
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            isDeleteMode
                                ? Color.red.opacity(0.2)
                                :
                            
                            colorScheme == .dark
                                ? Color.white.opacity(0.045)
                                : Color.black.opacity(0.07)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isDeleteMode
                                        ? Color.red.opacity(0.35)
                                        : Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isDeleteMode = false
        }
//        .overlay {
//            if showDeleteConfirmation {
//                Color.black.opacity(0.45)
//                    .ignoresSafeArea()
//                    .allowsHitTesting(false)
//            }
//        }
        .alert("Remove Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                accountPendingDeletion = nil
            }
            Button("Remove", role: .destructive) {
                if let accountPendingDeletion {
                    let deletingCurrentAccount = accountPendingDeletion.email.caseInsensitiveCompare(email) == .orderedSame
                    KeychainManager.shared.removeStoredAccount(accountPendingDeletion)
                    deletedAccountIDs.insert(accountPendingDeletion.id)
                    if deletingCurrentAccount {
                        onCurrentAccountDelete()
                    }
                }
                self.accountPendingDeletion = nil
                withAnimation(.easeInOut(duration: 0.2)) {
                    isDeleteMode = false
                }
            }
        } message: {
            Text("Are you sure you want to remove \(displayName(for: accountPendingDeletion)) from this device? You can still log in again anytime using your email and password.")
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
       // .presentationDetents([.height(CGFloat(350 + storedAccounts.count * 100)), .large])
        .presentationDetents([
            .height(CGFloat(350 + max(storedAccounts.count, 1) * 100)),
            .large
        ])
        .presentationDragIndicator(.visible)
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
            .padding(.vertical, 25) //
            .contentShape(Rectangle()) // makes the entire row tappable
        }
    }
}



struct LogoutSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var toastManager = ToastManager.shared
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
                    guard !isLoggingOut else { return }
                    isLoggingOut = true
                    Task {
                        let result = await FCMTokenManager.shared.logoutStrict()
                        isLoggingOut = false

                        switch result {
                        case .success:
                            dismiss()
                            KeychainManager.shared.resetToLogin()
                        case .failed(let message):
                            toastManager.show(message: message, type: .error)
                        }
                    }
                }) {
                    ZStack {
                        if isLoggingOut {
                            ProgressView()
                                .tint(colorScheme == .dark ? .black : .white)
                        } else {
                            Text("YES, LOGOUT")
                                .font(.custom("Inter-Bold", size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? .white : .black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
                }
                .disabled(isLoggingOut)
                .padding(.horizontal)
            
                
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
        .toast()

    }

}

struct DeleteConfirmationSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var deleteAccountViewModel = DeleteAccountViewModel()

    var body: some View {

        ZStack {
            VStack(spacing: 20) {

                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.3))
                    .frame(width: 40, height: 5)

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.red)
                    .padding(.top, 5)

                Text("Delete Account")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)

                Divider()
                    .background(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))

                Button {

                    Task {
                        await deleteAccountViewModel.deleteAccount()

                        if deleteAccountViewModel.isDeleteSuccess {

                            let storedAccounts = KeychainManager.shared.storedAccounts()
                            let userID = UserDefaults.standard.string(forKey: "user_id") ?? ""
                            let email = UserDefaults.standard.string(forKey: "email") ?? ""
                            let account = storedAccounts.first(where: {
                                !userID.isEmpty && $0.userID == userID
                            }) ?? storedAccounts.first(where: {
                                !email.isEmpty && $0.email.caseInsensitiveCompare(email) == .orderedSame
                            })

                            if let account {
                                KeychainManager.shared.removeStoredAccount(account)
                            }

                            // Clear login data
                            await FCMTokenManager.shared.performLogout()

                            dismiss()
                        }
                    }

                } label: {

                    ZStack {

                        if deleteAccountViewModel.isLoading {
                            ProgressView()
                                .tint(colorScheme == .dark ? .black : .white)
                        } else {
                            Text("YES, DELETE MY ACCOUNT")
                                .font(.custom("Inter-Bold", size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? .white : .black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
                }
                .disabled(deleteAccountViewModel.isLoading)
                .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.custom("Inter-Bold", size: 15))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.8))
                        .padding(.top,10)
                }

                
                // Error Message
                if !deleteAccountViewModel.errorMessage.isEmpty {
                    Text(deleteAccountViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }

            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .cornerRadius(24)
            .padding(.horizontal, 10)

        }
        .presentationDetents([.height(390)])
    }
}



struct ProfileImageView: View {
    let imageUrl: String?
    let size: CGFloat

    @State private var isLoading: Bool = false

    init(imageUrl: String?, size: CGFloat = 100) {
        self.imageUrl = imageUrl
        self.size = size
    }

    var body: some View {
        ZStack {

            // Shimmer only when loading VALID image
            if validImageURL != nil && isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        ShimmerView()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    )
            } else {
                // Placeholder (invalid URL or failure)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .frame(width: size, height: size)
            }

            // Remote image loader (only if URL valid)
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
        isLoading = validImageURL != nil
    }

    private var validImageURL: URL? {
        guard let imageUrl else { return nil }

        let trimmedURL = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty,
              trimmedURL.lowercased() != "null",
              let url = URL(string: trimmedURL),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil else {
            return nil
        }

        return url
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
