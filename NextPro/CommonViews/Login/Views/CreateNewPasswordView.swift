//
//  CreateNewPassword.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.



import SwiftUI

struct CreateNewPasswordView: View {
   // var userType: String
    var userName: String
    var comingFrom: String
    @Environment(\.dismiss) private var dismiss
    @StateObject var network = NetworkManager.shared
    @StateObject private var viewModel = CreateNewPasswordViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @State private var showNoInternetAlert = false
    @State private var showPassword = false
    @State private var showUpdateFailedAlert = false
    @State private var navigateToAggrement = false
    @State private var isAdmin = false
    @State private var showSuccessUpdateAlert = false

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
                                        .padding(.leading, 14)
                                }
                                SecureField("", text: $viewModel.newPassword)
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
                                    if viewModel.confirmPassword.isEmpty {
                                        Text("Confirm new password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .padding(.leading, 12)
                                    }
                                    
                                    if showPassword {
                                        TextField("", text: $viewModel.confirmPassword)
                                            .foregroundColor(.white)
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.horizontal, 14)
                                            .frame(height: 50)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("", text: $viewModel.confirmPassword)
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
                        if !network.hasInternet {
                            showNoInternetAlert = true
                            return
                        }
                        
                        Task {
                            
                            
                            await viewModel.updatePassword(username: self.userName)

                            if viewModel.updateSuccess {
                                // Show success toast
                               
                                if comingFrom == "user_profile"{
                                    showSuccessUpdateAlert = true
                                }else{ //come from setup user
                                    
                                    toastManager.show(
                                        message: "Password updated successfully!",
                                        type: .success,
                                        duration: 1.0
                                    )
                                    
                                    // Navigate after a short delay to show the toast
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    
                                   // isAdmin = (userType == "facility_manager")
                                    navigateToAggrement = true
                                }
                                
                            }else{
                                showUpdateFailedAlert = true
                            }
                        }
                        
                    }) {
                        Text(comingFrom == "login" ? "CREATE PASSWORD" :  "UPDATE PASSWORD")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                   
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }
                
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }

            
            
            .modernAlert(isPresented: $showNoInternetAlert) {
                  ModernAlertView(
                      title: "Error!",
                      message: "Please check your connection and try again.",
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showNoInternetAlert = false }
            }
            

            
            
            .modernAlert(isPresented: $showUpdateFailedAlert) {
                  ModernAlertView(
                      title: "Error!",
                      message: viewModel.errorMessage.isEmpty ? "Invalid credentials." : viewModel.errorMessage,
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showUpdateFailedAlert = false }
            }
            

            
            .modernAlert(isPresented: $showSuccessUpdateAlert) {
                  ModernAlertView(
                      title: "Success!",
                      message: "Your Password updated successfully",
                      isSuccess: true,
                      buttonTitle: "OK"
                  ) {
                      showSuccessUpdateAlert = false
                      dismiss()
                  }
            }
            .navigationDestination(isPresented: $navigateToAggrement) {
                UserAggremntView(password: viewModel.confirmPassword )
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
            
        }
        .internetOverlay()
       // .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toast()  // Add toast modifier

           
    }
}

