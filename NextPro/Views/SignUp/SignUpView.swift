//
//  SignUpView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI


struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""

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
                    Text("JOIN ACCESS CONTROL TODAY")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Text("Sign up for your free 14-day trial.No credit card required.")
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

           

                Spacer() // pushes content to bottom

                // Bottom section
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        print("Login tapped")
                    }) {
                        Text("SIGN UP")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    // Sign Up Text
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                            .font(.custom("Inter-Regular", size: 16))
                        Text("Log In")
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
}


#Preview {
    SignUpView()
}
