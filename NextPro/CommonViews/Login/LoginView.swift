//
//  LoginView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToCreatePassword = false
    @State private var loginError = ""
    @State private var userType = ""
    
    
    var body: some View {
        NavigationStack {
            // Use GeometryReader to define a fixed, full-screen container
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background layers (fixed)
                    Image("backgroundimg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                    
                    // Black translucent overlay
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    // Content VStack (fixed at the top)
                    VStack(spacing: 25) {
                        Spacer().frame(height: 40)
                        
                        // Header Text
                        VStack(spacing: 5) {
                            Text("LOG IN TO YOUR ACCOUNT")
                                .font(.custom("Inter-SemiBold", size: 20))
                                .foregroundColor(.white)
                            Text("WELCOME!")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.gray.opacity(0.8))
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
                                if email.isEmpty {
                                    Text("Type..")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                        .padding(.leading, 12)
                                }
                                
                                TextField("", text: $email)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text("Password")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text(" *")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                            
                            ZStack(alignment: .leading) {
                                if password.isEmpty {
                                    Text("Type..")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5)) // custom placeholder
                                        .padding(.leading, 12)
                                }
                                
                                SecureField("", text: $password)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Spacer()
                                Text("Forgot Password?")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer() // Pushes everything above it to the top
                        
                        // Bottom section
                        VStack(spacing: 16) {
                            // Login Button
                            Button(action: {
                                handleLogin()
                            }) {
                                Text("LOG IN")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            
                            // Sign Up Text
                            HStack {
                                Text("Don't have an account yet?")
                                    .foregroundColor(.gray)
                                    .font(.custom("Inter-Regular", size: 16))
                                Text("Sign Up")
                                    .font(.custom("Inter-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 14))
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom) // The key to stop resize
            .navigationDestination(isPresented: $navigateToCreatePassword) {
                CreateNewPasswordView(userTye: self.userType)
                    .navigationBarBackButtonHidden(true)
                           .navigationBarHidden(true)
                           .interactiveDismissDisabled(true)
            }
            
    
    }
    }
    
    func handleLogin() {
//            let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
//            let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
//            
//            if trimmedEmail.isEmpty || trimmedPassword.isEmpty {
//                loginError = "Please enter both email and password."
//                return
//            }
//            
//            // Dummy credentials check
//            if trimmedEmail == "jp" && trimmedPassword == "123" {
//                print("✅ End User login successful.")
//                loginError = ""
//                navigateToCreatePassword = true
//                userType = "0"
//               
//            } else if trimmedEmail == "admin" && trimmedPassword == "admin" {
//                print("✅ Admin login successful.")
//                loginError = ""
//                navigateToCreatePassword = true
//                userType = "1"
//            } else {
//                loginError = "Invalid credentials. Please try again."
//            }
        
        navigateToCreatePassword = true
         userType = "0"
        }
}

#Preview {
    LoginView()
}

