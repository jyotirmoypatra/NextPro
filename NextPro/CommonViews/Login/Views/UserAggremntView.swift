//
//  UserAggremntView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.


import SwiftUI



struct UserAggremntView: View {

    @State private var acceptTerms = false
    @State private var acceptPrivacy = false
    @State private var webViewUrl = ""
    @State private var webViewTitle = ""
    @State private var showWebView = false
    @State private var showAggremntError = false
    @State private var showLoginError = false
    @State private var isAdmin = false
    @State private var navigateToHome = false
    @StateObject private var viewModel = AggremntAcceptViewModel()
    @StateObject private var loginVM = LoginViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Background Image + Dark Overlay
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.78)
                    .ignoresSafeArea()

                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            // TITLE
                            Text("User Agreement")
                                .font(.custom("Inter-Bold", size: 28))
                                .foregroundColor(.white)
                                .padding(.top, 20)

                            // DESCRIPTION (FULL PAGE COVER STYLE)
                            VStack(spacing: 12) {

                                Text("To continue using the app, please read and accept our Terms & Conditions and Privacy Policy. These policies help ensure that your experience stays secure, transparent, and personalized.")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)

                                Text("By accepting, you agree that:")
                                    .font(.custom("Inter-SemiBold", size: 17))
                                    .foregroundColor(.white)

                                VStack(alignment: .leading, spacing: 12) {
                                    bullet("Your personal data is encrypted and kept safe from unauthorized access.")
                                    bullet("We only collect information required to improve your experience.")
                                    bullet("You understand how your information is stored, processed, and used.")
                                    bullet("You give permission for app functionality such as notifications and device-level access.")
                                    bullet("You are aware of your rights regarding data sharing, export, and deletion.")
                                    bullet("You acknowledge that misuse or violation may result in account restrictions.")
                                    bullet("You allow us to contact you regarding security updates or important notices.")
                                }

                                .padding(.horizontal, 32)
                            }

                            Spacer(minLength: 40)
                        }
                    }

                    // CHECKBOXES SECTION (JUST ABOVE ACCEPT BUTTON)
                    VStack(alignment: .leading, spacing: 24) {

                        HStack(alignment: .center) {
                            Button { acceptTerms.toggle() } label: {
                                Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(acceptTerms ? .blue : .white)
                                    .font(.system(size: 26))
                            }

                            Button {
                                webViewUrl = "https://www.utahtechlabs.com/terms-of-service"
                                webViewTitle = "Terms & Conditions"
                                showWebView = true
                            } label: {
                                Text("I agree to the ")
                                    .foregroundColor(.white)
                                +
                                Text("Terms & Conditions")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                        }

                        HStack(alignment: .center) {
                            Button { acceptPrivacy.toggle() } label: {
                                Image(systemName: acceptPrivacy ? "checkmark.square.fill" : "square")
                                    .foregroundColor(acceptPrivacy ? .blue : .white)
                                    .font(.system(size: 26))
                            }

                            Button {
                                webViewUrl = "https://www.utahtechlabs.com/privacy-policy"
                                webViewTitle = "Privacy Policy"
                                showWebView = true
                            } label: {
                                Text("I agree to the ")
                                    .foregroundColor(.white)
                                +
                                Text("Privacy Policy")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // ACCEPT BUTTON
                    Button(action: {
                        AcceptApiCall()
                    }) {
                        Text("ACCEPT & CONTINUE")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((acceptTerms && acceptPrivacy) ? Color.white : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!(acceptTerms && acceptPrivacy))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
                
                // WEBVIEW POPUP
                if showWebView {
                    WebViewModal(
                        url: webViewUrl,
                        title: webViewTitle,
                        isPresented: $showWebView
                    )
                        .transition(.opacity)
                        .zIndex(10)
                }

                if viewModel.isLoading{
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
           
            .modernAlert(isPresented: $showAggremntError) {
                  ModernAlertView(
                      title: "Error!",
                      message: viewModel.ErrorMessage.isEmpty ? "Invalid credentials." : viewModel.ErrorMessage,
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showAggremntError = false }
            }
            .modernAlert(isPresented: $showLoginError) {
                  ModernAlertView(
                      title: "Error!",
                      message: loginVM.loginError.isEmpty ? "Invalid credentials." : loginVM.loginError,
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showLoginError = false }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                if isAdmin {
                   HomeViewAdmin()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                }
                else {
                    HomeViewEndUser()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                }
            }
        }
        .internetOverlay()
    }

    // MARK: - Accept Api
    func AcceptApiCall() {
        Task {
            viewModel.isAggrementAccepted = (acceptTerms && acceptPrivacy)
            await viewModel.accept()
            if viewModel.Successflag {
                LoginApiCall()
            }else{
                showAggremntError = true
            }
        }
    }
    // MARK: - Login Api Call 
    func LoginApiCall() {
        Task {
        
            loginVM.email = UserDefaults.standard.string(forKey: "email") ?? ""
            loginVM.password = KeychainManager.shared.get("user_password") ?? ""
            
            await loginVM.login()
            if loginVM.loginSuccess {
                isAdmin = (loginVM.userType == "facility_manager")
                navigateToHome = true
            }else{
                showLoginError = true
            }
        }
    }
    
    // MARK: - Bullet Helper
    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(.white)
                .font(.custom("Inter-Regular", size: 18))
            Text(text)
                .foregroundColor(.white.opacity(0.85))
                .font(.custom("Inter-Regular", size: 15))
        }
    }
}
