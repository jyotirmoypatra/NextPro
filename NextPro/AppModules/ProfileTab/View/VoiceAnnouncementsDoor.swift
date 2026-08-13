//
//  VoiceAnnouncementsDoor.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 11/12/25.
//


import SwiftUI
import Foundation

struct MessageOption: Identifiable {
    let id = UUID()
    let text: String
    var isSelected: Bool
}

struct VoiceMessageDefaults {
    
    static let granted: [MessageOption] = [
        MessageOption(text: "Access Granted", isSelected: true),
        MessageOption(text: "Entry Approved", isSelected: false),
        MessageOption(text: "Access successfully verified", isSelected: false),
        MessageOption(text: "Door Unlocked", isSelected: false),
        MessageOption(text: "Access Confirmed", isSelected: false)
    ]
    
    static let denied: [MessageOption] = [
        MessageOption(text: "Access Denied", isSelected: true),
        MessageOption(text: "Entry Rejected", isSelected: false),
        MessageOption(text: "Access Not Permitted", isSelected: false),
        MessageOption(text: "Door Locked", isSelected: false),
        MessageOption(text: "Authorization Failed", isSelected: false)
    ]
    
    static let unauthorized: [MessageOption] = [
        MessageOption(text: "You do not have access to this door", isSelected: true),
        MessageOption(text: "Unauthorized door", isSelected: false),
        MessageOption(text: "This entry is restricted", isSelected: false),
        MessageOption(text: "Access not allowed at this location", isSelected: false),
        MessageOption(text: "Invalid door access attempt", isSelected: false)
    ]
    
    static let greetings: [MessageOption] = [
        MessageOption(text: "Welcome! Have a great day", isSelected: true),
        MessageOption(text: "Glad to have you here", isSelected: false),
        MessageOption(text: "Welcome! Enjoy your time", isSelected: false),
        MessageOption(text: "Welcome, wishing you a wonderful day ahead.", isSelected: false),
        MessageOption(text: "Welcome! Your presence is appreciated", isSelected: false)
    ]
}


