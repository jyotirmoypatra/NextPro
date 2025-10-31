//
//  LoginView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 28/10/25.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var firstName = ""
    @State private var LastName = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isChecked = false



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
                    Text("CREATE YOUR ACCOUNT")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Text("Sign up for your free 14-day trial.No credit card required.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)

                
                //name field
                HStack{
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 0) {
                            Text("First Name")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                            Text(" *")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }

                        ZStack(alignment: .leading) {
                            if firstName.isEmpty {
                                Text("Type..")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $firstName)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

                    }
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 0) {
                            Text("Last Name")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)
                            Text(" *")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }

                        ZStack(alignment: .leading) {
                            if LastName.isEmpty {
                                Text("Type..")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                    .padding(.leading, 12)
                            }
                            
                            TextField("", text: $LastName)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

                    }
                }
                
                
                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text("Phone Number")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                        Text(" *")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    ZStack(alignment: .leading) {
                        if phoneNumber.isEmpty {
                            Text("Type..")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.white.opacity(0.5)) // light placeholder
                                .padding(.leading, 12)
                        }
                        
                        TextField("", text: $phoneNumber)
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

                    
                }
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
                              Text("Type..")
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
                
                // Terms and Policy Checkbox
                HStack(alignment: .top) {
                    Button(action: {
                        isChecked.toggle()
                    }) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(isChecked ? .white : .gray)
                            .font(.system(size: 22))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Click here to confirm you're 18 or older and agree")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.custom("Inter-Regular", size: 14))
                        
                        HStack(spacing: 0) {
                            Text("to our ")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.custom("Inter-Regular", size: 14))
                            
                            Button(action: {
                                // Open Terms of Service
                                print("Terms of Service tapped")
                            }) {
                                Text("Terms of Service")
                                    .underline()
                                    .foregroundColor(.gray.opacity(0.8))
                                    .font(.custom("Inter-Regular", size: 14))
                            }
                            
                            Text(" and ")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.custom("Inter-Regular", size: 14))
                            
                            Button(action: {
                                // Open Privacy Policy
                                print("Privacy Policy tapped")
                            }) {
                                Text("Privacy Policy")
                                    .underline()
                                    .foregroundColor(.gray.opacity(0.8))
                                    .font(.custom("Inter-Regular", size: 14))
                            }
                            
                            Text(".")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.custom("Inter-Regular", size: 14))
                        }
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

                    
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    CreateAccountView()
}
