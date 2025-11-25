//
//  SignUpView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI


struct ResetPassword: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToVerifyOtp = false
    @StateObject private var viewModel = ForgetPasswordRequestViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                // Black translucent overlay
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                // Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        Spacer().frame(height: 40)
                        
                        // Header Text
                        VStack(spacing: 5) {
                            Text("RESET YOUR PASSWORD")
                                .font(.custom("Inter-SemiBold", size: 20))
                                .foregroundColor(.white)
                            Text("Enter the email associated with your account, and we'll send you a code to reset your password securely.")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 40)
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text("Email Address")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text(" *")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                            
                            ZStack(alignment: .leading) {
                                if viewModel.email.isEmpty {
                                    Text("Enter Email")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .padding(.leading, 14)
                                }
                                
                                TextField("", text: $viewModel.email)
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Regular", size: 16))
                                    .padding(.horizontal, 14)
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(10)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                        
                        Spacer().frame(height: 150)  // Prevent cut-off
                    }
                    .padding(.horizontal, 30)
                }
                
                // FOOTER - Fixed at Bottom
                VStack(spacing: 16) {
                    // Confirm Button
                    Button(action: {
                        print("CONFIRM tapped")
                      //  navigateToVerifyOtp = true
                        Task {
                                await viewModel.sendRequest()
                                if viewModel.success {
                                    navigateToVerifyOtp = true
                                }
                            }
                    }) {
                        Text("CONFIRM")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        dismiss() 
                    }) {
                        HStack(spacing: 8) {
                            Image("undoicon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                            
                            Text("Return to log in")
                                .foregroundColor(.gray)
                                .font(.custom("Inter-Regular", size: 16))
                        }
                        .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 35)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                
                // LOADING OVERLAY
                if viewModel.isLoading {
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
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .navigationDestination(isPresented: $navigateToVerifyOtp) {
                VerifyOtpAccount(email: viewModel.email)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


#Preview {
    ResetPassword()
}
