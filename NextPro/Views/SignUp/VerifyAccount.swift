//
//  SignUpView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI


struct VerifyAccount: View {
    @State private var digit1 = ""
    @State private var digit2 = ""
    @State private var digit3 = ""
    @State private var digit4 = ""
  

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
                    Text("VERIFY ACCOUNT")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Text("We sent a verification code to the email you entered.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                .padding(.bottom, 30)

                // Email Field
                HStack{
                    VStack(alignment: .leading, spacing: 6) {

                        ZStack(alignment: .center) {
                            if digit1.isEmpty {
                                Text("0")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $digit1)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.center)
                                .disableAutocorrection(true)
                        }

                    }
                    VStack(alignment: .leading, spacing: 6) {

                        ZStack(alignment: .center) {
                            if digit2.isEmpty {
                                Text("0")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $digit2)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.center)
                                .disableAutocorrection(true)
                        }

                    }
                    VStack(alignment: .leading, spacing: 6) {

                        ZStack(alignment: .center) {
                            if digit3.isEmpty {
                                Text("0")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $digit3)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.center)
                                .disableAutocorrection(true)
                        }

                    }
                    VStack(alignment: .leading, spacing: 6) {

                        ZStack(alignment: .center) {
                            if digit4.isEmpty {
                                Text("0")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $digit4)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.center)
                                .disableAutocorrection(true)
                        }

                    }
                }
                
               

           

                Spacer() // pushes content to bottom

                // Bottom section
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        print("Verify tapped")
                    }) {
                        Text("VERIFY CODE")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    // Sign Up Text
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
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
    }
}


#Preview {
    VerifyAccount()
}
