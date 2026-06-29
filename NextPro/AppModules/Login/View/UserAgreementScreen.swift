////
////  UserAgreementScreen.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 11/12/25.
////
//
//
import SwiftUI
import WebKit


struct UserAgreementScreen: View {
    var password : String?
    var  fromLogin: Bool?
    
    @State private var showAggremntError = false
    @State private var showLoginError = false
    @State private var showAggremntAcceptError = false
    @State private var showAggremntAcceptMessage = ""
  
    @State private var isAdmin = false
    @State private var navigateToHome = false
    @State private var navigateToLogin = false
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var viewModel = AggremntAcceptViewModel()
    @StateObject private var loginVM = LoginViewModel()
    
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    // check & unlock states
    @State private var termsUnlocked = false
    @State private var privacyUnlocked = false

    @State private var termsLoaded = false
    @State private var privacyLoaded = false

    @State private var termsAccepted = false
    @State private var privacyAccepted = false

    @State private var termsContentHeight: CGFloat = 300
    @State private var privacyContentHeight: CGFloat = 300
    @State private var showWebContent = false

//     private let termsURL = APIConfig.Web.privacy
//     private let privacyURL = APIConfig.Web.terms
    
    private let termsURL = "https://fe7b-103-75-162-117.ngrok-free.app/privacy/terms.php"
    private let privacyURL = "https://fe7b-103-75-162-117.ngrok-free.app/privacy/privacy.php"

    
    private let scrollSpaceName = "AgreementScroll"
    
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
                    // Title — pinned just below safe area
                    VStack(spacing: 6) {
                        Text("User Agreement")
                            .font(.custom("Inter-Bold", size: 20))
                            .foregroundColor(.white)

                        Text("Please read and accept both documents to continue")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    // Tabs
                    tabsSection

                    // WebView card — fills all remaining space between tabs and button
                    // Single ScrollView owns all scrolling; WKWebView internal scroll is disabled.
                    ZStack(alignment: .top) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 0) {
                                    Color.clear.frame(height: 1).id("TOP_ANCHOR")

                                    if showWebContent {
                                        // Terms WebView (always in hierarchy, hidden when not active)
                                        WebContentView(
                                            urlString: termsURL,
                                            onContentHeightChange: { height in
                                                let clamped = max(200, height)
                                                if abs(clamped - termsContentHeight) > 1 {
                                                    termsContentHeight = clamped
                                                }
                                            },
                                            onLoadFinished: {
                                                termsLoaded = true
                                            }
                                        )
                                        .frame(height: termsContentHeight)
                                        .opacity(selectedTab == 0 ? 1 : 0)
                                        .frame(height: selectedTab == 0 ? termsContentHeight : 0)
                                        .clipped()

                                        // Privacy WebView (always in hierarchy, hidden when not active)
                                        WebContentView(
                                            urlString: privacyURL,
                                            onContentHeightChange: { height in
                                                let clamped = max(200, height)
                                                if abs(clamped - privacyContentHeight) > 1 {
                                                    privacyContentHeight = clamped
                                                }
                                            },
                                            onLoadFinished: {
                                                privacyLoaded = true
                                            }
                                        )
                                        .frame(height: privacyContentHeight)
                                        .opacity(selectedTab == 1 ? 1 : 0)
                                        .frame(height: selectedTab == 1 ? privacyContentHeight : 0)
                                        .clipped()
                                    }

                                    // Bottom sentinel — only counts when page is fully loaded
                                    let currentLoaded = selectedTab == 0 ? termsLoaded : privacyLoaded
                                    GeometryReader { geo -> Color in
                                        let frame = geo.frame(in: .named(scrollSpaceName))
                                        DispatchQueue.main.async {
                                            if currentLoaded {
                                                let reachedBottom = frame.minY < UIScreen.main.bounds.height + 20
                                                if selectedTab == 0 {
                                                    if reachedBottom && !termsUnlocked { termsUnlocked = true }
                                                } else {
                                                    if reachedBottom && !privacyUnlocked { privacyUnlocked = true }
                                                }
                                            }
                                        }
                                        return Color.clear
                                    }
                                    .frame(height: 1)

                                    // Checkbox — only visible after page loaded AND scrolled to bottom
                                    let showCheckbox = selectedTab == 0
                                        ? (termsLoaded && termsUnlocked)
                                        : (privacyLoaded && privacyUnlocked)

                                    if showCheckbox {
                                        Divider().background(Color.white.opacity(0.15))
                                        HStack {
                                            Button(action: {
                                                if selectedTab == 0 { termsAccepted.toggle() } else { privacyAccepted.toggle() }
                                            }) {
                                                Image(systemName: (selectedTab == 0 ? termsAccepted : privacyAccepted) ? "checkmark.square.fill" : "square")
                                                    .font(.title3)
                                                    .foregroundColor(.white)
                                            }
                                            Text(selectedTab == 0 ?
                                                 "I have read and accept the Terms & Conditions" :
                                                 "I have read and accept the Privacy Policy")
                                                .foregroundColor(.white)
                                                .font(.custom("Inter-Regular", size: 14))
                                            Spacer()
                                        }
                                        .padding()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }

                                    Spacer(minLength: 10)
                                }
                                .padding(10)
                            }
                            .scrollIndicators(.hidden)
                            .coordinateSpace(name: scrollSpaceName)
                            .onChange(of: selectedTab) { _ in
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("TOP_ANCHOR", anchor: .top)
                                }
                            }
                        }

                        // Spinner — shown while active tab's page is still loading
                        let isCurrentTabLoading = selectedTab == 0 ? !termsLoaded : !privacyLoaded
                        if isCurrentTabLoading && showWebContent {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.4)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color(hex: "#242424"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // Accept button — pinned at bottom
                    Button(action: {
                        AcceptAggrementCall()
                    }) {
                        Text("ACCEPT AND CONTINUE")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                if viewModel.isLoading || loginVM.isLoading {
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
        }
        .toast()
        .internetOverlay()
        .onAppear {
            // Delay adding WebViews so the screen renders first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showWebContent = true
                }
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
        .modernAlert(isPresented: $showAggremntAcceptError) {
            ModernAlertView(
                title: "Error!",
                message: showAggremntAcceptMessage.isEmpty ? "Please read and accept both.Go to each tab and scroll to the buttom and check the acceptance checkbox" : showAggremntAcceptMessage,
                isSuccess: false,
                buttonTitle: "OK"
            ) { showAggremntAcceptError = false }
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView(isUserInitialSetupCompleted: true,prefilledEmail: UserDefaults.standard.string(forKey: "email") ?? "")
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        
        .navigationDestination(isPresented: $navigateToHome) {
//            if isAdmin {
//               HomeViewAdmin()
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarHidden(true)
//            }
//            else {
//                HomeViewEndUser()
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarHidden(true)
//            }
            
            
            HomeView(isAdmin: isAdmin, initialTab: 0)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        }
        
        
    }
   
    func AcceptAggrementCall() {
//        if !termsAccepted && !privacyAccepted {
//                showAggremntAcceptMessage = "Please read and accept both. Go to each tab and scroll to the bottom and check the acceptance checkbox"
//                showAggremntAcceptError = true
//            } else if !termsAccepted {
//                showAggremntAcceptMessage = "Please go to Terms & Conditions tab, scroll to the bottom and check the acceptance checkbox"
//                showAggremntAcceptError = true
//            } else if !privacyAccepted {
//                showAggremntAcceptMessage = "Please go to Privacy Policy tab, scroll to the bottom and check the acceptance checkbox"
//                showAggremntAcceptError = true
//            }
        
        
            if !termsAccepted && !privacyAccepted {
                
                selectedTab = 0   // move to Terms first
                showAggremntAcceptMessage = "Please read and accept both. Go to each tab and scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
                
            }
            else if !termsAccepted {
                
                selectedTab = 0   // switch to Terms tab
                showAggremntAcceptMessage = "Please go to Terms & Conditions tab, scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
                
            }
            else if !privacyAccepted {
                
                selectedTab = 1   // switch to Privacy tab
                showAggremntAcceptMessage = "Please go to Privacy Policy tab, scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
                
            }
        else{
            Task {
                viewModel.isAggrementAccepted =  true
                await viewModel.accept()

                if viewModel.Successflag {

                   if let fromLoggedin = fromLogin {
                       UserDefaults.standard.set(true, forKey: "is_logged_in")
                       KeychainManager.shared.resetToLogin()
                       
                       
                    } else {
                        
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
                    }

                } else {
                    showAggremntError = true
                }
            }
        }
    }
    
    func LoginApiCall() {
        Task {
        
            loginVM.email = UserDefaults.standard.string(forKey: "email") ?? ""
            loginVM.password = password ?? ""
            
            await loginVM.login()
            if loginVM.loginSuccess {
                // Replace the root window with a fresh ContentView.
                // is_logged_in = true is already set inside loginVM.login(), so
                // the new ContentView routes directly to HomeView.
                //
                // We MUST NOT use navigationDestination here — doing so while
                // UserAgreementScreen is still in the hierarchy (even with a delay)
                // creates a ghost HomeView that:
                //   1. Prevents logout from navigating back to LoginView.
                //   2. Spawns a duplicate DoorOpenView whose onDisappear resets
                //      DoorManager.isMQTTWindowActive → MQTT events are dropped.
                KeychainManager.shared.resetToLogin()
            } else {
                showLoginError = true
            }
        }
    }
    
    // MARK: Tabs UI
    private var tabsSection: some View {
        HStack {
            // Terms & Conditions Tab
            Button { selectedTab = 0 } label: {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        if termsAccepted {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 10, weight: .bold))
                        }
                        
                        
                        Text("Terms & Conditions")
                            .foregroundColor(selectedTab == 0 ? .white : .gray)
                            .font(.custom("Inter-Bold", size: 15))
                        
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 0 ? .white : .clear)
                    
                }
            }
            
            Spacer(minLength: 16)
            
            // Privacy Policy Tab
            Button { selectedTab = 1 } label: {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        
                        if privacyAccepted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        
                        Text("Privacy Policy")
                            .foregroundColor(selectedTab == 1 ? .white : .gray)
                            .font(.custom("Inter-Bold", size: 15))
                        
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedTab == 1 ? .white : .clear)
                    
                }
                    
                    
                
            }
        }
        .padding(.horizontal,20)
        .padding(.top, 28)
    }
    
}



