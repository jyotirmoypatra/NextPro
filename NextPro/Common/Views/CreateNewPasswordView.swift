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
    @State private var navigateToLogin = false
    @State private var showNoInternetAlert = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var showUpdateFailedAlert = false
    @State private var navigateToAggrement = false
    @State private var isAdmin = false
    @State private var showSuccessUpdateAlert = false
    
    enum NewPassField: Hashable {
        case newpass
        case confirmpass
    }

    @FocusState private var focusedField: NewPassField?
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top){
                // Background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.93)
                    .ignoresSafeArea()
                
                // MARK: - Header (Fixed at top)
                VStack{
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                            // .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Spacer()
                        
                        
                    }
                    .padding(.horizontal)
                    // .background(Color.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(999)
                    
                    
                    ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) { // Add ScrollView to manage height & keyboard
                        VStack(spacing: 15) {
                          Spacer().frame(height: 200)
                            
                            // Header
                            VStack(spacing: 5) {
                                // Text(comingFrom == "login" ? "CREATE YOUR ACCOUNT" : "UPDATE YOUR PASSWORD")
                                if (comingFrom == "validate_email"){
                                    Image("zylx")
                                     .resizable()
                                     .frame(width: 315, height: 120)
                                     .padding(.bottom,40)
                                }
                                
                                Text(
                                    comingFrom == "validate_email" ? "CREATE YOUR ACCOUNT" :
                                        comingFrom == "user_profile" ? "UPDATE YOUR PASSWORD" :
                                        comingFrom == "forgetPassword" ? "RESET YOUR PASSWORD" :
                                        "" // fallback
                                )
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.white)
                                Text("Create a secure password for your account")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(Color.gray.opacity(0.8))
                            }
                            .padding(.bottom, 40)

                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 0) {
                                    Text(comingFrom == "validate_email" ? "Create Password" : "New Password")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)
                                    Text(" *")
                                        .foregroundColor(.red)
                                }
                                
                                ZStack(alignment: .leading) {
                                    
                                    if viewModel.newPassword.isEmpty {
                                        Text("Enter New Password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(.leading, 14)
                                    }
                                    
                                    HStack {
                                        if showNewPassword {
                                            TextField("", text: $viewModel.newPassword)
                                                .foregroundColor(.white)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .focused($focusedField, equals: .newpass)
                                        } else {
                                            SecureField("", text: $viewModel.newPassword)
                                                .foregroundColor(.white)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .focused($focusedField, equals: .newpass)
                                        }
                                        
                                        Button(action: { showNewPassword.toggle() }) {
                                            Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: 50)
                                }
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                            .id(NewPassField.newpass)
                            
                            
                            
                            if !viewModel.newPassword.isEmpty {
                                PasswordPolicyView(
                                    policy: passwordPolicy(for: viewModel.newPassword)
                                )
                                
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut(duration: 0.25), value: viewModel.newPassword)
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 0) {
                                    Text("Confirm Password")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)
                                    Text(" *")
                                        .foregroundColor(.red)
                                }
                                
                                ZStack(alignment: .leading) {
                                    
                                    if viewModel.confirmPassword.isEmpty {
                                        Text("Confirm New Password")
                                            .font(.custom("Inter-Regular", size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(.leading, 14)
                                    }
                                    
                                    HStack {
                                        if showConfirmPassword {
                                            TextField("", text: $viewModel.confirmPassword)
                                                .foregroundColor(.white)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .focused($focusedField, equals: .confirmpass)
                                        } else {
                                            SecureField("", text: $viewModel.confirmPassword)
                                                .foregroundColor(.white)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .focused($focusedField, equals: .confirmpass)
                                        }
                                        
                                        Button(action: { showConfirmPassword.toggle() }) {
                                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: 50)
                                }
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }.id(NewPassField.confirmpass)
                            
                            
                            Spacer()
                            
                            
                            
                        }
                        .padding(.horizontal, 10)
                        
                    }
                    .onChange(of: focusedField) { field in
                           guard let field else { return }
                           withAnimation(.easeInOut(duration: 0.25)) {
                               proxy.scrollTo(field, anchor: .center)
                           }
                       }


                }
                } .padding(.bottom, 100)
                
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
                                }
                                else if comingFrom == "validate_email" { //come from setup user
                                    
                                    toastManager.show(
                                        message: "Password updated successfully!",
                                        type: .success,
                                        duration: 1.0
                                    )
                                    
                                    // Navigate after a short delay to show the toast
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    
                                    // isAdmin = (userType == "facility_manager")
                                    navigateToAggrement = true
                                } else {
                                    toastManager.show(
                                        message: "Password updated successfully!",
                                        type: .success,
                                        duration: 1.0
                                    )
                                    
                                    // Navigate after a short delay to show the toast
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    
                                    
                                    // KeychainManager.shared.resetToLogin()
                                    navigateToLogin = true
                                }
                                
                            }else{
                                showUpdateFailedAlert = true
                            }
                        }
                        
                    }) {
                        // Text(comingFrom == "validate_email" ? "CREATE PASSWORD" :  "UPDATE PASSWORD")
                        Text(
                            comingFrom == "validate_email" ? "CREATE PASSWORD" :
                                comingFrom == "user_profile" ? "UPDATE PASSWORD" :
                                comingFrom == "forgetPassword" ? "RESET PASSWORD" :
                                "" // fallback
                        )
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
                // .background(.black)
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
            
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(isUserInitialSetupCompleted: true,prefilledEmail: UserDefaults.standard.string(forKey: "email") ?? "")
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .interactiveDismissDisabled(true)
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
                UserAgreementScreen(password:viewModel.confirmPassword)
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


//struct PasswordField: View {
//    var title: String
//    var placeholder: String
//    @Binding var text: String
//    @Binding var showText: Bool     // for eye button
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack(spacing: 0) {
//                Text(title)
//                    .font(.custom("Inter-Medium", size: 16))
//                    .foregroundColor(.white)
//                Text(" *")
//                    .foregroundColor(.red)
//            }
//            
//            ZStack(alignment: .leading) {
//                
//                if text.isEmpty {
//                    Text(placeholder)
//                        .font(.custom("Inter-Regular", size: 16))
//                        .foregroundColor(.white.opacity(0.5))
//                        .padding(.leading, 14)
//                }
//                
//                HStack {
//                    if showText {
//                        TextField("", text: $text)
//                            .foregroundColor(.white)
//                            .autocapitalization(.none)
//                            .disableAutocorrection(true)
//                    } else {
//                        SecureField("", text: $text)
//                            .foregroundColor(.white)
//                            .autocapitalization(.none)
//                            .disableAutocorrection(true)
//                    }
//                    
//                    Button(action: { showText.toggle() }) {
//                        Image(systemName: showText ? "eye.slash.fill" : "eye.fill")
//                            .foregroundColor(.white.opacity(0.8))
//                    }
//                }
//                .padding(.horizontal, 14)
//                .frame(height: 50)
//            }
//            .background(Color.white.opacity(0.15))
//            .cornerRadius(10)
//        }
//    }
//}





struct PasswordPolicyView: View {
    let policy: PasswordPolicy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PolicyRow(text: "At least one uppercase letter (A-Z)", isValid: policy.hasUppercase)
            PolicyRow(text: "At least one lowercase letter (a-z)", isValid: policy.hasLowercase)
            PolicyRow(text: "At least one number (0-9)", isValid: policy.hasNumber)
            PolicyRow(text: "At least one special character (@#$%^&+=!)", isValid: policy.hasSpecialChar)
            PolicyRow(text: "8-15 characters", isValid: policy.validLength)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
        
    }
}

struct PolicyRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
                .font(.system(size: 13))
            
            
            Text(text)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(isValid ? .green : .gray)
        }
        
    }
}

struct PasswordPolicy {
    let hasUppercase: Bool
    let hasLowercase: Bool
    let hasNumber: Bool
    let hasSpecialChar: Bool
    let validLength: Bool
}

func passwordPolicy(for password: String) -> PasswordPolicy {
    PasswordPolicy(
        hasUppercase: password.range(of: "[A-Z]", options: .regularExpression) != nil,
        hasLowercase: password.range(of: "[a-z]", options: .regularExpression) != nil,
        hasNumber: password.range(of: "[0-9]", options: .regularExpression) != nil,
        hasSpecialChar: password.range(of: "[@#$%^&+=!]", options: .regularExpression) != nil,
        validLength: password.count >= 8 && password.count <= 15
    )
}
