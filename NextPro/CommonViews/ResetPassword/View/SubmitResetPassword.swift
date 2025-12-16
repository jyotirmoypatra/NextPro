////
////  CreateNewPassword.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 29/10/25.
////
//
//
//import SwiftUI
//
//struct SubmitResetPassword: View {
//    var userEmail : String
//    @State private var showNewPassword = false
//    @State private var showConfirmPassword = false
//    @StateObject private var viewModel = CreateNewPasswordViewModel()
//    @StateObject private var toastManager = ToastManager.shared
//    @State private var navigateToLogin = false
//    @State private var showUpdateFailedAlert = false
//    @Environment(\.dismiss) private var dismiss
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .top) {
//                // Background image
//                Image("backgroundimg")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//                    .ignoresSafeArea()
//
//                // Black translucent overlay
//                Color.black.opacity(0.9)
//                    .ignoresSafeArea()
//
//                // Scrollable Content
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack(spacing: 25) {
//                        Spacer().frame(height: 40)
//
//                        // Header Text
//                        VStack(spacing: 5) {
//                            Text("RESET YOUR PASSWORD")
//                                .font(.custom("Inter-SemiBold", size: 20))
//                                .foregroundColor(.white)
//                            Text("Enter a new password for your account. Make sure it's something secure and easy for you to remember.")
//                                .font(.custom("Inter-Regular", size: 16))
//                                .foregroundColor(Color.gray.opacity(0.8))
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding(.bottom, 40)
//                        
//                        
////                        PasswordField(
////                            title: "New Password",
////                            placeholder: "Enter new password",
////                            text: $viewModel.newPassword,
////                            showText: $showNewPassword,
////                            focused: $focusedField,
////                            field: .newPassword
////                        )
////
////                        
////                        
////                        if focusedField == .newPassword || !viewModel.newPassword.isEmpty {
////                            PasswordPolicyView(
////                                policy: passwordPolicy(for: viewModel.newPassword)
////                            )
////                            
////                            .transition(.opacity.combined(with: .move(edge: .top)))
////                            .animation(.easeInOut(duration: 0.25), value: viewModel.newPassword)
////                        }
//
//                        
////                        PasswordField(
////                            title: "Confirm Password",
////                            placeholder: "Enter confirm password",
////                            text: $viewModel.confirmPassword,
////                            showText: $showConfirmPassword,
////                            focused: $focusedField,
////                            field: .confirmPassword
////                        )
//                        
//                        // New Password Field
////                        VStack(alignment: .leading, spacing: 6) {
////                            HStack(spacing: 0) {
////                                Text("New Password")
////                                    .font(.custom("Inter-Medium", size: 16))
////                                    .foregroundColor(.white)
////                                Text(" *")
////                                    .font(.system(size: 14))
////                                    .foregroundColor(.red)
////                            }
////
////                            ZStack(alignment: .trailing) {
////                                ZStack(alignment: .leading) {
////                                    if viewModel.newPassword.isEmpty {
////                                        Text("Enter new password")
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .foregroundColor(Color.white.opacity(0.5))
////                                            .padding(.leading, 14)
////                                    }
////                                    
////                                    if showNewPassword {
////                                        TextField("", text: $viewModel.newPassword)
////                                            .foregroundColor(.white)
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .padding(.horizontal, 14)
////                                            .frame(height: 50)
////                                            .autocapitalization(.none)
////                                            .disableAutocorrection(true)
////                                    } else {
////                                        SecureField("", text: $viewModel.newPassword)
////                                            .foregroundColor(.white)
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .padding(.horizontal, 14)
////                                            .frame(height: 50)
////                                            .autocapitalization(.none)
////                                            .disableAutocorrection(true)
////                                    }
////                                }
////                                .background(Color.white.opacity(0.15))
////                                .cornerRadius(10)
////                                
////                                Button(action: { showNewPassword.toggle() }) {
////                                    Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
////                                        .foregroundColor(.white.opacity(0.8))
////                                }
////                                .padding(.trailing, 14)
////                            }
////                        }
//
//                        // Confirm Password Field
////                        VStack(alignment: .leading, spacing: 6) {
////                            HStack(spacing: 0) {
////                                Text("Confirm Password")
////                                    .font(.custom("Inter-Medium", size: 16))
////                                    .foregroundColor(.white)
////                                Text(" *")
////                                    .font(.system(size: 14))
////                                    .foregroundColor(.red)
////                            }
////
////                            ZStack(alignment: .trailing) {
////                                ZStack(alignment: .leading) {
////                                    if viewModel.confirmPassword.isEmpty {
////                                        Text("Confirm new password")
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .foregroundColor(Color.white.opacity(0.5))
////                                            .padding(.leading, 14)
////                                    }
////                                    
////                                    if showConfirmPassword {
////                                        TextField("", text: $viewModel.confirmPassword)
////                                            .foregroundColor(.white)
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .padding(.horizontal, 14)
////                                            .frame(height: 50)
////                                            .autocapitalization(.none)
////                                            .disableAutocorrection(true)
////                                    } else {
////                                        SecureField("", text: $viewModel.confirmPassword)
////                                            .foregroundColor(.white)
////                                            .font(.custom("Inter-Regular", size: 16))
////                                            .padding(.horizontal, 14)
////                                            .frame(height: 50)
////                                            .autocapitalization(.none)
////                                            .disableAutocorrection(true)
////                                    }
////                                }
////                                .background(Color.white.opacity(0.15))
////                                .cornerRadius(10)
////                                
////                                Button(action: { showConfirmPassword.toggle() }) {
////                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
////                                        .foregroundColor(.white.opacity(0.8))
////                                }
////                                .padding(.trailing, 14)
////                            }
////                        }
//
//                        Spacer().frame(height: 150)  // Prevent cut-off
//                    }
//                    .padding(.horizontal, 30)
//                } .keyboardAware()
//
//                // FOOTER - Fixed at Bottom
//                VStack(spacing: 16) {
//                    // Submit Button
//                    Button(action: {
//                        print("SUBMIT")
//                        //resetToLogin()
//                        
//                        Task {
//                            
//                            await viewModel.updatePassword(username: self.userEmail)
//
//                            if viewModel.updateSuccess {
//                                // Show success toast
//                                toastManager.show(
//                                    message: "Password updated successfully!",
//                                    type: .success,
//                                    duration: 1.0
//                                )
//                                
//                                // Navigate after a short delay to show the toast
//                                try? await Task.sleep(nanoseconds: 1_000_000_000)
//                                
//                                
//                               // KeychainManager.shared.resetToLogin()
//                                navigateToLogin = true
//                                
//                            }else{
//                                showUpdateFailedAlert = true
//                            }
//                        }
//                        
//                    }) {
//                        Text("SUBMIT")
//                            .font(.custom("Inter-SemiBold", size: 16))
//                            .foregroundColor(.black)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(10)
//                    }
//                    
//                    Button(action: {
//                        navigateToLogin = true 
//                    }) {
//                        HStack(spacing: 8) {
//                            Image("undoicon")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.gray)
//
//                            Text("Return to log in")
//                                .foregroundColor(.gray)
//                                .font(.custom("Inter-Regular", size: 16))
//                        }
//                        .font(.system(size: 14))
//                    }
//                    .buttonStyle(.plain)
//                }
//                .padding(.horizontal, 30)
//                .padding(.bottom, 35)
//               // .background(.black)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//                
//                
//                if viewModel.isLoading {
//                    ZStack {
//                        Color.black.opacity(0.4)
//                            .ignoresSafeArea()
//
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(1.8)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .ignoresSafeArea()
//                }
//            }
//            .onTapGesture {
//                UIApplication.shared.hideKeyboard()
//            }
//            
//            .navigationDestination(isPresented: $navigateToLogin) {
//                LoginView(isUserInitialSetupCompleted: true,prefilledEmail: UserDefaults.standard.string(forKey: "email") ?? "")
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarHidden(true)
//                    .interactiveDismissDisabled(true)
//            }
//            .modernAlert(isPresented: $showUpdateFailedAlert) {
//                  ModernAlertView(
//                      title: "Error!",
//                      message: viewModel.errorMessage.isEmpty ? "Invalid credentials." : viewModel.errorMessage,
//                      isSuccess: false,
//                      buttonTitle: "OK"
//                  ) { showUpdateFailedAlert = false }
//            }
//        }
//        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .toast() 
//    }
//    
// 
//}
//
