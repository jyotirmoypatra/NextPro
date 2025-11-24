//
//  WebViewModal.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 24/11/25.
//

import SwiftUI
import WebKit

struct WebViewModal: View {
    let url: String
    let title: String
    @Binding var isPresented: Bool
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Full-screen semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // WebView Container
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                
                // WebView
                ZStack {
                    WebView(url: url, isLoading: $isLoading)
                    
                    // Loading indicator
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 600)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - WebView Wrapper
struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .white
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load if not already loaded
        if webView.url == nil {
            if let url = URL(string: url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🌐 WebView started loading")
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading")
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("WebView failed to load: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("WebView failed provisional navigation: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WebViewModal(
        url: "https://www.apple.com",
        title: "Privacy Policy",
        isPresented: .constant(true)
    )
}

