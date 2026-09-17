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

    @State private var termsLoaded = false
    @State private var privacyLoaded = false

    // Unlocked once that tab's webview has been scrolled all the way to its own bottom —
    // gates the checkbox row (dim + not tappable until then). Sticky: only ever flips true,
    // never back to false from scrolling back up. No JS involved: driven purely by the
    // native UIScrollViewDelegate in WebContentView.
    @State private var termsUnlocked = false
    @State private var privacyUnlocked = false

    // Live, two-way position tracker (unlike *Unlocked above) — reflects whether the webview
    // is at its bottom RIGHT NOW, used only to show/hide the down-arrow hint.
    @State private var termsAtBottom = false
    @State private var privacyAtBottom = false

    @State private var termsAccepted = false
    @State private var privacyAccepted = false

    @State private var showWebContent = false

    // Live WKWebView references, captured once each is created, so the down-arrow button
    // can command the currently active tab's webview to scroll to its own bottom.
    @State private var termsWebView: WKWebView?
    @State private var privacyWebView: WKWebView?

     private let termsURL = APIConfig.Web.terms
     private let privacyURL = APIConfig.Web.privacy

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

                    // WebView card — simple structure, no outer ScrollView, no JS: the webview
                    // fills the available space and scrolls itself; the acceptance checkbox is
                    // a plain, always-visible row below it (not overlapping).
                    ZStack {
                        VStack(spacing: 0) {
                            // Webview area — fills all remaining space above the checkbox
                            ZStack {
                                if showWebContent {
                                    // Terms WebView (always in hierarchy, hidden when not active)
                                    WebContentView(
                                        urlString: termsURL,
                                        isActive: selectedTab == 0,
                                        onLoadingStateChange: { isLoading in
                                            termsLoaded = !isLoading
                                            if isLoading {
                                                termsUnlocked = false
                                                termsAtBottom = false
                                            }
                                        },
                                        onScrolledToBottom: { atBottom in
                                            // Sticky unlock: once reached the bottom once, stay
                                            // unlocked — scrolling back up afterward should
                                            // never re-dim the checkbox again.
                                            if atBottom {
                                                termsUnlocked = true
                                            }
                                            // Live position, for the down-arrow hint only.
                                            termsAtBottom = atBottom
                                        },
                                        onWebViewReady: { webView in
                                            termsWebView = webView
                                        }
                                    )
                                    .opacity(selectedTab == 0 ? 1 : 0)
                                    .allowsHitTesting(selectedTab == 0)

                                    // Privacy WebView (always in hierarchy, hidden when not active)
                                    WebContentView(
                                        urlString: privacyURL,
                                        isActive: selectedTab == 1,
                                        onLoadingStateChange: { isLoading in
                                            privacyLoaded = !isLoading
                                            if isLoading {
                                                privacyUnlocked = false
                                                privacyAtBottom = false
                                            }
                                        },
                                        onScrolledToBottom: { atBottom in
                                            // Sticky unlock: once reached the bottom once, stay
                                            // unlocked — scrolling back up afterward should
                                            // never re-dim the checkbox again.
                                            if atBottom {
                                                privacyUnlocked = true
                                            }
                                            // Live position, for the down-arrow hint only.
                                            privacyAtBottom = atBottom
                                        },
                                        onWebViewReady: { webView in
                                            privacyWebView = webView
                                        }
                                    )
                                    .opacity(selectedTab == 1 ? 1 : 0)
                                    .allowsHitTesting(selectedTab == 1)

                                    // Spinner — shown while the active tab's page is still loading
                                    let isCurrentTabLoading = selectedTab == 0 ? !termsLoaded : !privacyLoaded
                                    if isCurrentTabLoading {
                                        VStack(spacing: 16) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                .scaleEffect(1.8)

                                            Text(selectedTab == 0
                                                 ? "Loading Terms & Conditions..."
                                                 : "Loading Privacy Policy...")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundColor(.black.opacity(0.7))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.white)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(alignment: .bottomTrailing) {
                                // Down-arrow — scrolls the active tab's webview toward its own
                                // bottom. Always shown in either tab whenever that tab isn't
                                // currently at its bottom, independent of whether it's already
                                // been unlocked or whether the page is still loading.
                                let currentAtBottom = selectedTab == 0 ? termsAtBottom : privacyAtBottom
                                if !currentAtBottom {
                                    ScrollDownArrowButton(action: scrollActiveWebViewDown)
                                        .padding(.trailing, 24)
                                        .padding(.bottom, 40)
                                }
                            }

                            // Checkbox — below the webview. Dimmed and not tappable until that
                            // tab's webview has been scrolled all the way to its own bottom.
                            let isCurrentAccepted = selectedTab == 0 ? termsAccepted : privacyAccepted
                            let checkboxColor = isCurrentAccepted ? Color.black : Color.init(hex: "#383838")
                            let isCurrentUnlocked = selectedTab == 0 ? termsUnlocked : privacyUnlocked

                            Divider().background(Color.black.opacity(0.2))
                            Button(action: {
                                if isCurrentUnlocked {
                                    if selectedTab == 0 { termsAccepted.toggle() } else { privacyAccepted.toggle() }
                                } else {
                                    toastManager.show(
                                        message: "Scroll to the bottom to enable acceptance",
                                        type: .warning,
                                        duration: 1.5
                                    )
                                }
                            }) {
                                HStack {
                                    Image(systemName: isCurrentAccepted ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 30))
                                        .foregroundColor(checkboxColor)
                                    Text(selectedTab == 0 ?
                                         "I have read and agree to the ZYLX Terms & Conditions" :
                                         "I have read and agree to the ZYLX Privacy Policy")
                                        .foregroundColor(checkboxColor)
                                        .font(.custom("Inter-Bold", size: 15))
                                    Spacer()
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 15)
                            }
                            .buttonStyle(.plain)
                            .opacity(isCurrentUnlocked ? 1.0 : 0.4)
                            .animation(.easeInOut(duration: 0.2), value: isCurrentUnlocked)
                        }
                    }
                    .background(Color.white)
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
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
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
            HomeView(isAdmin: isAdmin, initialTab: 0)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        }
        
        
    }
   
    func AcceptAggrementCall() {
        
            if !termsAccepted && !privacyAccepted {
                
                switchToAgreementTabAndShowAlert(
                    tab: 0,
                    message: "Please read and accept both. Go to each tab and scroll to the bottom and check the acceptance checkbox"
                )
                
            }
            else if !termsAccepted {
                
                switchToAgreementTabAndShowAlert(
                    tab: 0,
                    message: "Please go to Terms & Conditions tab, scroll to the bottom and check the acceptance checkbox"
                )
                
            }
            else if !privacyAccepted {
                
                switchToAgreementTabAndShowAlert(
                    tab: 1,
                    message: "Please go to Privacy Policy tab, scroll to the bottom and check the acceptance checkbox"
                )
                
            }
        else{
            Task {
                viewModel.isAggrementAccepted =  true
                await viewModel.accept()

                if viewModel.Successflag {
                    
                   if let fromLoggedin = fromLogin, fromLoggedin {
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
                KeychainManager.shared.resetToLogin()
            } else {
                showLoginError = true
            }
        }
    }

    private func switchToAgreementTabAndShowAlert(tab: Int, message: String) {
        showAggremntAcceptError = false
        showAggremntAcceptMessage = message
        selectedTab = tab

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showAggremntAcceptError = true
        }
    }

    /// Scrolls the currently active tab's webview toward its own bottom, whatever the page's
    /// own layout looks like. A plain static page scrolls its top-level document, which is
    /// what `webView.scrollView` mirrors. But some pages (e.g. https://dev.nextprotechnologies.com/terms-and-conditions
    /// and /privacy-policy) use the common `html, body { height: 100%; overflow-y: auto }`
    /// pattern — `document.scrollingElement` (the `<html>` element) never actually overflows,
    /// while `<body>` is the one with real scrollable content. WKWebView's native scrollView
    /// only ever mirrors the top-level *document* scroll, so for a page like this it never
    /// moves at all no matter what we set it to. Ask the page itself, via JS, which element is
    /// actually scrollable right now and move that one directly.
    private func scrollActiveWebViewDown() {
        guard let webView = selectedTab == 0 ? termsWebView : privacyWebView else { return }
        webView.evaluateJavaScript(Self.scrollToBottomScript) { _, error in
            if let error {
                print("⚠️ scrollActiveWebViewDown JS error: \(error)")
            }

            // Reflect "reached the bottom" immediately instead of waiting for the native
            // scroll-event bridge (see WebContentView.Coordinator) to report back.
            DispatchQueue.main.async {
                if self.selectedTab == 0 {
                    self.termsUnlocked = true
                    self.termsAtBottom = true
                } else {
                    self.privacyUnlocked = true
                    self.privacyAtBottom = true
                }
            }
        }
    }

    private static let scrollToBottomScript = """
    (function() {
        function isScrollable(el) {
            if (!el || el.scrollHeight - el.clientHeight <= 5) return false;
            if (el === document.scrollingElement) return true;
            var overflowY = window.getComputedStyle(el).overflowY;
            return overflowY === 'auto' || overflowY === 'scroll';
        }
        var best = document.scrollingElement || document.documentElement;
        var bestDelta = best.scrollHeight - best.clientHeight;
        var all = document.querySelectorAll('*');
        for (var i = 0; i < all.length; i++) {
            var el = all[i];
            if (!isScrollable(el)) continue;
            var delta = el.scrollHeight - el.clientHeight;
            if (delta > bestDelta) {
                bestDelta = delta;
                best = el;
            }
        }
        best.scrollTop = best.scrollHeight;
        return true;
    })();
    """

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



// MARK: - Down-arrow scroll hint (bounces up/down while visible)
private struct ScrollDownArrowButton: View {
    let action: () -> Void
    @State private var animate = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.4), radius: 6)
        }
        .offset(y: animate ? 5 : -5)
        .onAppear {
            animate = true
        }
        .animation(
            .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
            value: animate
        )
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - WebContentView (URL-loading WKWebView, scrolls itself)
struct WebContentView: UIViewRepresentable {
    let urlString: String
    var isActive: Bool = true
    var onLoadingStateChange: ((Bool) -> Void)? = nil
    var onScrolledToBottom: ((Bool) -> Void)? = nil
    var onWebViewReady: ((WKWebView) -> Void)? = nil

