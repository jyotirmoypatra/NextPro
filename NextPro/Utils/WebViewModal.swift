//
//  WebViewModal.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 24/11/25.
//

import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .white
       webView.scrollView.backgroundColor = .white
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
      // applyBackground(to: webView)

        if webView.url == nil {
            if let url = URL(string: url) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func applyBackground(to webView: WKWebView) {
        let isDark = colorScheme == .dark
        
        let js = """
        document.documentElement.style.backgroundColor = "\(isDark ? "#616161" : "#FFFFFF")";
        document.body.style.backgroundColor = "\(isDark ? "#616161" : "#FFFFFF")";
        document.body.style.color = "\(isDark ? "white" : "black")";
        """
        
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
           // parent.applyBackground(to: webView)   // Apply again when page finishes loading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
    }
}

