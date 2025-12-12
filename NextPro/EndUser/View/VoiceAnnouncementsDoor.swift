//
//  VoiceAnnouncementsDoor.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/12/25.
//


import SwiftUI

struct VoiceAnnouncementsDoor: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    @State private var showSaved = false
    @State private var openSection: Int? = nil

    @State private var grantedOptions = [
        MessageOption(text: "Access Granted", isSelected: true),
        MessageOption(text: "Entry Approved", isSelected: false),
        MessageOption(text: "Access successfully verified", isSelected: false),
        MessageOption(text: "Door Unlocked", isSelected: false),
        MessageOption(text: "Access Confirmed", isSelected: false)
    ]
    
    @State private var deniedOptions = [
        MessageOption(text: "Access Denied", isSelected: true),
        MessageOption(text: "Entry Rejected", isSelected: false),
        MessageOption(text: "Access Not Permitted", isSelected: false),
        MessageOption(text: "Door Locked", isSelected: false),
        MessageOption(text: "Authorization Failed", isSelected: false)
    ]
    
    @State private var unauthorizedOptions = [
        MessageOption(text: "You do not have access to this door", isSelected: true),
        MessageOption(text: "Unauthorized door", isSelected: false),
        MessageOption(text: "This entry is restricted", isSelected: false),
        MessageOption(text: "Access not allowed at this location", isSelected: false),
        MessageOption(text: "Invalid door access attempt", isSelected: false)
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
                    
                    VStack {
                        
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
                                
                                Divider()
                                    .overlay(Color.white.opacity(0.08))
                                
                                // MARK: 2 - Access Denied
                                MessageSection(
                                    id: 1,
                                    title: "Access Denied",
                                    description: "This message plays when the door cannot approve the request.",
                                    options: $deniedOptions,
                                    openSection: $openSection
                                    
                                )
                                
                                Divider()
                                    .overlay(Color.white.opacity(0.08))
                                
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack {
    
                            Button(action: {
                                saveMessages()
                            }) {
                                Text("SAVE")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                         
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            
                            Button(action: {
                                //saveMessages()
                            }) {
                                Text("RESET TO DEFAULTS")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                    )
                            }
                       
                            .padding(.bottom, 10)
                        }
                        
                    }.padding(.horizontal, 20)
                }
                
            }
            .onAppear {
                loadSavedSelections()
            }
            .toast()

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
            
        
        toastManager.show(
            message: "Saved successfully",
            type: .success,
            duration: 1.0
        )
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

    private var isOpen: Bool {
        openSection == id
    }

    var selectedText: String {
        options.first(where: { $0.isSelected })?.text ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(.white)

            Text(description)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(.white.opacity(0.55))

            // Dropdown button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    openSection = isOpen ? nil : id
                }
            } label: {
                HStack {
                    Text(selectedText)
                        .foregroundColor(.white)
                        .font(.custom("Inter-Regular", size: 14))

                    Spacer()

                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if isOpen {
                VStack(spacing: 0) {
                    ForEach(options.indices, id: \.self) { idx in
                        Button {
                            select(idx)
                        } label: {
                            HStack {
                                Text(options[idx].text)
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Regular", size: 14))

                                Spacer()

                                if options[idx].isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                        }
                      //  .background(idx % 2 == 0 ? Color.white.opacity(0.03) : Color.white.opacity(0.05))

                        if idx != options.count - 1 {
                            Divider()
                                .overlay(Color.white.opacity(0.08))
                              //  .padding(.leading, 12)
                        }
                    }
                }
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity)
                .padding(.top,-9)
            }
                
        }
        
    }

    private func select(_ index: Int) {
        for i in options.indices {
            options[i].isSelected = (i == index)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            openSection = nil
        }
    }
}
