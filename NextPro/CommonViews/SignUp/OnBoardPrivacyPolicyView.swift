//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.



import SwiftUI
import WebKit

struct OnBoardPrivacyPolicyView: View {
    @State private var isAccepted = false
    @State private var navigateTermsCondition = false
    @State private var isLoadingWebView = true

    let privacyPolicyURL = "https://www.utahtechlabs.com/privacy-policy" // Replace with your URL

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    // MARK: - Header (Fixed)
                    VStack(spacing: 5) {
//                        Text("PRIVACY POLICY")
//                            .font(.custom("Inter-SemiBold", size: 20))
//                            .foregroundColor(.white)
                        Text("Read our privacy policy to understand how we handle your data.")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    // MARK: - WebView (Scrollable, loads in background)
//                    WebView(url: privacyPolicyURL, isLoading: $isLoadingWebView)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                        .onAppear {
//                            // Trigger WebView load asynchronously to avoid blocking UI
//                            DispatchQueue.main.async {
//                                isLoadingWebView = true
//                            }
//                        }
                    
                    if let filePath = Bundle.main.path(forResource: "privacy", ofType: "html") {
                        let fileURL = URL(fileURLWithPath: filePath)
                        WebView(url: fileURL.absoluteString, isLoading: $isLoadingWebView)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }


                    // MARK: - Checkbox + Accept Button (Fixed)
                    VStack(spacing: 16) {
                        HStack {
                            Button(action: { isAccepted.toggle() }) {
                                Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isAccepted ? .green : .gray)
                            }
                            Text("I accept the Privacy Policy")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white)
                                .onTapGesture { isAccepted.toggle() } // make text tappable
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        
                        Button(action: {
                            if isAccepted {
                                
                               // navigateTermsCondition = true
                                
                                isLoadingWebView = true
                                       
                                       // Delay for 2 seconds before navigating
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                           isLoadingWebView = false
                                           navigateTermsCondition = true
                                }
                            }
                        }) {
                            Text("ACCEPT")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isAccepted ? Color.white : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isAccepted)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .navigationDestination(isPresented: $navigateTermsCondition) {
                            OnboardTermConditionView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                        }
                    }
                    .background(.black)
                   
                }
                

                .ignoresSafeArea(edges: .bottom)
                
                
                if isLoadingWebView{
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
    }
}
