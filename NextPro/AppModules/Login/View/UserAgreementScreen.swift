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
    
    @State private var termsAccepted = false
    @State private var privacyAccepted = false
    
    @State private var webContentHeight: CGFloat = 300
    
    @State private var  termsHTML: String = ""
    @State private var  privacyHTML: String = ""
    @State private var showWebContent = false

    
    private let scrollSpaceName = "AgreementScroll"
    
    var body: some View {
        ZStack{
            Image("backgroundimg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // Top ba
                
                // Title
                VStack(spacing: 6) {
                    Text("User Agreement")
                        .font(.custom("Inter-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Text("Please read and accept both documents to continue")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
                
                // Tabs
                tabsSection
                
                
                VStack(spacing: 0) {
                    GeometryReader { outerProxy in
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                
                                VStack(spacing: 0) {
                                    Color.clear
                                        .frame(height: 1)
                                        .id("TOP_ANCHOR")

                                    if showWebContent {
                                        WebContentView(
                                            htmlString: selectedTab == 0 ? termsHTML : privacyHTML,
                                            onContentHeightChange: { height in
                                                let clamped = max(200, height)
                                                if abs(clamped - webContentHeight) > 1 {
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        webContentHeight = clamped
                                                    }
                                                }
                                            }
                                        )
                                        .frame(height: webContentHeight)
                                        .clipped()
                                        .transition(.opacity) // optional fade-in effect
                                    }

                                    
                                    
                                    Color.clear
                                        .frame(height: 1)
                                        .background(GeometryReader { geo -> Color in
                                            // geo frame in "AgreementScroll" coordinate space
                                            let frame = geo.frame(in: .named(scrollSpaceName))
                                            
                                            DispatchQueue.main.async {
                                                
                                                let visibleHeight = outerProxy.size.height
                                                
                                                let threshold: CGFloat = 10
                                                let reachedBottom = frame.minY <= (visibleHeight + threshold)
                                                
                                                if selectedTab == 0 {
                                                    if reachedBottom && !termsUnlocked {
                                                        termsUnlocked = true
                                                    } else if !reachedBottom {
                                                        
                                                    }
                                                } else {
                                                    if reachedBottom && !privacyUnlocked {
                                                        privacyUnlocked = true
                                                    } else if !reachedBottom {
                                                        
                                                    }
                                                }
                                            }
                                            
                                            return Color.clear
                                        })
                                        .frame(height: 1)
                                    Divider().background(Color.white.opacity(0.15))
                                    
                                    
                                    // Checkbox (part of the scrollable content). It will be visible only after unlocked.
                                    if selectedTab == 0 ? termsUnlocked : privacyUnlocked {
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
                                       

                                    // extra spacing so the checkbox can scroll up and be hidden again
                                    Spacer(minLength: 10)
                                }
                                .padding(10)
                            }
                            .scrollIndicators(.hidden)   
                            .onChange(of: selectedTab) { _ in
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("TOP_ANCHOR", anchor: .top)
                                }
                                
                                
                            }
                            .coordinateSpace(name: scrollSpaceName)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color(hex: "#242424"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: 500) // adjust card height to taste (or use dynamic)
                // Continue button
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
                //.disabled(!(termsAccepted && privacyAccepted))
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .padding(.top,20)
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
        .toast()
        .internetOverlay()
        .onAppear{
                termsHTML = loadHTML("terms")
                privacyHTML = loadHTML("privacy")
            
            // Delay adding WebView so the screen appears first
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
        if !termsAccepted && !privacyAccepted {
                showAggremntAcceptMessage = "Please read and accept both. Go to each tab and scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
            } else if !termsAccepted {
                showAggremntAcceptMessage = "Please go to Terms & Conditions tab, scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
            } else if !privacyAccepted {
                showAggremntAcceptMessage = "Please go to Privacy Policy tab, scroll to the bottom and check the acceptance checkbox"
                showAggremntAcceptError = true
            } 
        else{
            Task {
                viewModel.isAggrementAccepted =  true
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
    }
    
    func LoginApiCall() {
        Task {
        
            loginVM.email = UserDefaults.standard.string(forKey: "email") ?? ""
            loginVM.password = password ?? ""
            
            await loginVM.login()
            if loginVM.loginSuccess {
                isAdmin = loginVM.is_admin
                navigateToHome = true
            }else{
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



// MARK: - WebContentView (non-scrolling WKWebView that reports contentHeight)
struct WebContentView: UIViewRepresentable {
    let htmlString: String
    var onContentHeightChange: ((CGFloat) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator { Coordinator(self, onContentHeightChange: onContentHeightChange) }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.navigationDelegate = context.coordinator
        
        // IMPORTANT: disable internal scrolling so outer SwiftUI ScrollView controls scrolling
        webview.scrollView.isScrollEnabled = false
        webview.isOpaque = false
        webview.backgroundColor = .clear
        
        // Load HTML
        webview.loadHTMLString(htmlString, baseURL: nil)
        return webview
    }
    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // nothing else needed; navigation delegate will catch load finish
//        applyBackground(to: uiView)
//        uiView.loadHTMLString(htmlString, baseURL: nil)
//        DispatchQueue.main.async {
//            uiView.scrollView.setContentOffset(.zero, animated: false)
//        }
//    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only update the background (no reload)
      //  applyBackground(to: uiView)
        
        // Optionally scroll to top when htmlString changes
        if context.coordinator.lastHTMLString != htmlString {
            uiView.loadHTMLString(htmlString, baseURL: nil)
            context.coordinator.lastHTMLString = htmlString
        }
        
        DispatchQueue.main.async {
            uiView.scrollView.setContentOffset(.zero, animated: false)
        }
    }

    
    func applyBackground(to webView: WKWebView) {
        
        
        let js = """
        document.documentElement.style.backgroundColor = "#242424";
        document.body.style.backgroundColor = "#242424";
        document.body.style.color = "#C7C7C7";
        document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(function(h) {
            h.style.color = "#C7C7C7";
        });
        """
        
        
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebContentView
        var onContentHeightChange: ((CGFloat) -> Void)?
        var lastHTMLString: String?
        
        init(_ parent: WebContentView,onContentHeightChange: ((CGFloat) -> Void)?) {
            self.onContentHeightChange = onContentHeightChange
            self.parent = parent
            self.lastHTMLString = nil
        }
        
        
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Query content height from the page
           // parent.applyBackground(to: webView)
            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                if let h = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.onContentHeightChange?(h)
                    }
                } else if let hDouble = result as? Double {
                    DispatchQueue.main.async {
                        self.onContentHeightChange?(CGFloat(hDouble))
                    }
                }
            }
        }
    }
}

