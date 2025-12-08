////
////  LoginView.swift
////  NextPro
////
////  Created by JYOTIRMOY PATRA on 28/10/25.
////
//
import SwiftUI


struct LoginView: View {
    var isUserInitialSetupCompleted : Bool
    var prefilledEmail: String = ""
    @StateObject var network = NetworkManager.shared
    @StateObject private var vm = LoginViewModel()
    @StateObject private var validateVM = ValidateEmailViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @State private var navigateToCreatePassword = false
    @State private var navigateToAggremnt = false
    @State private var navigateToResetPassword = false
    @State private var showNoInternetAlert = false
    @State private var showLoginFailedAlert = false
    @State private var showValidateFailedAlert = false
    @State private var showPassword = false
    @State private var navigateToHome = false
    @State private var isAdmin = false
    @State private var isDeviceprov = false
    
    @State private var isUserInitialSetupDone = false
    
    
    init(isUserInitialSetupCompleted: Bool,prefilledEmail: String = "") {
            self.isUserInitialSetupCompleted = isUserInitialSetupCompleted
            _isUserInitialSetupDone = State(initialValue: isUserInitialSetupCompleted)
        self.prefilledEmail = prefilledEmail
        }
    
    var body: some View {
    
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
                                
//                                if !isUserInitialSetupDone {
//                                    Text("WELCOME!")
//                                        .font(.custom("Inter-Regular", size: 16))
//                                        .foregroundColor(Color.gray.opacity(0.8))
//                                }
                                Text(isUserInitialSetupDone ? "LOG IN TO YOUR ACCOUNT" : "SETUP YOUR ACCOUNT")
                                    .font(.custom("Inter-SemiBold", size: 20))
                                    .foregroundColor(.white)
                                
                                if !isUserInitialSetupDone {
                                    Text("Enter your register email to continue")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                }
                               
                                
                                if isUserInitialSetupDone {
                                    Text("WELCOME!")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                }
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
                                    if isUserInitialSetupDone {
                                        if vm.email.isEmpty {
                                            Text("Enter Email")
                                                .foregroundColor(Color.white.opacity(0.5))
                                                .font(.custom("Inter-Regular", size: 16))
                                                .padding(.leading, 14)
                                                .onAppear {
                                                               if !prefilledEmail.isEmpty {
                                                                   vm.email = prefilledEmail
                                                               }
                                                    }
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
                                    }else{   // fresh account
                                        if validateVM.email.isEmpty {
                                            Text("Enter Email")
                                                .foregroundColor(Color.white.opacity(0.5))
                                                .font(.custom("Inter-Regular", size: 16))
                                                .padding(.leading, 14)
                                        }
                                        
                                        TextField("", text: $validateVM.email)
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
                            }

                            // Password Field
                            if  isUserInitialSetupDone {
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
                                    
                                }
                            }

                            Spacer().frame(height: 150)  // Prevent cut-off
                        }
                        .padding(.horizontal, 30)
                    } .keyboardAware()

                    // FOOTER - Fixed at Bottom
                    VStack(spacing: 16) {
                        if isUserInitialSetupDone {
                            
                            Button(action: {
                                if !network.hasInternet {
                                    showNoInternetAlert = true
                                    return
                                }
                                
                                ///------THIS Is for Testing Purpose - remove later
                                if vm.email == "admin" && vm.password == "admin"{
                                    navigateToHome = true
                                    // isDeviceprov = true
                                    isAdmin = true
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
                                            try? await Task.sleep(nanoseconds: 500_000_000)
                                            
                                            // navigateToCreatePassword = true
                                            
                                            isAdmin = (vm.userType == "facility_manager")
                                            
                                            navigateToHome = true
//                                            if vm.isPasswordReset{
//                                                navigateToHome = true
//                                            }
//                                            else{
//                                                navigateToCreatePassword = true
//                                            }
                                            
                                            
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
                            
                        }else{
                            Button(action: {
                                print("continue account setup")
                                Task {
                                    
                                    ///------THIS Is for Testing Purpose
                                    if validateVM.email == "admin" {
                                        isUserInitialSetupDone = true
                                        vm.email = validateVM.email
                                        return
                                    }
                                    ///-----THIS Is for Testing Purpose - remove later
                                    
                                    await validateVM.validate()
                                    if validateVM.validateSuccess {
                                        
                                        if validateVM.isPasswordReset && validateVM.isAggrementAccept{
                                            isUserInitialSetupDone = true
                                            toastManager.show(
                                                message: "This email is already set up. Please log in with your password",
                                                type: .success,
                                                duration: 1.5
                                            )
                                            vm.email = validateVM.email
                                            
                                        }else if !validateVM.isAggrementAccept && validateVM.isPasswordReset {
                                            toastManager.show(
                                                message: "Please Accept Aggrement!",
                                                type: .success,
                                                duration: 1.0
                                            )
                                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                                            navigateToAggremnt = true
                                        }else{
                                            toastManager.show(
                                                message: "Email validation successfully!",
                                                type: .success,
                                                duration: 1.0
                                            )
                                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                                            
                                            navigateToCreatePassword = true
                                        }
                                        
                                        
                                    }else{
                                        showValidateFailedAlert = true
                                    }
                                }
                                
                            }){
                                Text("VERIFY EMAIL")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                        }
                        HStack {

                            if isUserInitialSetupDone {
                                
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

                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 35)
                    .background(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                        
                    // LOADING OVERLAY
                    if vm.isLoading || validateVM.isLoading{
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
                CreateNewPasswordView(userName: validateVM.email, comingFrom: "login")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
            
            .navigationDestination(isPresented: $navigateToResetPassword) { //forget password navigate
              ResetPassword()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
            .navigationDestination(isPresented: $navigateToAggremnt) { //forget password navigate
              UserAggremntView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
            }
            
            .navigationDestination(isPresented: $navigateToHome) {
                if isAdmin {
                   HomeViewAdmin()
                   // OnboardPageDeviceScanView()
                  //  HomeViewEndUser()
                    
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
            
//            .modernAlert(isPresented: $showNoInternetAlert) {
//                  ModernAlertView(
//                      title: "Error!",
//                      message: "Please check your connection and try again.",
//                      isSuccess: false,
//                      buttonTitle: "OK"
//                  ) { showNoInternetAlert = false }
//            }
            
            .modernAlert(isPresented: $showLoginFailedAlert) {
                  ModernAlertView(
                      title: "Error!",
                      message: vm.loginError.isEmpty ? "Invalid credentials." : vm.loginError,
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showLoginFailedAlert = false }
            }
        
            .modernAlert(isPresented: $showValidateFailedAlert) {
                  ModernAlertView(
                      title: "Error!",
                      message: validateVM.validateEmailError.isEmpty ? "Invalid credentials." : validateVM.validateEmailError,
                      isSuccess: false,
                      buttonTitle: "OK"
                  ) { showValidateFailedAlert = false }
            }
            .internetOverlay()
            .toast()

    
    }
    
}