    /// Name the page's injected listener posts to — matched by the message handler below.
    private static let scrollMessageHandlerName = "uaScroll"

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoadingStateChange: onLoadingStateChange, onScrolledToBottom: onScrolledToBottom)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: Self.scrollMessageHandlerName)
        config.userContentController = contentController

        let webview = WKWebView(frame: .zero, configuration: config)
        webview.navigationDelegate = context.coordinator
        webview.scrollView.delegate = context.coordinator
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.backgroundColor = .clear
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.scrollView.showsHorizontalScrollIndicator = false
        if let url = URL(string: urlString) {
            context.coordinator.loadedURL = urlString
            webview.load(URLRequest(url: url))
        }
        // Deferred: setting @State synchronously from inside makeUIView (mid SwiftUI view
        // update) can silently fail to stick — dispatch it to the next runloop turn instead.
        DispatchQueue.main.async {
            onWebViewReady?(webview)
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

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // WKUserContentController.add(_:name:) retains the handler strongly — break that
        // reference explicitly instead of leaking the coordinator for the process's lifetime.
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: scrollMessageHandlerName)
    }

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var onLoadingStateChange: ((Bool) -> Void)?
        var onScrolledToBottom: ((Bool) -> Void)?
        var loadedURL: String?

        init(onLoadingStateChange: ((Bool) -> Void)?, onScrolledToBottom: ((Bool) -> Void)?) {
            self.onLoadingStateChange = onLoadingStateChange
            self.onScrolledToBottom = onScrolledToBottom
        }

        /// Fires for every native `scroll` event the injected listener (installed in
        /// `didFinish` below) reports. Unlike polling this view via `evaluateJavaScript` —
        /// which WebKit can defer/batch until an active scroll gesture settles — a page's own
        /// `scroll` events aren't throttled that way, so this reacts immediately, mid-gesture.
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let percent = (message.body as? NSNumber)?.doubleValue else { return }
            onScrolledToBottom?(percent >= 0.98)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoadingStateChange?(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadingStateChange?(false)
            installScrollListener(in: webView)

            // `didFinish` only means the page's own navigation completed — the actual
            // agreement text can still be rendering asynchronously after that (e.g. fetched
            // and inserted by the page's own script after load). Checking contentSize once,
            // right away, would see that not-yet-rendered content as "nothing to scroll" and
            // unlock prematurely. Instead, only conclude "short content, nothing to scroll"
            // once the content size has held steady across several checks a couple of
            // seconds apart — genuinely short content stays put; content still rendering
            // keeps changing and never satisfies this.
            checkForShortContent(in: webView, previousHeight: -1, stableCount: 0, attempt: 0)
        }

        private func checkForShortContent(in webView: WKWebView, previousHeight: CGFloat, stableCount: Int, attempt: Int) {
            guard attempt < 8 else { return } // ~5s of polling, then give up — real scrollable content, let the user's own scroll drive unlock

            let sv = webView.scrollView
            let currentHeight = sv.contentSize.height
            let fits = currentHeight <= sv.bounds.height + 24
            let unchanged = abs(currentHeight - previousHeight) < 1

            if fits && unchanged && stableCount >= 3 {
                onScrolledToBottom?(true)
                return
            }

            // Once content is clearly taller than the viewport by a solid margin, it's real,
            // scrollable content — stop polling early instead of continuing pointlessly.
            if !fits && currentHeight > sv.bounds.height * 1.5 {
                return
            }

            let nextStableCount = (fits && unchanged) ? stableCount + 1 : 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.checkForShortContent(in: webView, previousHeight: currentHeight, stableCount: nextStableCount, attempt: attempt + 1)
            }
        }

        /// Installs a native `scroll` event listener that pushes the current scroll
        /// fraction back to Swift via the "uaScroll" message handler every time it fires.
        ///
        /// Deliberately does NOT pick one scrollable element once and cache it: some pages
        /// (e.g. https://dev.nextprotechnologies.com/terms-and-conditions and /privacy-policy)
        /// still show no overflow anywhere at `didFinish` time — their real content renders
        /// in asynchronously afterward (same reason `checkForShortContent` above has to poll
        /// instead of checking once). Picking a target too early would lock onto the wrong
        /// element permanently. Instead this listens on every plausible scroll source AND
        /// re-resolves which element is actually scrollable fresh, inside the handler, every
        /// time it fires — since a scroll event only exists once something really is
        /// scrolling, that's always correct regardless of load timing.
        ///
        /// This also covers the specific reason those two pages don't respond to the native
        /// `UIScrollViewDelegate` at all: they use the common
        /// `html, body { height: 100%; overflow-y: auto }` pattern, where `<html>` (i.e.
        /// `document.scrollingElement`) never actually overflows and `<body>` is the one
        /// that does — WKWebView's own scrollView only ever mirrors the top-level document's
        /// scroll, so for a page shaped like this it never fires at all.
        private func installScrollListener(in webView: WKWebView) {
            let script = """
            (function() {
                if (window.__uaScrollHandlerInstalled) return;
                window.__uaScrollHandlerInstalled = true;

                function isScrollable(el) {
                    if (!el || el.scrollHeight - el.clientHeight <= 5) return false;
                    if (el === document.scrollingElement) return true;
                    var overflowY = window.getComputedStyle(el).overflowY;
                    return overflowY === 'auto' || overflowY === 'scroll';
                }

                function findScrollable() {
                    var best = document.scrollingElement || document.documentElement;
                    var bestDelta = best.scrollHeight - best.clientHeight;
                    var all = document.querySelectorAll('*');
                    for (var i = 0; i < all.length; i++) {
                        var el = all[i];
                        if (!isScrollable(el)) continue;
                        var delta = el.scrollHeight - el.clientHeight;
                        if (delta > bestDelta) {
                            bestDelta = delta;
                            best = el;
                        }
                    }
                    return best;
                }

                function report() {
                    var target = findScrollable();
                    var scrollHeight = target.scrollHeight;
                    var clientHeight = target.clientHeight;
                    if (scrollHeight <= clientHeight) {
                        // Nothing is scrollable right now — either the content hasn't
                        // finished rendering in yet, or the page genuinely has nothing to
                        // scroll. Treating that as "fully scrolled" would instantly unlock
                        // the checkbox with no actual scrolling. Native's
                        // checkForShortContent is the one that safely concludes "genuinely
                        // short content" (only after the size has held stable across
                        // several checks) — leave that case to it and don't report here.
                        return;
                    }
                    var percent = Math.max(0, Math.min(1, (target.scrollTop + clientHeight) / scrollHeight));
                    try {
                        window.webkit.messageHandlers.uaScroll.postMessage(percent);
                    } catch (e) {}
                }

                // Cover every shape a page's real scroll container can take: a normal
                // top-level document (window/document), or the html/body-both-overflow
                // pattern where body itself is the one that truly scrolls.
                window.addEventListener('scroll', report, { passive: true });
                document.addEventListener('scroll', report, { passive: true });
                document.documentElement.addEventListener('scroll', report, { passive: true });
                document.body.addEventListener('scroll', report, { passive: true });

                report();
            })();
            """

            webView.evaluateJavaScript(script)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onLoadingStateChange?(false)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onLoadingStateChange?(false)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let contentHeight = scrollView.contentSize.height
            let visibleHeight = scrollView.bounds.height
            guard contentHeight > 0, visibleHeight > 0 else { return }

            // A fixed "within 6pt of the exact bottom" threshold is too strict for pages
            // whose contentSize keeps adjusting slightly (dynamic/Angular-rendered pages,
            // bounce/inertia rounding) — the user can be scrolled all the way down and still
            // never land within 6pt. Use a percentage of how far through the page they've
            // scrolled instead: once they've reached 95% of the way down, treat that as
            // "reached the bottom".
            let scrolledDistance = scrollView.contentOffset.y + visibleHeight
            let percentScrolled = min(1.0, max(0.0, scrolledDistance / contentHeight))
            onScrolledToBottom?(percentScrolled >= 0.98)
        }
    }
}


