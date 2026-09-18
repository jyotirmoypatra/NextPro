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
    var isCustom: Bool = false
}
private enum VoiceMessageCustomKeys {
    static let granted = "voice_granted_custom"
    static let denied = "voice_denied_custom"
    static let unauthorized = "voice_unauthorized_custom"
    static let greeting = "voice_greeting_custom"
}

struct VoiceMessageDefaults {
    
    static let granted: [MessageOption] = [
        MessageOption(text: "Access Granted", isSelected: true),
        MessageOption(text: "Entry Approved", isSelected: false),
        MessageOption(text: "Door Unlocked", isSelected: false),
    ]
    
    static let denied: [MessageOption] = [
        MessageOption(text: "Access Denied", isSelected: true),
        MessageOption(text: "Entry Rejected", isSelected: false),
        MessageOption(text: "Access Not Permitted", isSelected: false),
    ]
    
    static let unauthorized: [MessageOption] = [
        MessageOption(text: "You do not have access to this door", isSelected: true),
        MessageOption(text: "Unauthorized door", isSelected: false),
        MessageOption(text: "This entry is restricted", isSelected: false),
    ]
    
    static let greetings: [MessageOption] = [
        MessageOption(text: "Welcome! Have a great day", isSelected: true),
        MessageOption(text: "Glad to have you here", isSelected: false),
        MessageOption(text: "Welcome! Enjoy your time", isSelected: false),
    ]
}

/// Which spoken pattern plays after a successful door open — either the access-granted
/// message alone, or followed by the friendly greeting. Shared with `DoorOpenView`,
/// which reads `storageKey` to decide what to speak.
enum VoicePlaybackPattern: String {
    case withGreeting
    case grantedOnly

    static let storageKey = "voice_playback_pattern"

