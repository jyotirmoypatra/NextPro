//
//  ProfileTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct AdminProfileTabView: View {
	@State private var showAddCard = false
    @State private var notificationsEnabled = true

    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
               
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                       
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")// Replace with your actual asset name
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .foregroundColor(.gray.opacity(0.6))
                                .clipShape(Circle())
                                .shadow(radius: 6)
                                
                            
                            // Full Name
                            Text("Jyotirmoy")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white)

                            // Phone Number
                            Text("9859844884")
                                .font(.custom("Inter-Regular", size: 13))
                                .foregroundColor(.gray)


                            Button(action: {
                               
                            }) {
                                Text("Edit Profile")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Settings Section
                        VStack(spacing: 0) {
                            // Update Password
//                            UserProfileRow(title: "Update Password",textColor: .white) {
//                               
//                            }

//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)

                            // Support
                            UserProfileRow(title: "Support",textColor: .white) {
                                // Handle support action
                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)

                            // Notifications Toggle
                            HStack {
                                Text("Notifications")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30) // consistent with other rows
                            
//                            Divider().background(Color.white.opacity(0.15))
//
//                            UserProfileRow(title: "Add Card") {
//                                // Handle support action
//                            }
                            
                            
//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//                            
//                            UserProfileRow(title: "Privacy Policy" , textColor: .white) {
//                                
// 
//                            }
//                            
//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//                            
//                            UserProfileRow(title: "Terms and Conditon" , textColor: .white) {
//                                
//
//                            }

//                            Divider().background(Color.white.opacity(0.15))
//                                .padding(.horizontal,20)
//                            
//                            UserProfileRow(title: "Delete Account" , textColor: .red) {
//                               
//                            }

                            Divider().background(Color.white.opacity(0.15))
                                .padding(.horizontal,20)
                            
                            UserProfileRow(title: "Logout" , textColor: .red) {
                                KeychainManager.shared.clearUserDefaultsAndKeychainData()
                                KeychainManager.shared.resetToLogin()
                            }

                           
                        }
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
        
        

        }
       

    }
    
  
}