struct VoiceAnnouncementsDoor: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    @State private var showSaved = false
    @State private var openSection: Int? = nil
    
    
    @State private var grantedOptions = VoiceMessageDefaults.granted
    @State private var deniedOptions = VoiceMessageDefaults.denied
    @State private var unauthorizedOptions = VoiceMessageDefaults.unauthorized
    @State private var greetingOptions = VoiceMessageDefaults.greetings
    @State private var isVoiceAnnouncementEnabled = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Full-screen semi-transparent background
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack{
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Spacer()
                        
                        Text("Voice Messages")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal,10)
                    .padding(.top, 10)
                //    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(111)
                    
                    Text("Control and personalize the voice announcements that play during different door access scenarios.")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal,15)
                        .padding(.bottom,5)
                        .padding(.top,2)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Voice Announcements")
                                .font(.custom("Inter-SemiBold", size: 15))
                                .foregroundColor(.white)

                            Text("Play voice messages during door access events.")
                                .font(.custom("Inter-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.55))
                        }

                        Spacer()

                        Toggle("", isOn: $isVoiceAnnouncementEnabled)
                            .labelsHidden()
                            .tint(.green)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                    
                    VStack {
                        
                        ScrollViewReader { proxy in
                            
                            ScrollView {
                                VStack(spacing: 22) {
                                    
                                    
                                    // MARK: 1 - Access Granted
                                    MessageSection(
                                        id: 0,
                                        title: "Access Granted",
                                        description: "This message played when door opens successfully.",
                                        options: $grantedOptions,
                                        openSection: $openSection
                                    )
                                    .id(0)
                                    Divider()
                                        .overlay(Color.white.opacity(0.08))
                                    
                                    // MARK: 2 - Access Denied
                                    MessageSection(
                                        id: 1,
                                        title: "Access Denied",
                                        description: "This message played when door access failed.",
                                        options: $deniedOptions,
                                        openSection: $openSection
                                        
                                    )
                                    .id(1)
                                    
                                    Divider()
                                        .overlay(Color.white.opacity(0.08))
                                    
                                    // MARK: 3 - Unauthorized
                                    MessageSection(
                                        id: 4,
                                        title: "Unauthorized Door",
                                        description: "This message played when approaching an unauthorized door.",
                                        options: $unauthorizedOptions,
                                        openSection: $openSection
                                        
                                    )
                                    .id(4)
                                    
                                    Divider()
                                        .overlay(Color.white.opacity(0.8))
                                    
                                    // MARK: 3 -  Friendly Welcome
                                    MessageSection(
                                        id: 2,
                                        title: "Friendly Welcome",
                                        description: "Greeting played after successfull access",
                                        options: $greetingOptions,
                                        openSection: $openSection
                                        
                                    )
                                    .id(2)
                                    
                                    Spacer().frame(height: 20)
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
                            
                            //  THIS IS THE MAGIC LINE
                               .onChange(of: openSection) { id in
                                   guard let id else { return }

                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                       withAnimation(.easeInOut) {
                                           proxy.scrollTo(id, anchor: .top)
                                       }
                                   }
                               }
                        }
                        
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "bell")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    
                                Text("Playback Pattern")
                                    .font(.custom("Inter-SemiBold", size: 14))
                                    .foregroundColor(.white)
                                Spacer()
                            } .padding(.horizontal,10)
                                .padding(.top,5)
                            
                            HStack{
                                Text("Door Name")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.55))
                                
                                Text("->")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.55))
                                
                                Text("Access granted message")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.55))
                                
                                Text("->")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.55))
                                
                                Text("Friendly greeting message ")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.55))
                               
                            }
                            .padding(.horizontal,10)
                            .padding(.bottom,5)
                            
                            
                        }.overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.vertical,10)
                        
                        HStack(spacing: 12) {

                            // RESET (Wider)
                            Button(action: {
                                ResetMessages()
                            }) {
                                Text("RESET TO DEFAULTS")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .padding(.horizontal, 10)
                                    .background(Color.white.opacity(0.03))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            .layoutPriority(1)   // ⭐ Gives RESET more width


                            // SAVE (Smaller)
                            Button(action: {
                                saveMessages()
                            }) {
                                Text("SAVE")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(minWidth: 80, minHeight: 50) // smaller fixed width
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        

                        
                    }.padding(.horizontal, 10)
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
        
        isVoiceAnnouncementEnabled = UserDefaults.standard.object(forKey: "voice_announcement_enabled" ) as? Bool ?? true
    }
    
    func saveMessages() {
        let granted = grantedOptions.first(where: { $0.isSelected })?.text
        let denied = deniedOptions.first(where: { $0.isSelected })?.text
        let unauthorized = unauthorizedOptions.first(where: { $0.isSelected })?.text
        let greeting = greetingOptions.first(where: { $0.isSelected })?.text
        
        UserDefaults.standard.set(granted, forKey: "voice_granted")
        UserDefaults.standard.set(denied, forKey: "voice_denied")
        UserDefaults.standard.set(unauthorized, forKey: "voice_unauthorized")
        UserDefaults.standard.set(greeting, forKey: "voice_greeting")
        
        UserDefaults.standard.set(isVoiceAnnouncementEnabled,forKey: "voice_announcement_enabled")
        
        toastManager.show(
            message: "Saved successfully",
            type: .success,
            duration: 1.5
        )
    }
    
    func ResetMessages() {
        // Get default first items
        let defaultGranted = VoiceMessageDefaults.granted.first!.text
        let defaultDenied = VoiceMessageDefaults.denied.first!.text
        let defaultUnauthorized = VoiceMessageDefaults.unauthorized.first!.text
        let defaultGreeting = VoiceMessageDefaults.greetings.first!.text
        
        // Reset options arrays
        grantedOptions = VoiceMessageDefaults.granted.map { MessageOption(text: $0.text, isSelected: $0.text == defaultGranted) }
        deniedOptions = VoiceMessageDefaults.denied.map { MessageOption(text: $0.text, isSelected: $0.text == defaultDenied) }
        unauthorizedOptions = VoiceMessageDefaults.unauthorized.map { MessageOption(text: $0.text, isSelected: $0.text == defaultUnauthorized) }
        greetingOptions = VoiceMessageDefaults.greetings.map { MessageOption(text: $0.text, isSelected: $0.text == defaultGreeting) }
        
        // Update UserDefaults
        UserDefaults.standard.set(defaultGranted, forKey: "voice_granted")
        UserDefaults.standard.set(defaultDenied, forKey: "voice_denied")
        UserDefaults.standard.set(defaultUnauthorized, forKey: "voice_unauthorized")
        UserDefaults.standard.set(defaultGreeting, forKey: "voice_greeting")
        
        isVoiceAnnouncementEnabled = true

        UserDefaults.standard.set(true,forKey: "voice_announcement_enabled")
        
        // Show toast
        toastManager.show(
            message: "Successfully reset to defaults",
            type: .success,
            duration: 1.5
        )
    }
    
    
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
                        .multilineTextAlignment(.leading)
                    
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
                                    .multilineTextAlignment(.leading)
                                
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
