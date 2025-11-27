//
//  SignUpView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 29/10/25.
//

import SwiftUI
import Combine


struct VerifyOtpAccount: View {
    @State private var digit1 = ""
    @State private var digit2 = ""
    @State private var digit3 = ""
    @State private var digit4 = ""
    @State private var digit5 = ""
    
    @StateObject private var resendVM = ForgetPasswordRequestViewModel()
    @StateObject var viewModel =  VerifyOtpViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @State private var counter: Int = 8
    @State private var timerActive: Bool = true
    @State private var showOtpVerifyFailedAlert = false
   // @State private var showOtpResendFailedAlert = false

    

    var email : String
    @State private var navigateToResetPassword = false
    @Environment(\.dismiss) private var dismiss
    
    // Focus state for auto-advancing
    @FocusState private var focusedField: OTPField?
    
    enum OTPField: Int {
        case digit1, digit2, digit3, digit4, digit5, digit6
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background image
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                
                // Black translucent overlay
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                // Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
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
                    
                    // OTP Fields
                    HStack(spacing: 10){
                        // Digit 1
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit1.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                      
                                }
                                
                                TextField("", text: $viewModel.digit1)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit1)
                                    .onChange(of: viewModel.digit1) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit1)
                                    }
                            }
                        }
                        
                        // Digit 2
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit2.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                       
                                }
                                
                                TextField("", text: $viewModel.digit2)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit2)
                                    .onChange(of: viewModel.digit2) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit2)
                                    }
                            }
                        }
                        
                        // Digit 3
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit3.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                        
                                }
                                
                                TextField("", text: $viewModel.digit3)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit3)
                                    .onChange(of: viewModel.digit3) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit3)
                                    }
                            }
                        }
                        
                        // Digit 4
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit4.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                       
                                }
                                
                                TextField("", text: $viewModel.digit4)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit4)
                                    .onChange(of: viewModel.digit4) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit4)
                                    }
                            }
                        }
                        
                        // Digit 5
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit5.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                       
                                }
                                
                                TextField("", text: $viewModel.digit5)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit5)
                                    .onChange(of: viewModel.digit5) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit5)
                                    }
                            }
                        }
                        
                        // Digit 6
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack(alignment: .center) {
                                if viewModel.digit6.isEmpty {
                                    Text("")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(Color.white.opacity(0.5))
                                       
                                }
                                
                                TextField("", text: $viewModel.digit6)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .multilineTextAlignment(.center)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .digit6)
                                    .onChange(of: viewModel.digit6) { newValue in
                                        handleDigitChange(newValue: newValue, field: .digit6)
                                    }
                            }
                        }
                    }
                    
                        //otp resend
                        HStack {
                            if timerActive {
                                Text("Resend OTP in \(counter)s")
                                    .foregroundColor(.gray.opacity(0.8))
                                    .font(.custom("Inter-Regular", size: 16))
                            } else {
                                Button(action: {
                                  resendOtpNow()
                                }) {
                                    Text("RESEND OTP")
                                        .font(.custom("Inter-SemiBold", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .underline()
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .onReceive(timer) { _ in
                            if timerActive {
                                if counter > 0 {
                                    counter -= 1
                                } else {
                                    timerActive = false
                                }
                            }
                        }

                        
                        
                    Spacer().frame(height: 150)  // Prevent cut-off by fixed footer
                }
                .padding(.horizontal, 30)
            }
                
                // FOOTER - Fixed at Bottom
                VStack(spacing: 16) {
                    // Verify Button
                    Button(action: {
                        Task {
                            await viewModel.verifyOtp(emailId: self.email)
                            if viewModel.success {
                                navigateToResetPassword = true
                            }else{
                                showOtpVerifyFailedAlert = true
                            }
                        }
                    }) {
                        Text("VERIFY CODE")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    // Return to login
                    Button(action: {
                        print("Return to login tapped")
                        dismiss()
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
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 35)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            
            
            // LOADING OVERLAY
            if viewModel.isLoading || resendVM.isLoading {
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
        .ignoresSafeArea(.keyboard, edges: .bottom) // Prevents UI from moving when keyboard appears
        .navigationDestination(isPresented: $navigateToResetPassword) {
            SubmitResetPassword(userEmail: self.email)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .interactiveDismissDisabled(true)
        }
        .onAppear {
            
           resendVM.email = self.email
            // Auto-focus first field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .digit1
            }
        }
        .alert("Failed", isPresented: $showOtpVerifyFailedAlert) {
                        Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage.isEmpty ? "Invalid credentials." : viewModel.errorMessage)
        }
        
//        .alert("Failed to resend OTP", isPresented: $showOtpResendFailedAlert) {
//                        Button("OK", role: .cancel) {}
//        } message: {
//            Text(resendVM.errorMessage.isEmpty ? "Invalid credentials." : resendVM.errorMessage)
//        }
        .toast() 
    }
    
    
    private func resendOtpNow() {
       
        focusedField = nil

        Task {
                await resendVM.sendRequest()
                if resendVM.success {
                    counter = 20
                    timerActive = true
                    toastManager.show(
                        message: "Resend otp successfully!",
                        type: .success,
                        duration: 1.0
                    )
                }else{
                    // showOtpResendFailedAlert = true
                    toastManager.show(
                        message: resendVM.errorMessage,
                        type: .error,
                        duration: 1.0
                      )
                }
            }
    }

    
    // MARK: - Helper Functions
    private func handleDigitChange(newValue: String, field: OTPField) {
        // Limit to 1 character
        let filtered = String(newValue.prefix(1))
        
        switch field {
        case .digit1:
            viewModel.digit1 = filtered
            if filtered.count == 1 { focusedField = .digit2 }
        case .digit2:
            viewModel.digit2 = filtered
            if filtered.count == 1 { focusedField = .digit3 }
            else if filtered.isEmpty { focusedField = .digit1 }
        case .digit3:
            viewModel.digit3 = filtered
            if filtered.count == 1 { focusedField = .digit4 }
            else if filtered.isEmpty { focusedField = .digit2 }
        case .digit4:
            viewModel.digit4 = filtered
            if filtered.count == 1 { focusedField = .digit5 }
            else if filtered.isEmpty { focusedField = .digit3 }
        case .digit5:
            viewModel.digit5 = filtered
            if filtered.count == 1 { focusedField = .digit6 }
            else if filtered.isEmpty { focusedField = .digit4 }
        case .digit6:
            viewModel.digit6 = filtered
            if filtered.isEmpty { focusedField = .digit5 }
            // Last field - dismiss keyboard when filled
            else { focusedField = nil }
        }
    }
}

