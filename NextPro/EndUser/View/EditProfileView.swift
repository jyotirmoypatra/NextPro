//
//  EditProfileView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 24/11/25.
//

import SwiftUI
import Photos

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var showSuccessAlert = false
    @State private var isLoading = false
    @StateObject private var toastManager = ToastManager.shared
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showPermissionAlert = false
    @State private var showSourcePicker = false
    @State private var pickerSource: ImagePicker.SourceType? = nil

    
    @StateObject private var viewModel = UploadProfileImgViewModel()
    
    
    // Parameters to receive data from ProfileEndUserView
    let initialFullName: String
    let initialPhoneNumber: String
    let initialemail: String
    
    init(fullName: String = "", phoneNumber: String = "", email : String = "") {
        self.initialFullName = fullName
        self.initialPhoneNumber = phoneNumber
        self.initialemail = email
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                // MARK: - Header (Fixed at top)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
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
                                
                                if let img = selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        )
                                } else {
                                    
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.gray.opacity(0.6))
                                        .clipShape(Circle())
                                    
                                    
                                }
                                
                                
                                // Edit icon
                                Button(action: {
                                    // Handle image picker
                                    print("Change profile picture")
                                    //checkPhotoPermission()
                                    showSourcePicker = true
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
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text("Email ID")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("Enter your email")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(.custom("Inter-Regular", size: 16))
                                        .padding(.leading, 14)
                                }
                                
                                TextField("", text: $email)
                                    .foregroundColor(.gray)
                                    .font(.custom("Inter-Regular", size: 16))
                                    .padding(.horizontal, 14)
                                    .frame(height: 50)
                                    .disabled(true)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(10)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
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
                if isLoading  || viewModel.isLoading{
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
        .toast()  // Add toast modifier
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
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully!")
        }
    
        
        .sheet(item: $pickerSource) { source in
            ImagePicker(
                selectedImage: $selectedImage,
                sourceType: source
            ) { cropped in
                
//                if let jpeg = cropped.jpegData(compressionQuality: 0.8) {
//                    viewModel.ImgBase64 = jpeg.base64EncodedString()
//                    
//                    Task {
//                        await viewModel.UploadImg()
//                        if viewModel.uploadImgSuccess {
//                            toastManager.show(
//                                message: viewModel.uploadSuccessMessage,
//                                type: .success,
//                                duration: 1.0
//                            )
//                        } else {
//                            toastManager.show(
//                                message: viewModel.errorMessage,
//                                type: .error,
//                                duration: 1.0
//                            )
//                        }
//                    }
//                }
                
                
                
                if let compressed = cropped.compressTo(maxKB: 300) {
                    viewModel.ImgBase64 = compressed.base64EncodedString()

                    Task {
                        await viewModel.UploadImg()
                        if viewModel.uploadImgSuccess {
                            toastManager.show(
                                message: viewModel.uploadSuccessMessage,
                                type: .success,
                                duration: 1.0
                            )
                        } else {
                            toastManager.show(
                                message: viewModel.errorMessage,
                                type: .error,
                                duration: 1.0
                            )
                        }
                    }
                }

                
                
            }
        }

        
        .alert("Permission Needed", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow photo library access to select a profile picture.")
        }
        
        
        .sheet(isPresented: $showSourcePicker) {
            VStack(spacing: 0) {
                
                // Drag indicator
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                
                // Camera
                Button {

                    showSourcePicker = false
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                           checkCameraPermission()
                       }
                } label: {
                    Text("Camera")
                        .font(.custom("Inter-Bold", size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .foregroundColor(.blue)
                }
                .padding(.vertical,20)
                Divider().background(Color.white.opacity(0.3))
                
                // Gallery
                Button {
                    showSourcePicker = false
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                           checkPhotoPermission()
                       }
                } label: {
                    Text("Photo Library")
                        .font(.custom("Inter-Bold", size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.blue)
                }
                .padding(.vertical,20)
                Divider().background(Color.white.opacity(0.3))
                
                // Cancel
                Button {
                    showSourcePicker = false
                } label: {
                    Text("Cancel")
                        .font(.custom("Inter-Bold", size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundColor(.red)
                }
                .padding(.top, 10)
                
            }
            
            .cornerRadius(20)
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.hidden)
        }
        
        
        
    }
    
    func loadUserData() {
        // Load data from passed parameters or UserDefaults as fallback
        fullName = !initialFullName.isEmpty ? initialFullName :  ""
        phoneNumber = !initialPhoneNumber.isEmpty ? initialPhoneNumber :  ""
        email = !initialemail.isEmpty ? initialemail : ""
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
    
    

    
    func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        if status == .authorized || status == .limited {
            pickerSource = .gallery
        }
        else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    pickerSource = (newStatus == .authorized || newStatus == .limited) ? .gallery : nil
                    showPermissionAlert = !(newStatus == .authorized || newStatus == .limited)
                }
            }
        }
        else {
            showPermissionAlert = true
        }
    }

    
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            pickerSource = .camera

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    pickerSource = granted ? .camera : nil
                    showPermissionAlert = !granted
                }
            }

        default:
            showPermissionAlert = true
        }
    }

    
    
}

#Preview {
    EditProfileView(fullName: "John Doe", phoneNumber: "+1234567890")
}


