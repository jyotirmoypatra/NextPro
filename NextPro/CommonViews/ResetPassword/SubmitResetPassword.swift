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

    var body: some View {
        ZStack {
            // Background image
            Image("backgroundimg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
          

            // Black translucent overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()

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

                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text("New Password")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                        Text(" *")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    ZStack(alignment: .leading) {
                        if newPassword.isEmpty {
                            Text("Enter new password")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                .padding(.leading, 12)
                        }
                        
                        TextField("", text: $newPassword)
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
                        Text("Confirm Password")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                        Text(" *")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    ZStack(alignment: .leading) {
                          if confirmPassword.isEmpty {
                              Text("Confirm new password")
                                  .font(.custom("Inter-Regular", size: 16))
                                  .foregroundColor(Color.white.opacity(0.5)) // custom placeholder
                                  .padding(.leading, 12)
                          }

                          SecureField("", text: $confirmPassword)
                              .padding()
                              .background(Color.white.opacity(0.15))
                              .cornerRadius(8)
                              .foregroundColor(.white)
                      }

                    
                }

                Spacer() // pushes content to bottom

                // Bottom section
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        print("SUBMIT")
                    }) {
                        Text("SUBMIT")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                }
                
                Button(action: {
                    // 👉 Perform navigation or action here
                    print("Return to login tapped")
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
               .buttonStyle(.plain) // prevents default blue tint + removes highlight
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    SubmitResetPassword()
}