    static var saved: VoicePlaybackPattern {
        VoicePlaybackPattern(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .withGreeting
    }

    var steps: [String] {
        switch self {
        case .withGreeting: return ["Door Name", "Access granted message", "Friendly greeting message"]
        case .grantedOnly: return ["Door Name", "Access granted message"]
        }
    }
}

private struct PendingDelete: Identifiable {
    let option: MessageOption
    let sectionId: Int
    let categoryTitle: String
    var id: UUID { option.id }
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
    @State private var pendingDelete: PendingDelete?
    @State private var selectedPlaybackPattern: VoicePlaybackPattern = .withGreeting
    
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
            
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }

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
                            .font(.custom("Inter-SemiBold", size: 16))
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
                            .onChange(of: isVoiceAnnouncementEnabled) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "voice_announcement_enabled")
                            }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                    
                   
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 22) {


                                // MARK: 1 - Access Granted
                                MessageSection(
                                    id: 0,
                                    title: "Access Granted",
                                    description: "This message played when door opens successfully.",
                                    options: $grantedOptions,
                                    openSection: $openSection,
                                    onAddCustom: { addCustomMessage($0, options: $grantedOptions, customKey: VoiceMessageCustomKeys.granted) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 0, categoryTitle: "Access Granted") }
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
                                    openSection: $openSection,
                                    onAddCustom: { addCustomMessage($0, options: $deniedOptions, customKey: VoiceMessageCustomKeys.denied) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 1, categoryTitle: "Access Denied") }

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
                                    openSection: $openSection,
                                    onAddCustom: { addCustomMessage($0, options: $unauthorizedOptions, customKey: VoiceMessageCustomKeys.unauthorized) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 4, categoryTitle: "Unauthorized Door") }

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
                                    openSection: $openSection,
                                    onAddCustom: { addCustomMessage($0, options: $greetingOptions, customKey: VoiceMessageCustomKeys.greeting) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 2, categoryTitle: "Friendly Welcome") }

                                )
                                .id(2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)

                            Divider()
                                .overlay(Color.white.opacity(0.15))
                                .padding(.vertical, 6)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Choose Playback Pattern")
                                    .font(.custom("Inter-SemiBold", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 2)

                                PlaybackPatternCard(
                                    title: "Access message + Greeting",
                                    steps: VoicePlaybackPattern.withGreeting.steps,
                                    isSelected: selectedPlaybackPattern == .withGreeting,
                                    onSelect: { selectedPlaybackPattern = .withGreeting }
                                )

                                PlaybackPatternCard(
                                    title: "Access message only",
                                    steps: VoicePlaybackPattern.grantedOnly.steps,
                                    isSelected: selectedPlaybackPattern == .grantedOnly,
                                    onSelect: { selectedPlaybackPattern = .grantedOnly }
                                )
                            }
                            .padding(.vertical, 10)

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

                            Spacer().frame(height: 20)
                        }
                        .padding(.horizontal, 10)
                        .scrollIndicators(.hidden)
                        // `simultaneousGesture` so this fires alongside row/button taps
                        // instead of stealing them — lets tapping empty space in the
                        // scroll content dismiss the keyboard too.
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                UIApplication.shared.hideKeyboard()
                            }
                        )

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
                }

            }
            .onAppear {
                loadSavedSelections()
            }
            .toast()
           
            .modernAlert(item: $pendingDelete) { pending in
                ModernAlertView(
                    title: "Delete Message?",
                    message: "Delete “\(pending.option.text)” from \(pending.categoryTitle) list?",
                    isSuccess: false,
                    buttonTitle: "Delete",
                    action: {
                        confirmDelete(pending)
                        pendingDelete = nil
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryAction: { pendingDelete = nil }
                )
            }

        }

    }

    private func confirmDelete(_ pending: PendingDelete) {
        switch pending.sectionId {
        case 0:
            deleteCustomMessage(pending.option, options: $grantedOptions, customKey: VoiceMessageCustomKeys.granted)
        case 1:
            deleteCustomMessage(pending.option, options: $deniedOptions, customKey: VoiceMessageCustomKeys.denied)
        case 4:
            deleteCustomMessage(pending.option, options: $unauthorizedOptions, customKey: VoiceMessageCustomKeys.unauthorized)
        case 2:
            deleteCustomMessage(pending.option, options: $greetingOptions, customKey: VoiceMessageCustomKeys.greeting)
        default:
            break
        }
    }
    
    func loadSavedSelections() {
        grantedOptions = optionsList(defaults: VoiceMessageDefaults.granted, customKey: VoiceMessageCustomKeys.granted)
        deniedOptions = optionsList(defaults: VoiceMessageDefaults.denied, customKey: VoiceMessageCustomKeys.denied)
        unauthorizedOptions = optionsList(defaults: VoiceMessageDefaults.unauthorized, customKey: VoiceMessageCustomKeys.unauthorized)
        greetingOptions = optionsList(defaults: VoiceMessageDefaults.greetings, customKey: VoiceMessageCustomKeys.greeting)

        applySavedSelection(&grantedOptions, savedText: UserDefaults.standard.string(forKey: "voice_granted"))
        applySavedSelection(&deniedOptions, savedText: UserDefaults.standard.string(forKey: "voice_denied"))
        applySavedSelection(&unauthorizedOptions, savedText: UserDefaults.standard.string(forKey: "voice_unauthorized"))
        applySavedSelection(&greetingOptions, savedText: UserDefaults.standard.string(forKey: "voice_greeting"))

        isVoiceAnnouncementEnabled = UserDefaults.standard.object(forKey: "voice_announcement_enabled" ) as? Bool ?? true
        selectedPlaybackPattern = VoicePlaybackPattern.saved
    }

    private func optionsList(defaults: [MessageOption], customKey: String) -> [MessageOption] {
        let customTexts = UserDefaults.standard.stringArray(forKey: customKey) ?? []
        return defaults + customTexts.map { MessageOption(text: $0, isSelected: false, isCustom: true) }
    }

    private func applySavedSelection(_ options: inout [MessageOption], savedText: String?) {
        guard let savedText else { return }
        for i in options.indices {
            options[i].isSelected = (options[i].text == savedText)
        }
    }

    private func addCustomMessage(_ text: String, options: Binding<[MessageOption]>, customKey: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard !options.wrappedValue.contains(where: { $0.text.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            toastManager.show(message: "This message already exists", type: .error, duration: 1.5)
            return
        }

        options.wrappedValue.append(MessageOption(text: trimmed, isSelected: false, isCustom: true))
        persistCustomMessages(options.wrappedValue, key: customKey)
        toastManager.show(message: "Message added", type: .success, duration: 1.2)
    }

    private func deleteCustomMessage(_ option: MessageOption, options: Binding<[MessageOption]>, customKey: String) {
        guard option.isCustom else { return }

        let wasSelected = option.isSelected
        options.wrappedValue.removeAll { $0.id == option.id }

        if wasSelected, !options.wrappedValue.isEmpty {
            for i in options.wrappedValue.indices {
                options.wrappedValue[i].isSelected = (i == 0)
            }
        }

        persistCustomMessages(options.wrappedValue, key: customKey)
    }

    private func persistCustomMessages(_ options: [MessageOption], key: String) {
        let customTexts = options.filter { $0.isCustom }.map { $0.text }
        UserDefaults.standard.set(customTexts, forKey: key)
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
        UserDefaults.standard.set(selectedPlaybackPattern.rawValue, forKey: VoicePlaybackPattern.storageKey)

        toastManager.show(
            message: "Saved successfully",
            type: .success,
            duration: 1.5
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    func ResetMessages() {
        // Get default first items
        let defaultGranted = VoiceMessageDefaults.granted.first!.text
        let defaultDenied = VoiceMessageDefaults.denied.first!.text
        let defaultUnauthorized = VoiceMessageDefaults.unauthorized.first!.text
        let defaultGreeting = VoiceMessageDefaults.greetings.first!.text

        grantedOptions = grantedOptions.map { MessageOption(text: $0.text, isSelected: $0.text == defaultGranted, isCustom: $0.isCustom) }
        deniedOptions = deniedOptions.map { MessageOption(text: $0.text, isSelected: $0.text == defaultDenied, isCustom: $0.isCustom) }
        unauthorizedOptions = unauthorizedOptions.map { MessageOption(text: $0.text, isSelected: $0.text == defaultUnauthorized, isCustom: $0.isCustom) }
        greetingOptions = greetingOptions.map { MessageOption(text: $0.text, isSelected: $0.text == defaultGreeting, isCustom: $0.isCustom) }
        
        // Update UserDefaults
        UserDefaults.standard.set(defaultGranted, forKey: "voice_granted")
        UserDefaults.standard.set(defaultDenied, forKey: "voice_denied")
        UserDefaults.standard.set(defaultUnauthorized, forKey: "voice_unauthorized")
        UserDefaults.standard.set(defaultGreeting, forKey: "voice_greeting")
        
        isVoiceAnnouncementEnabled = true
        selectedPlaybackPattern = .withGreeting

        UserDefaults.standard.set(true,forKey: "voice_announcement_enabled")
        UserDefaults.standard.set(VoicePlaybackPattern.withGreeting.rawValue, forKey: VoicePlaybackPattern.storageKey)

        // Show toast
        toastManager.show(
            message: "Successfully reset to defaults",
            type: .success,
            duration: 1.5
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
    
    
}




/// One selectable "Playback Pattern" card — shows the message chain as
/// `Door Name -> ... -> ...` with a radio button reflecting selection.
private struct PlaybackPatternCard: View {
    let title: String
    let steps: [String]
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(.white)

                    Text(steps.joined(separator: "  ›  "))
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .padding(14)
            .frame(height: 74, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.white.opacity(0.08) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MessageSection: View {
    let id: Int
    let title: String
    let description: String
    @Binding var options: [MessageOption]
    @Binding var openSection: Int?
    var onAddCustom: (String) -> Void
    var onRequestDelete: (MessageOption) -> Void

    @State private var newMessageText = ""

    private let maxMessageLength = 30

    private var isOpen: Bool {
        openSection == id
    }

    var selectedText: String {
        options.first(where: { $0.isSelected })?.text ?? ""
    }

    private var trimmedNewMessage: String {
        newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var remainingCharacters: Int {
        maxMessageLength - newMessageText.count
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
                        HStack(spacing: 10) {
                            Button {
                                select(idx)
                            } label: {
                                HStack {
                                    Text(options[idx].text)
                                        .foregroundColor(.white)
                                        .font(.custom("Inter-Regular", size: 14))
                                        .multilineTextAlignment(.leading)

                                    if options[idx].isCustom {
                                        Text("Custom")
                                            .font(.custom("Inter-Regular", size: 9))
                                            .foregroundColor(.white.opacity(0.65))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.12))
                                            .clipShape(Capsule())
                                    }

                                    Spacer()

                                    if options[idx].isSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            // Only ever shown for a user-added message — presets can
                            // never be deleted.
                            if options[idx].isCustom {
                                Button {
                                    onRequestDelete(options[idx])
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13))
                                        .foregroundColor(.red.opacity(0.85))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        //  .background(idx % 2 == 0 ? Color.white.opacity(0.03) : Color.white.opacity(0.05))

                        Divider()
                            .overlay(Color.white.opacity(0.08))
                    }

                    // Add-your-own-message row
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.bubble")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))

                            TextField("", text: $newMessageText, prompt: Text("Add your own message...").foregroundColor(.white.opacity(0.4)))
                                .foregroundColor(.white)
                                .font(.custom("Inter-Regular", size: 14))
                                .submitLabel(.done)
                                .onSubmit(addCustomMessage)
                                .onChange(of: newMessageText) { newValue in
                        
                                    if newValue.count > maxMessageLength {
                                        newMessageText = String(newValue.prefix(maxMessageLength))
                                    }
                                }

                            Button(action: addCustomMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(trimmedNewMessage.isEmpty ? .white.opacity(0.25) : .green)
                            }
                            .disabled(trimmedNewMessage.isEmpty)
                        }

                        Text("\(remainingCharacters) characters left")
                            .font(.custom("Inter-Regular", size: 11))
                            .foregroundColor(remainingCharacters <= 10 ? .orange : .white.opacity(0.4))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
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

    private func addCustomMessage() {
        guard !trimmedNewMessage.isEmpty else { return }
        onAddCustom(trimmedNewMessage)
        newMessageText = ""
        UIApplication.shared.hideKeyboard()
    }
}