// MARK: - WebContentView (URL-loading, non-scrolling WKWebView that reports contentHeight)
struct WebContentView: UIViewRepresentable {
    let urlString: String
    var onContentHeightChange: ((CGFloat) -> Void)? = nil
    var onLoadFinished: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(onContentHeightChange: onContentHeightChange, onLoadFinished: onLoadFinished)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView(frame: .zero)
        webview.navigationDelegate = context.coordinator
        // Disable internal scroll — outer SwiftUI ScrollView handles all scrolling
        webview.scrollView.isScrollEnabled = false
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .clear
        if let url = URL(string: urlString) {
            context.coordinator.loadedURL = urlString
            webview.load(URLRequest(url: url))
        }
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Reload only if the URL changes
        if context.coordinator.loadedURL != urlString, let url = URL(string: urlString) {
            context.coordinator.loadedURL = urlString
            uiView.load(URLRequest(url: url))
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var onContentHeightChange: ((CGFloat) -> Void)?
        var onLoadFinished: (() -> Void)?
        var loadedURL: String?

        init(onContentHeightChange: ((CGFloat) -> Void)?, onLoadFinished: (() -> Void)?) {
            self.onContentHeightChange = onContentHeightChange
            self.onLoadFinished = onLoadFinished
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                let height: CGFloat
                if let h = result as? CGFloat { height = h }
                else if let h = result as? Double { height = CGFloat(h) }
                else { return }
                DispatchQueue.main.async {
                    self.onContentHeightChange?(height)
                    self.onLoadFinished?()
                }
            }
        }
    }
}


