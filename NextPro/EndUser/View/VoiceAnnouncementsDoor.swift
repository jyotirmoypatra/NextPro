//
//  VoiceAnnouncementsDoor.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/12/25.
//


import SwiftUI

struct VoiceAnnouncementsDoor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSaved = false
    @State private var grantedOptions = [
        MessageOption(text: "Access granted", isSelected: true),
        MessageOption(text: "Door unlocked", isSelected: false),
        MessageOption(text: "Welcome, entry approved", isSelected: false)
    ]
    
    @State private var deniedOptions = [
        MessageOption(text: "Access denied", isSelected: true),
        MessageOption(text: "Entry rejected", isSelected: false),
        MessageOption(text: "Cannot unlock the door", isSelected: false)
    ]
    
    @State private var unauthorizedOptions = [
        MessageOption(text: "Unauthorized door", isSelected: true),
        MessageOption(text: "You are not allowed", isSelected: false),
        MessageOption(text: "Access blocked", isSelected: false)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Full-screen semi-transparent background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack(spacing : 10){
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Spacer()
                        
                        Text("Voice Announcements")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(111)
                    
                    ScrollView {
                        VStack(spacing: 22) {
                            
                            
                            // MARK: 1 - Access Granted
                            MessageSection(
                                title: "Access Granted",
                                options: $grantedOptions
                            )
                            
                            // MARK: 2 - Access Denied
                            MessageSection(
                                title: "Access Denied",
                                options: $deniedOptions
                            )
                            
                            // MARK: 3 - Unauthorized
                            MessageSection(
                                title: "Unauthorized",
                                options: $unauthorizedOptions
                            )
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    VStack {
                                      if showSaved {
                                          Text("Saved successfully")
                                              .foregroundColor(.green)
                                              .font(.custom("Inter-Medium", size: 18))
                                              .transition(.opacity)
                                      }
                                      
                                      Button(action: {
                                          saveMessages()
                                      }) {
                                          Text("Save")
                                              .font(.custom("Inter-SemiBold", size: 18))
                                              .foregroundColor(.black)
                                              .frame(maxWidth: .infinity)
                                              .padding()
                                              .background(Color.green)
                                              .clipShape(RoundedRectangle(cornerRadius: 14))
                                      }
                                      .padding(.horizontal, 16)
                                      .padding(.bottom, 25)
                                  }
                }
            }
        }
    }
    func saveMessages() {
            let granted = grantedOptions.first(where: { $0.isSelected })?.text
            let denied = deniedOptions.first(where: { $0.isSelected })?.text
            let unauthorized = unauthorizedOptions.first(where: { $0.isSelected })?.text
            
            UserDefaults.standard.set(granted, forKey: "voice_granted")
            UserDefaults.standard.set(denied, forKey: "voice_denied")
            UserDefaults.standard.set(unauthorized, forKey: "voice_unauthorized")
            
            withAnimation {
                showSaved = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaved = false
                }
            }
        }
}

// MARK: - Option Model
struct MessageOption: Identifiable {
    let id = UUID()
    let text: String
    var isSelected: Bool
}

// MARK: - Reusable Section Component
struct MessageSection: View {
    let title: String
    @Binding var options: [MessageOption]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.custom("Inter-SemiBold", size: 17))
            
            VStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    Button {
                        selectOption(at: index)
                    } label: {
                        HStack {
                            Image(systemName: options[index].isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(options[index].isSelected ? .green : .white)
                                .font(.system(size: 22))

                            Text(options[index].text)
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                    }

                    if index != options.count - 1 {
                        Divider()
                            .padding(.leading, 35)
                    }
                }
            }
            .background(Color(hex: "#171717"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
        }
    }
    
    private func selectOption(at index: Int) {
        for i in options.indices {
            options[i].isSelected = (i == index)
        }
    }
}
