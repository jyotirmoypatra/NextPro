//
//  AccountPicker.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/26.
//

import SwiftUI

struct AccountPicker: View {
    @State private var accounts: [StoredAccount]
    @StateObject private var switchViewModel = AccountSwitchViewModel()
    @StateObject private var revokeTokenViewModel = RevokeTokenViewModel()
    @State private var isDeleteMode = false
    @State private var accountPendingDeletion: StoredAccount?
    @State private var showDeleteConfirmation = false
    @State private var showRevokeErrorAlert = false
    @State private var showSwitchErrorAlert = false
    @State private var accountBeingOpened: StoredAccount?
    @State private var showMaximumAccountsAlert = false
    @State private var loginRequest: LoginRequest?

    private struct LoginRequest: Identifiable {
        let id = UUID()
        let email: String
    }

    init() {
        _accounts = State(initialValue: KeychainManager.shared.storedAccounts())
    }

    private func displayName(for account: StoredAccount) -> String {
        if let fullname = account.fullname, !fullname.isEmpty {
            return fullname
        }
        if !account.username.isEmpty {
            return account.username
        }
        return account.email
    }

    private func initials(for account: StoredAccount) -> String {
        let parts = displayName(for: account)
            .split(separator: " ")
            .map(String.init)
        if parts.count > 1 {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }
        return String(displayName(for: account).prefix(2)).uppercased()
    }
    

    @MainActor
    private func switchToAccount(_ account: StoredAccount) async {

        accountBeingOpened = account
        let overlayStart = Date()
        let minimumOverlayDuration: TimeInterval = 2.0

        // Keeps the switching overlay visible for at least 2 seconds
        func waitForMinimumOverlay() async {
            let remaining = minimumOverlayDuration - Date().timeIntervalSince(overlayStart)
            if remaining > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            }
        }

        // 1. Call account switch API
        await switchViewModel.accountSwitch(
            refreshToken: account.refreshToken
        )

        // 2. Check API response
        guard switchViewModel.successFlag,
              let response = switchViewModel.switchResponse,
              let userID = response.user_id,
              userID == account.userID else {

            if switchViewModel.requiresLogin {
                KeychainManager.shared.setLoginRequired(true, for: account.userID)
                accounts = KeychainManager.shared.storedAccounts()
            }
            await waitForMinimumOverlay()
            accountBeingOpened = nil
            showSwitchErrorAlert = true
            return
        }

        // 3. Save fresh tokens and ctx_blob
        let isUpdated = KeychainManager.shared.updateAccountAfterSwitch(
            userID: userID,
            response: response
        )

        guard isUpdated else {
            accountBeingOpened = nil
            return
        }

        // 4. Get updated saved account
        guard let updatedAccount = KeychainManager.shared.storedAccounts()
            .first(where: { $0.userID == userID }) else {

            accountBeingOpened = nil
            return
        }

        // 5. Update active account details and permissions
        KeychainManager.shared.updateActiveAccountDetails(
            updatedAccount,
            response: response
        )

        // 6. Activate account and restore MQTT credentials
        guard KeychainManager.shared.activate(updatedAccount) else {
            accountBeingOpened = nil
            return
        }

        // 7. Register FCM for the selected account
        FCMTokenManager.shared.registerForCurrentAccount()

        // 8. Refresh account list
        accounts = KeychainManager.shared.storedAccounts()

        // 9. Ensure overlay was visible for at least 2 seconds
        await waitForMinimumOverlay()

        // 10. Navigate to home
        KeychainManager.shared.resetToHome()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .zIndex(999)
                    
