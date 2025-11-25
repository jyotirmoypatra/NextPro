//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI

struct SubmitResetPassword: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @Environment(\.dismiss) private var dismiss
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
                            Text("Enter a new password for your account. Make sure it's something secure and easy for you to remember.")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 40)

                        // New Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text("New Password")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text(" *")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }

                            ZStack(alignment: .trailing) {
                                ZStack(alignment: .leading) {
                                    if newPassword.isEmpty {
                                        Text("Enter new password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .padding(.leading, 14)
                                    }
                                    
                                    if showNewPassword {
                                        TextField("", text: $newPassword)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("", text: $newPassword)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    }
                                }
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                                
                                Button(action: { showNewPassword.toggle() }) {
                                    Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 14)
                            }
                        }

                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text("Confirm Password")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text(" *")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }

                            ZStack(alignment: .trailing) {
                                ZStack(alignment: .leading) {
                                    if confirmPassword.isEmpty {
                                        Text("Confirm new password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .padding(.leading, 14)
                                    }
                                    
                                    if showConfirmPassword {
                                        TextField("", text: $confirmPassword)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("", text: $confirmPassword)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    }
                                }
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 14)
                            }
                        }

                        Spacer().frame(height: 150)  // Prevent cut-off
                    }
                    .padding(.horizontal, 30)
                }

                // FOOTER - Fixed at Bottom
                VStack(spacing: 16) {
                    // Submit Button
                    Button(action: {
                        print("SUBMIT")
                        resetToLogin()
                    }) {
                        Text("SUBMIT")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("Return to login tapped")
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
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    func resetToLogin() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        }
    }
}

#Preview {
    SubmitResetPassword()
}
