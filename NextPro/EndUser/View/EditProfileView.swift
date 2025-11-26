//
//  EditProfileView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 24/11/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
 //   @State private var email: String = ""
    @State private var address: String = ""
    @State private var showSuccessAlert = false
    @State private var isLoading = false
    
    // Parameters to receive data from ProfileEndUserView
    let initialFullName: String
    let initialPhoneNumber: String
    
    init(fullName: String = "", phoneNumber: String = "") {
        self.initialFullName = fullName
        self.initialPhoneNumber = phoneNumber
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // MARK: - Header (Fixed at top)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Spacer()
                    
                    Text("Edit Profile")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible button for symmetry
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundColor(.clear)
                            .padding(10)
                    }
                    .disabled(true)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.black)
                .frame(maxWidth: .infinity, alignment: .top)
                .zIndex(1)
                
                // Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        Spacer().frame(height: 90)
                            
                            // Profile Image Section
                            VStack(spacing: 12) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("person")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        )
                                    
                                    // Edit icon
                                    Button(action: {
                                        // Handle image picker
                                        print("Change profile picture")
                                    }) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .padding(8)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.black.opacity(0.4), lineWidth: 2)
                                            )
                                    }
                                    .offset(x: -5, y: -5)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Full Name Field
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 0) {
                                    Text("Full Name")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)
                                    Text(" *")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                }
                                
                                ZStack(alignment: .leading) {
                                    if fullName.isEmpty {
                                        Text("Enter your full name")
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.leading, 14)
                                    }
                                    
                                    TextField("", text: $fullName)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 14)
                                        .frame(height: 50)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                        .autocapitalization(.words)
                                        .disableAutocorrection(false)
                                }
                            }
                            
                            // Phone Number Field
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
                                        Text("Enter your phone number")
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.leading, 14)
                                    }
                                    
                                    TextField("", text: $phoneNumber)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 14)
                                        .frame(height: 50)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                        .keyboardType(.phonePad)
                                }
                            }
                            
//                            // Email Field
//                            VStack(alignment: .leading, spacing: 6) {
//                                HStack(spacing: 0) {
//                                    Text("Email Address")
//                                        .font(.custom("Inter-Medium", size: 16))
//                                        .foregroundColor(.white)
//                                }
//                                
//                                ZStack(alignment: .leading) {
//                                    if email.isEmpty {
//                                        Text("Enter your email")
//                                            .foregroundColor(Color.white.opacity(0.5))
//                                            .font(.custom("Inter-Regular", size: 16))
//                                            .padding(.leading, 14)
//                                    }
//                                    
//                                    TextField("", text: $email)
//                                        .foregroundColor(.white)
//                                        .font(.custom("Inter-Regular", size: 16))
//                                        .padding(.horizontal, 14)
//                                        .frame(height: 50)
//                                        .background(Color.white.opacity(0.15))
//                                        .cornerRadius(10)
//                                        .autocapitalization(.none)
//                                        .keyboardType(.emailAddress)
//                                        .disableAutocorrection(true)
//                                }
//                            }
                            
                            // Address Field
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 0) {
                                    Text("Address")
                                        .font(.custom("Inter-Medium", size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    if address.isEmpty {
                                        Text("Enter your address")
                                            .foregroundColor(Color.white.opacity(0.5))
                                            .font(.custom("Inter-Regular", size: 16))
                                            .padding(.leading, 14)
                                            .padding(.top, 14)
                                    }
                                    
                                    TextEditor(text: $address)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .frame(height: 100)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                        .autocapitalization(.sentences)
                                }
                            }
                            
                            Spacer().frame(height: 150)  // Prevent cut-off
                        }
                        .padding(.horizontal, 30)
                    }
                .keyboardAware()
                    
                    // FOOTER - Fixed at Bottom
                    VStack(spacing: 16) {
                        // Save Button
                        Button(action: {
                            saveProfile()
                        }) {
                            Text("SAVE CHANGES")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        
                        // Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("CANCEL")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 35)
                    .background(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                // LOADING OVERLAY
                if isLoading {
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserData()
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully!")
        }
    }
    
    func loadUserData() {
        // Load data from passed parameters or UserDefaults as fallback
        fullName = !initialFullName.isEmpty ? initialFullName :  ""
        phoneNumber = !initialPhoneNumber.isEmpty ? initialPhoneNumber :  ""
      //  email = UserDefaults.standard.string(forKey: "user_email") ?? ""
        
    }
    
    func saveProfile() {
        // Validation
        guard !fullName.isEmpty else {
            print("⚠️ Full name is required")
            return
        }
        
        guard !phoneNumber.isEmpty else {
            print("⚠️ Phone number is required")
            return
        }
        
        // Show loading
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            
            isLoading = false
            showSuccessAlert = true
            
            print("✅ Profile updated successfully")
        }
    }
}

#Preview {
    EditProfileView(fullName: "John Doe", phoneNumber: "+1234567890")
}


