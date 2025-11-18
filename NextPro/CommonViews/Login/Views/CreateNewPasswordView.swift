//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.



import SwiftUI

struct CreateNewPasswordView: View {
    var userTye: String
    @StateObject var network = NetworkManager.shared
    @StateObject private var viewModel = CreateNewPasswordViewModel()
    @State private var showNoInternetAlert = false
    @State private var showUpdateFailedAlert = false
    @State private var navigateToHome = false
    @State private var isAdmin = false


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
                                if viewModel.newPassword.isEmpty {
                                    Text("Enter new password")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .padding(.leading, 12)
                                }
                                SecureField("", text: $viewModel.newPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
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
                            ZStack(alignment: .leading) {
                                if viewModel.confirmPassword.isEmpty {
                                    Text("Confirm new password")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .padding(.leading, 12)
                                }
                                SecureField("", text: $viewModel.confirmPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                       
                        
                    }
                    .padding(.horizontal, 25) // ✅ Apply padding to entire VStack
                }
                
                // Bottom Button
                VStack(spacing: 16) {
                    Button(action: {
                        if !network.hasInternet {
                            showNoInternetAlert = true
                            return
                        }
                        
                        Task {
                            await viewModel.updatePassword()

                            if viewModel.updateSuccess {
                                isAdmin = (viewModel.userType == "1")
                                navigateToHome = true
                            }else{
                                showUpdateFailedAlert = true
                            }
                        }
                        
                    }) {
                        Text("UPDATE PASSWORD")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $navigateToHome) {
                        if isAdmin {
                            HomeViewAdmin()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                        } else {
                            HomeViewEndUser()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .alert("No Internet Connection", isPresented: $showNoInternetAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please check your connection and try again.")
            }
            
            .alert("Update Failed", isPresented: $showUpdateFailedAlert) {
                            Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage.isEmpty ? "Invalid credentials." : viewModel.errorMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)

           
    }
}

