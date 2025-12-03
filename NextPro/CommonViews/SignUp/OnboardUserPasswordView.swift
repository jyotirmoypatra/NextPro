//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.



import SwiftUI

struct OnboardUserPasswordView: View {
   
    @State private var newpass = ""
    @State private var confirmpass = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    @State private var navigateToPrivacyPolicy = false
    @State private var showPassword = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                ScrollView { // ✅ Add ScrollView to manage height & keyboard
                    VStack(spacing: 25) {
                        Spacer().frame(height: 40)
                        
                        // Header
                        VStack(spacing: 5) {
                            Text("CREATE NEW PASSWORD")
                                .font(.custom("Inter-SemiBold", size: 20))
                                .foregroundColor(.white)
                            Text("CREATE YOU OWN PASSWORD")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color.gray.opacity(0.8))
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
                            
                            ZStack(alignment: .leading) {
                                if newpass.isEmpty {
                                    Text("Enter new password")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .padding(.leading, 12)
                                }
                                SecureField("", text: $newpass)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .frame(height: 50)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
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
                                    if confirmpass.isEmpty {
                                        Text("Confirm new password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .padding(.leading, 12)
                                    }
                                    
                                    if showPassword {
                                        TextField("", text: $confirmpass)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("", text: $confirmpass)
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
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.trailing, 14)
                            }
                        }
                        
                        Spacer()
                        
                       
                        
                    }
                    .padding(.horizontal, 25) // ✅ Apply padding to entire VStack
                } .keyboardAware()
                
                // Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
                        navigateToPrivacyPolicy = true
                    }) {
                        Text("SAVE PASSWORD")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $navigateToPrivacyPolicy) {
                   
                        OnBoardPrivacyPolicyView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                    
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
               
                
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }

            
        }
       // .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toast()  // Add toast modifier

           
    }
}

