//
//  UserAggremntView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.


import SwiftUI



struct UserAggremntView: View {
    var password : String?
    @State private var acceptTerms = false
    @State private var acceptPrivacy = false
    @State private var webViewUrl = ""
    @State private var webViewTitle = ""
    @State private var showWebView = false
    @State private var showAggremntError = false
    @State private var showLoginError = false
    @State private var isAdmin = false
    @State private var navigateToHome = false
    @State private var navigateToLogin = false
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var viewModel = AggremntAcceptViewModel()
    @StateObject private var loginVM = LoginViewModel()
    @State private var navigate_Webview_PrivacyTerms = false

    var body: some View {
      //  GeometryReader { geometry in
            ZStack {
                
                Image("backgroundimg")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()   // Full screen always

                        Color.black.opacity(0.78)
                            .ignoresSafeArea()
                VStack {
                  
                        VStack(spacing: 10) {

                            // TITLE
                            Text("User Agreement")
                                .font(.custom("Inter-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            Text("Please read and accept our terms and Privacy Policy to continue.")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            // DESCRIPTION (FULL PAGE COVER STYLE)
                            VStack(spacing: 12) {
                                
                              ScrollView(showsIndicators: false) {
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("TERMS OF SERVICE AND USER AGREEMENT")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))

                                    Text("Last Updated: December 2024")
                                        .foregroundColor(.gray)
                                        .font(.custom("Inter-Regular", size: 14))
                                    
                                    Text("1. ACCEPTANCE OF TERMS")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))
                                    
                                    Text("By downloading, installing, or using the NextPro application (App), you agree to be bound by these Terms of Service (Terms).If you do not agree to these Terms, please do not use the App.")
                                        .foregroundColor(.gray)
                                        .font(.custom("Inter-Regular", size: 14))
                                    
                                    Text("2. USE OF THE APP")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))
                                    
                                    Text("The App provides access control and door management services.You agree to use the App only for lawful purposes and in accordance with these Terms.You are responsible for maintaining the confidentiality of your account credentials.")
                                        .foregroundColor(.gray)
                                        .font(.custom("Inter-Regular", size: 14))
                                    
                                    Text("3. USER RESPONSIBILITIES")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))
                                    
                                    bullet("You agree not to misuse, reverse-engineer, or interfere with the App or any connected devices.")
                                    bullet("You will ensure that all information you provide is accurate and up to date.")
                                    bullet("You must immediately notify us of any unauthorized access or security breach.")
                                    bullet("You shall not use the App in any way that may damage, disable, or impair its functionality.")

                                    Text("4. DATA PRIVACY & SECURITY")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))
                                    bullet("Your data is encrypted and stored securely.")
                                    bullet("We only collect information required for service functionality and improvement.")
                                    bullet("We do not share your personal data with third parties without your consent, except where required by law.")
                                    bullet("You may request data export or deletion at any time by contacting our support team.")
                                    
                                    Text("5. CONTACT & SUPPORT")
                                        .foregroundColor(.gray)
                                                        .font(.custom("Inter-Medium", size: 15))
                                    bullet(" For questions, data requests, or support, please contact: support@nextproapp.com.")
                                    
                                   

                                   
                                }
                                .padding()
                              }.padding(.vertical,10)
                            }
                            .background(Color(hex: "#171717"))
                            .cornerRadius(12)
                            .padding(.horizontal,20)
                            .padding(.vertical,10)

                        }
             

                    // CHECKBOXES SECTION (JUST ABOVE ACCEPT BUTTON)
                    HStack{
                        VStack(alignment: .leading, spacing: 24) {
                            
                            HStack(alignment: .center) {
                                Button { acceptTerms.toggle() } label: {
                                    Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(acceptTerms ? .white : .gray)
                                        .font(.system(size: 26))
                                }
                                
                                Button {
//                                    webViewUrl = "https://www.utahtechlabs.com/terms-of-service"
//                                    webViewTitle = "Terms & Conditions"
//                                    showWebView = true
                                    
                                    
//                                    if let url = URL(string: "https://www.utahtechlabs.com/terms-of-service") {
//                                        UIApplication.shared.open(url)
//                                    }

                                    
                                    webViewUrl = "https://www.utahtechlabs.com/terms-of-service"
                                    webViewTitle = "Terms & Conditions"
                                    navigate_Webview_PrivacyTerms = true
                                    
                                } label: {
                                    Text("I agree to the ")
                                        .foregroundColor(.gray)
                                    +
                                    Text("Terms & Conditions")
                                        .underline()
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            HStack(alignment: .center) {
                                Button { acceptPrivacy.toggle() } label: {
                                    Image(systemName: acceptPrivacy ? "checkmark.square.fill" : "square")
                                        .foregroundColor(acceptPrivacy ? .white : .gray)
                                        .font(.system(size: 26))
                                }
                                
                                Button {
//                                    webViewUrl = "https://www.utahtechlabs.com/privacy-policy"
//                                    webViewTitle = "Privacy Policy"
//                                    showWebView = true

                                    webViewUrl = "https://www.utahtechlabs.com/privacy-policy"
                                    webViewTitle = "Privacy Policy"
                                    navigate_Webview_PrivacyTerms = true
//                                    if let url = URL(string: "https://www.utahtechlabs.com/privacy-policy") {
//                                            UIApplication.shared.open(url)
//                                        }
                                } label: {
                                    Text("I agree to the ")
                                        .foregroundColor(.gray)
                                    +
                                    Text("Privacy Policy")
                                        .underline()
                                        .foregroundColor(.blue)
                                }
                            }
                            
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 5)
                        Spacer()
                    }
                    .padding(.horizontal,20)
                   

                    // ACCEPT BUTTON
                    Button(action: {
                        AcceptApiCall()
                    }) {
                        Text("ACCEPT & CONTINUE")
                            .font(.custom("Inter-SemiBold", size: 16))
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
                .padding(.horizontal,15)
                
                
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

                if viewModel.isLoading || loginVM.isLoading{
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
            .navigationDestination(isPresented: $navigate_Webview_PrivacyTerms) {
                PrivacyAndTermsView(webViewURL: webViewUrl, webViewTitle: webViewTitle)
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
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(isUserInitialSetupCompleted: true,prefilledEmail: UserDefaults.standard.string(forKey: "email") ?? "")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
        //}
        .toast()
        .internetOverlay()
        
    }

    // MARK: - Accept Api
    func AcceptApiCall() {
        Task {
            viewModel.isAggrementAccepted = (acceptTerms && acceptPrivacy)
            await viewModel.accept()

            if viewModel.Successflag {

                if let pwd = password,
                   !pwd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                    LoginApiCall()   // password exists → call login

                } else {
                    toastManager.show(
                        message: "Your account is ready.Please login your account",
                        type: .success,
                        duration: 1.0
                    )
                   // loginVM.email = UserDefaults.standard.string(forKey: "email") ?? ""
                    navigateToLogin = true
                }

            } else {
                showAggremntError = true
            }
        }
    }


    // MARK: - Login Api Call
    func LoginApiCall() {
        Task {
        
            loginVM.email = UserDefaults.standard.string(forKey: "email") ?? ""
            loginVM.password = password ?? ""
            
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
                .foregroundColor(.gray)
                .font(.custom("Inter-Regular", size: 18))
            Text(text)
                .foregroundColor(.gray)
                .font(.custom("Inter-Regular", size: 14))
        }
    }
}
