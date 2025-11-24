////
////  LoginView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 28/10/25.
////
//
import SwiftUI


struct LoginView: View {
    @StateObject var network = NetworkManager.shared
    @StateObject private var vm = LoginViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @State private var navigateToCreatePassword = false
    @State private var navigateToResetPassword = false
    @State private var showNoInternetAlert = false
    @State private var showLoginFailedAlert = false
    @State private var showPassword = false
    @State private var navigateToHome = false
    @State private var isAdmin = false
    @State private var isDeviceprov = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Image("backgroundimg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                    
                    // Content VStack (fixed at the top)
                    // Scrollable Fields
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 25) {
                            Spacer().frame(height: 40)

                            // Header
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
                                    if vm.email.isEmpty {
                                        Text("Enter Email")
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.leading, 14)
                                    }

                                    TextField("", text: $vm.email)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 14)
                                        .frame(height: 50)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
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

                                ZStack(alignment: .trailing) {
                                    ZStack(alignment: .leading) {
                                        if vm.password.isEmpty {
                                            Text("Enter Password")
                                                .foregroundColor(Color.white.opacity(0.5))
                                                .font(.custom("Inter-Regular", size: 16))
                                                .padding(.leading, 14)
                                        }

                                        if showPassword {
                                            TextField("", text: $vm.password)
                                                .foregroundColor(.white)
                                                .font(.custom("Inter-Regular", size: 16))
                                                .padding(.horizontal, 14)
                                                .frame(height: 50)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                        } else {
                                            SecureField("", text: $vm.password)
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

//                                HStack {
//                                    Spacer()
//                                    Text("Forgot Password?")
//                                        .font(.custom("Inter-Regular", size: 14))
//                                        .foregroundColor(.white)
//                                        .padding(.top, 6)
//                                }
                            }

                            Spacer().frame(height: 150)  // Prevent cut-off
                        }
                        .padding(.horizontal, 30)
                    }

                    // FOOTER - Fixed at Bottom
                    VStack(spacing: 16) {

                        Button(action: {
                            if !network.hasInternet {
                                showNoInternetAlert = true
                                return
                            }

                            
                            if vm.email == "admin" && vm.password == "admin"{
                                navigateToHome = true
                                isDeviceprov = true
                            }else{
                                Task {
                                   
                                    await vm.login()
                                    if vm.loginSuccess {
                                        
                                        // Show success toast
                                        toastManager.show(
                                            message: "Login successfully!",
                                            type: .success,
                                            duration: 1.0
                                        )
                                        
                                        // Navigate after a short delay to show the toast
                                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                                        
                                       // navigateToCreatePassword = true
                                        
                                        isAdmin = (vm.userType == "facility_manager")
                                        if vm.isPasswordReset{
                                            navigateToHome = true
                                        }else{
                                            navigateToCreatePassword = true
                                        }
                                        
                                        
                                    } else {
                                        showLoginFailedAlert = true
                                    }
                                }
                            }
                            
                           
                        }) {
                            Text("LOG IN")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        HStack {
//                            Text("Don't have an account yet?")
//                                .foregroundColor(.gray)
//                                .font(.custom("Inter-Regular", size: 16))
//
//                            Text("Sign Up")
//                                .foregroundColor(.white)
//                                .font(.custom("Inter-Bold", size: 16))
                            
                            
                            Button(action: {
                                
                                navigateToResetPassword = true
                                
                            }) {
                                Text("Forgot Password?")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.top, 6)
                            }
                        }

                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 35)
                    .background(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                        
                    // LOADING OVERLAY
                    if vm.isLoading {
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

            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom) // The key to stop resize
            .navigationDestination(isPresented: $navigateToCreatePassword) {
                CreateNewPasswordView(userType: vm.userType, userName: vm.userName)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
            
            .navigationDestination(isPresented: $navigateToResetPassword) {
              ResetPassword()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
            
            .navigationDestination(isPresented: $navigateToHome) {
                if isAdmin {
                 //   HomeViewAdmin()
                   // OnboardPageDeviceScanView()
                    HomeViewEndUser()
                    
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                } else if isDeviceprov{
                    OnboardPageDeviceScanView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                }
                else {
                   
                    HomeViewEndUser()
                    //OnboardPageDeviceScanView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                }
            }
            
            .onReceive(network.$didCheckInternet) { done in
                if done && !network.hasInternet {
                    showNoInternetAlert = true
                }
            }
            .alert("No Internet Connection", isPresented: $showNoInternetAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please check your connection and try again.")
            }
            .alert("Login Failed", isPresented: $showLoginFailedAlert) {
                            Button("OK", role: .cancel) {}
            } message: {
                Text(vm.loginError.isEmpty ? "Invalid credentials." : vm.loginError)
            }
            .toast() 

    }
    }
    
}




