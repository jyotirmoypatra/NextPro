//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//


import SwiftUI

struct CreateNewPasswordView: View {
    @State private var newPassword = ""
    @State private var confirsPassword = ""
    @State private var navigateToGetStarted = false

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
                    Text("CREATE NEW PASSWORD")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Text("CREATE YOU OWN PASSWORD")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
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
                          if confirsPassword.isEmpty {
                              Text("Confirm new password")
                                  .font(.custom("Inter-Regular", size: 16))
                                  .foregroundColor(Color.white.opacity(0.5)) // custom placeholder
                                  .padding(.leading, 12)
                          }

                          SecureField("", text: $confirsPassword)
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

                Spacer() // pushes content to bottom

                // Bottom section
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        navigateToGetStarted = true
                    }) {
                        Text("UPDATE PASSWORD")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $navigateToGetStarted) {
                        GetStartedView()
                    }

                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CreateNewPasswordView()
}
