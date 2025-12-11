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
    @State private var openSection: Int? = nil

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
                    
                    Text("Control and personalize the voice announcements that play during different door access scenarios.")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal,10)
                        .multilineTextAlignment(.center)
                    
                    
                    ScrollView {
                        VStack(spacing: 22) {
                            
                            
                            // MARK: 1 - Access Granted
                            MessageSection(
                                id: 0,
                                title: "Access Granted",
                                description: "This message plays when entry is successfully approved.",
                                options: $grantedOptions,
                                openSection: $openSection
                            )
                            
                            // MARK: 2 - Access Denied
                            MessageSection(
                                id: 1,
                                title: "Access Denied",
                                description: "This message plays when the door cannot approve the request.",
                                options: $deniedOptions,
                                openSection: $openSection
                            )
                            
                            // MARK: 3 - Unauthorized
                            MessageSection(
                                id: 2,
                                title: "Unauthorized",
                                description: "This message plays when an unregistered user tries to open the door.",
                                options: $unauthorizedOptions,
                                openSection: $openSection
                            )
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.horizontal, 16)
                        
                    }
                    .padding(.top, 15)
                    .scrollIndicators(.hidden)
                    
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
                                              .background(Color.white)
                                              .clipShape(RoundedRectangle(cornerRadius: 14))
                                      }
                                      .padding(.horizontal, 16)
                                      .padding(.bottom, 25)
                                  }
                }
            }
            .onAppear {
                loadSavedSelections()
            }

        }
    }
    
    func loadSavedSelections() {
        let savedGranted = UserDefaults.standard.string(forKey: "voice_granted")
        let savedDenied = UserDefaults.standard.string(forKey: "voice_denied")
        let savedUnauthorized = UserDefaults.standard.string(forKey: "voice_unauthorized")

        if let savedGranted {
            for i in grantedOptions.indices {
                grantedOptions[i].isSelected = (grantedOptions[i].text == savedGranted)
            }
        }

        if let savedDenied {
            for i in deniedOptions.indices {
                deniedOptions[i].isSelected = (deniedOptions[i].text == savedDenied)
            }
        }

        if let savedUnauthorized {
            for i in unauthorizedOptions.indices {
                unauthorizedOptions[i].isSelected = (unauthorizedOptions[i].text == savedUnauthorized)
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




struct MessageSection: View {
    let id: Int
    let title: String
    let description: String
    @Binding var options: [MessageOption]

    @Binding var openSection: Int?

    private var isExpanded: Bool {
        openSection == id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // HEADER
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    // If already open → close it
                    if openSection == id {
                        openSection = nil
                    } else {
                        openSection = id
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)

                        Text(description)
                            .font(.custom("Inter-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.55))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, 12)
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // CONTENT
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { index in
                        Button {
                            selectOption(at: index)
                        } label: {
                            HStack(spacing: 12) {

                                Image(systemName: options[index].isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(options[index].isSelected ? .green : .gray.opacity(0.6))
                                    .animation(.spring(), value: options[index].isSelected)

                                Text(options[index].text)
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                            .background(
                                options[index].isSelected
                                ? Color.white.opacity(0.06)
                                : Color.clear
                            )
                        }
                    }
                }
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 5, y: 4)
                // Replace your transition with this
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)

            }
        }
        .padding(.vertical, 4)
    }

    private func selectOption(at index: Int) {
        for i in options.indices {
            options[i].isSelected = (i == index)
        }
    }
}