                    ScrollViewReader { _ in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                Spacer().frame(height: 15)
                                VStack(spacing: 0) {
                                    Image("zylx")
                                        .resizable()
                                        .frame(width: 280, height: 95)
                                        .padding(.bottom,30)
                                    
                                    
                                    Text("Welcome Back")
                                        .font(.custom("Inter-SemiBold", size: 22))
                                        .foregroundColor(.white)

                                    
                                    Text("Choose a saved account to continue")
                                        .font(.custom("Inter-Regular", size: 20))
                                        .foregroundColor(.white.opacity(0.55))
                                        .padding(.top, 12)
                                    
                                    VStack(spacing: 14) {
                                        ForEach(accounts) { account in
                                            ZStack(alignment: .topTrailing) {
                                                HStack(spacing: 14) {
                                                    ProfileImageView(imageUrl: account.imageURL, size: 40)

                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(displayName(for: account))
                                                            .font(.custom("Inter-SemiBold", size: 17))
                                                            .foregroundColor(.white)
                                                            .lineLimit(1)

                                                        Text(account.email)
                                                            .font(.custom("Inter-Regular", size: 14))
                                                            .foregroundColor(.white.opacity(0.62))
                                                            .lineLimit(1)

                                                        if account.loginRequired == true {
                                                            Text("Sign-in Required")
                                                                .font(.custom("Inter-Regular", size: 12))
                                                                .foregroundColor(Color.yellow.opacity(0.8))
                                                                .fixedSize(horizontal: false, vertical: true)
                                                        }
                                                    }

                                                    Spacer()

                                                    if isDeleteMode {
                                                        Button {
                                                            accountPendingDeletion = account
                                                            showDeleteConfirmation = true
                                                        } label: {
                                                            Image(systemName: "trash.fill")
                                                                .font(.system(size: 16, weight: .semibold))
                                                                .foregroundColor(.white)
                                                                .padding(10)
                                                                .background(Color.red)
                                                                .clipShape(Circle())
                                                        }
                                                    } else {
                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 20, weight: .medium))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 16)
                                                .background(Color.white.opacity(0.035))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                                .contentShape(Rectangle())
//                                                .onTapGesture {
//                                                    guard !isDeleteMode else { return }
//                                                    accountBeingOpened = account
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                                                        KeychainManager.shared.activate(account)
//                                                        FCMTokenManager.shared.registerForCurrentAccount()
//                                                        KeychainManager.shared.resetToHome()
//                                                    }
//                                                }
                                                .onTapGesture {
                                                    guard !isDeleteMode,
                                                          !switchViewModel.isLoading else {
                                                        return
                                                    }

                                                    if account.loginRequired == true {
                                                        loginRequest = LoginRequest(email: account.email)
                                                        return
                                                    }

                                                    Task {
                                                        await switchToAccount(account)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.horizontal, 24)
                                    
                                    Spacer(minLength: 150)
                                }
                            }
                        }
                        
                        Button {
                            if accounts.count >= 5 {
                                showMaximumAccountsAlert = true
                            } else {
                                loginRequest = LoginRequest(email: "")
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .regular))
                                
                                Text("Log in another account")
                                    .font(.custom("Inter-Medium", size: 15))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)

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
                                isDeleteMode
                                    ? .red
                                    : Color.gray
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                isDeleteMode
                                    ? Color.red.opacity(0.10)
                                    : Color.white.opacity(0.045)
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
                        .padding(.bottom, 10)
                        .padding(.horizontal, 24)
                    }
                .contentShape(Rectangle())
                .onTapGesture {
                    isDeleteMode = false
                }
                .modernAlert(isPresented: $showDeleteConfirmation) {
                    ModernAlertView(
                        title: "Remove Saved Account",
                        message: "Are you sure you want to remove this saved account from this device? You can still log in again anytime using your email and password.",
                        isSuccess: false,
                        buttonTitle: "Remove",
                        action: {
                            guard let account = accountPendingDeletion,
                                  !revokeTokenViewModel.isLoading else { return }

                            Task { @MainActor in
                                guard await revokeTokenViewModel.revoke(
                                    refreshToken: account.refreshToken
                                ) else {
                                    showDeleteConfirmation = false
                                    showRevokeErrorAlert = true
                                    return
                                }

                                withAnimation(.easeInOut(duration: 0.2)) {
                                    accounts.removeAll { $0.id == account.id }
                                    KeychainManager.shared.removeStoredAccount(account)
                                    self.accountPendingDeletion = nil
                                    isDeleteMode = false
                                }
                                showDeleteConfirmation = false
                                if accounts.isEmpty {
                                    KeychainManager.shared.resetToLogin()
                                }
                            }
                        },
                        secondaryButtonTitle: "Cancel",
                        secondaryAction: {
                            accountPendingDeletion = nil
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isDeleteMode = false
                            }
                            showDeleteConfirmation = false
                        }
                    )
                }
                .modernAlert(isPresented: $showRevokeErrorAlert) {
                    ModernAlertView(
                        title: "Unable to Remove Account",
                        message: revokeTokenViewModel.errorMessage ?? "Unable to remove this account.",
                        isSuccess: false,
                        buttonTitle: "OK"
                    ) {
                        showRevokeErrorAlert = false
                    }
                }
                .modernAlert(isPresented: $showSwitchErrorAlert) {
                    ModernAlertView(
                        title: "Account Switch Failed",
                        message: switchViewModel.errorMessage.isEmpty
                            ? "Unable to switch account."
                            : switchViewModel.errorMessage,
                        isSuccess: false,
                        buttonTitle: "OK"
                    ) {
                        showSwitchErrorAlert = false
                    }
                }
                .modernAlert(isPresented: $showMaximumAccountsAlert) {
                    ModernAlertView(
                        title: "Maximum Accounts Reached",
                        message: "You've reached the maximum limit of 5 saved accounts on this device. Please remove an existing saved account before logging in with another account.",
                        isSuccess: false,
                        buttonTitle: "OK"
                    ) {
                        showMaximumAccountsAlert = false
                    }
                }
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .overlay {
                if revokeTokenViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                }
            }
            .fullScreenCover(item: $accountBeingOpened) { account in
                AccountSwitchingOverlay(
                    accountName: displayName(for: account),
                    titlePrefix: "Logging to"
                )
                    .interactiveDismissDisabled(true)
            }
            .fullScreenCover(item: $loginRequest) { request in
                NavigationStack {
                    LoginView(
                        isUserInitialSetupCompleted: true,
                        prefilledEmail: request.email,
                        showsCloseButton: true,
                        isAccountAddition: true,
                        onAccountAdded: {
                            loginRequest = nil
                            FCMTokenManager.shared.registerForCurrentAccount()
                            KeychainManager.shared.resetToHome()
                        },
                        onClose: {
                            loginRequest = nil
                        }
                    )
                    .id(request.id)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                }
            }
        }
    }
}
