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
    var serverId: String? = nil
}
private enum VoiceMessageCustomKeys {
    static let granted = "voice_granted_custom"
    static let denied = "voice_denied_custom"
    static let unauthorized = "voice_unauthorized_custom"
    static let greeting = "voice_greeting_custom"
}

private enum VoiceMessageCategory: String {
    case accessGranted = "access_granted"
    case accessDenied = "access_denied"
    case accessUnauthorized = "access_unauthorized"
    case welcome = "welcome"

    var sectionId: Int {
        switch self {
        case .accessGranted: return 0
        case .accessDenied: return 1
        case .accessUnauthorized: return 4
        case .welcome: return 2
        }
    }

    var title: String {
        switch self {
        case .accessGranted: return "Access Granted"
        case .accessDenied: return "Access Denied"
        case .accessUnauthorized: return "Unauthorized Door"
        case .welcome: return "Friendly Welcome"
        }
    }
}

enum VoicePlaybackPattern: String {
    case withGreeting
    case grantedOnly

    static let storageKey = "voice_playback_pattern"

    static var saved: VoicePlaybackPattern {
        VoicePlaybackPattern(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .withGreeting
    }

    init?(apiType: String?) {
        guard let apiType, !apiType.isEmpty else { return nil }
        let lower = apiType.lowercased()
        if lower.contains("greet") || lower.contains("welcome") {
            self = .withGreeting
        } else {
            self = .grantedOnly
        }
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
  
    @ObservedObject var profileViewModel: UserProfileDetailsViewModel
    private var voiceMessage: VoiceMessage? { profileViewModel.voiceMessage }
    @Environment(\.dismiss) private var dismiss
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var addMessageVM = AddNewVoiceMessageViewModel()
    @StateObject private var deleteMessageVM = DeleteCustomVoiceViewModel()
    @StateObject private var saveVoicePreferenceVM = SaveVoicePreferenceViewModel()
    @State private var showSaved = false
    @State private var openSection: Int? = nil


    @State private var grantedOptions: [MessageOption] = []
    @State private var deniedOptions: [MessageOption] = []
    @State private var unauthorizedOptions: [MessageOption] = []
    @State private var greetingOptions: [MessageOption] = []
    
    @State private var isGrantedVoiceEnabled = true
    @State private var isDeniedVoiceEnabled = true
    @State private var isUnauthorizedVoiceEnabled = true
    @State private var isGreetingVoiceEnabled = true
    
    @State private var pendingDelete: PendingDelete?
    @State private var deletingOptionId: UUID?

    @State private var isResetting = false
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
                                .frame(width: 44, height: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

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
                                    isVoiceEnabled: $isGrantedVoiceEnabled,
                                    isAdding: addMessageVM.isLoading,
                                    deletingOptionId: deletingOptionId,
                                    onAddCustom: { addCustomMessage($0, options: $grantedOptions, customKey: VoiceMessageCustomKeys.granted, category: .accessGranted) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 0, categoryTitle: "Access Granted") }
                                )
                                .id(0)

                                // MARK: 2 - Access Denied
                                MessageSection(
                                    id: 1,
                                    title: "Access Denied",
                                    description: "This message played when door access failed.",
                                    options: $deniedOptions,
                                    openSection: $openSection,
                                    isVoiceEnabled: $isDeniedVoiceEnabled,
                                    isAdding: addMessageVM.isLoading,
                                    deletingOptionId: deletingOptionId,
                                    onAddCustom: { addCustomMessage($0, options: $deniedOptions, customKey: VoiceMessageCustomKeys.denied, category: .accessDenied) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 1, categoryTitle: "Access Denied") }

                                )
                                .id(1)


                                // MARK: 3 - Unauthorized
                                MessageSection(
                                    id: 4,
                                    title: "Unauthorized Door",
                                    description: "This message played when approaching an unauthorized door.",
                                    options: $unauthorizedOptions,
                                    openSection: $openSection,
                                    isVoiceEnabled: $isUnauthorizedVoiceEnabled,
                                    isAdding: addMessageVM.isLoading,
                                    deletingOptionId: deletingOptionId,
                                    onAddCustom: { addCustomMessage($0, options: $unauthorizedOptions, customKey: VoiceMessageCustomKeys.unauthorized, category: .accessUnauthorized) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 4, categoryTitle: "Unauthorized Door") }

                                )
                                .id(4)


                                // MARK: 3 -  Friendly Welcome
                                MessageSection(
                                    id: 2,
                                    title: "Friendly Welcome",
                                    description: "Greeting played after successfull access",
                                    options: $greetingOptions,
                                    openSection: $openSection,
                                    isVoiceEnabled: $isGreetingVoiceEnabled,
                                    isAdding: addMessageVM.isLoading,
                                    deletingOptionId: deletingOptionId,
                                    onAddCustom: { addCustomMessage($0, options: $greetingOptions, customKey: VoiceMessageCustomKeys.greeting, category: .welcome) },
                                    onRequestDelete: { pendingDelete = PendingDelete(option: $0, sectionId: 2, categoryTitle: "Friendly Welcome") }

                                )
                                .id(2)
                            }
                            .padding(.vertical, 15)

                            Divider()
                                .overlay(Color.white.opacity(0.15))
                                .padding(.vertical, 6)

                            HStack(spacing: 12) {

                                // RESET (Wider)
                                Button(action: {
                                    ResetMessages()
                                }) {
                                    Group {
                                        if isResetting {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        } else {
                                            Text("RESET TO DEFAULTS")
                                                .font(.custom("Inter-SemiBold", size: 16))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .padding(.horizontal, 10)
                                    .background(Color.white.opacity(0.03))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                }
                                .disabled(saveVoicePreferenceVM.isLoading)
                                .layoutPriority(1)   // ⭐ Gives RESET more width


                                // SAVE (Smaller)
                                Button(action: {
                                    saveMessages()
                                }) {
                                    Group {
                                        if saveVoicePreferenceVM.isLoading && !isResetting {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        } else {
                                            Text("SAVE")
                                                .font(.custom("Inter-SemiBold", size: 16))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    .frame(minWidth: 80, minHeight: 50) // smaller fixed width
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(saveVoicePreferenceVM.isLoading)
                            }

                            Spacer().frame(height: 20)
                        }
                        .padding(.horizontal, 10)
                        .scrollIndicators(.hidden)
                        
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
            // Each section's toggle lives in MessageSection now, so its persistence
            // side effect lives here instead of on a single top-level Toggle view —
            // each one is independent, with its own UserDefaults key.
            .onChange(of: isGrantedVoiceEnabled) { newValue in
                UserDefaults.standard.set(newValue, forKey: "voice_enabled_granted")
            }
            .onChange(of: isDeniedVoiceEnabled) { newValue in
                UserDefaults.standard.set(newValue, forKey: "voice_enabled_denied")
            }
            .onChange(of: isUnauthorizedVoiceEnabled) { newValue in
                UserDefaults.standard.set(newValue, forKey: "voice_enabled_unauthorized")
            }
            .onChange(of: isGreetingVoiceEnabled) { newValue in
                UserDefaults.standard.set(newValue, forKey: "voice_enabled_greeting")
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
        deletingOptionId = pending.option.id

        print("🗑️ Deleting voice message — text: \"\(pending.option.text)\", serverId: \(pending.option.serverId ?? "nil")")

        func removeLocally() {
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

        // No serverId means this entry only ever existed locally (e.g. cached before
        // the add flow started syncing back a real id) — there's nothing for the
        // delete API to remove, so just drop it from this device.
        guard let serverId = pending.option.serverId else {
            removeLocally()
            toastManager.show(message: "Message removed", type: .success, duration: 1.2)
            deletingOptionId = nil
            return
        }

        Task {
            await deleteMessageVM.deleteMessage(messageID: serverId)

            if deleteMessageVM.addSuccess {
                removeLocally()
                toastManager.show(message: "Message deleted", type: .success, duration: 1.2)
            } else {
                let failureMessage = deleteMessageVM.errorMessage.isEmpty
                    ? "Failed to delete message"
                    : deleteMessageVM.errorMessage
                toastManager.show(message: failureMessage, type: .error, duration: 1.5)
            }

            deletingOptionId = nil
        }
    }
    
    func loadSavedSelections() {
        grantedOptions = optionsList(serverOptions: voiceMessage?.access_granted, customKey: VoiceMessageCustomKeys.granted)
        deniedOptions = optionsList(serverOptions: voiceMessage?.access_denied, customKey: VoiceMessageCustomKeys.denied)
        unauthorizedOptions = optionsList(serverOptions: voiceMessage?.access_unauthorized, customKey: VoiceMessageCustomKeys.unauthorized)
        greetingOptions = optionsList(serverOptions: voiceMessage?.welcome, customKey: VoiceMessageCustomKeys.greeting)

        applySavedSelection(&grantedOptions, savedText: UserDefaults.standard.string(forKey: "voice_granted"))
        applySavedSelection(&deniedOptions, savedText: UserDefaults.standard.string(forKey: "voice_denied"))
        applySavedSelection(&unauthorizedOptions, savedText: UserDefaults.standard.string(forKey: "voice_unauthorized"))
        applySavedSelection(&greetingOptions, savedText: UserDefaults.standard.string(forKey: "voice_greeting"))

        ensureAtLeastOneSelected(&grantedOptions)
        ensureAtLeastOneSelected(&deniedOptions)
        ensureAtLeastOneSelected(&unauthorizedOptions)
        ensureAtLeastOneSelected(&greetingOptions)


        // Each section's toggle starts from its own locally-saved value if present
        // (the user already flipped it independently on this device), otherwise
        // falls back to that category's own `is_voice_active_*` flag from the server.
        isGrantedVoiceEnabled = UserDefaults.standard.object(forKey: "voice_enabled_granted") as? Bool
            ?? (voiceMessage?.is_voice_active_granted ?? true)
        isDeniedVoiceEnabled = UserDefaults.standard.object(forKey: "voice_enabled_denied") as? Bool
            ?? (voiceMessage?.is_voice_active_denied ?? true)
        isUnauthorizedVoiceEnabled = UserDefaults.standard.object(forKey: "voice_enabled_unauthorized") as? Bool
            ?? (voiceMessage?.is_voice_active_unauthorized ?? true)
        isGreetingVoiceEnabled = UserDefaults.standard.object(forKey: "voice_enabled_greeting") as? Bool
            ?? (voiceMessage?.is_voice_active_welcome ?? true)

        // The server no longer has a separate playback-pattern list — keep
        // whatever was last saved locally (defaulting to "with greeting").
        if let savedRaw = UserDefaults.standard.string(forKey: VoicePlaybackPattern.storageKey),
           let saved = VoicePlaybackPattern(rawValue: savedRaw) {
            selectedPlaybackPattern = saved
        } else {
            selectedPlaybackPattern = .withGreeting
        }
    }

    private func optionsList(serverOptions: [VoiceMessageOption]?, customKey: String) -> [MessageOption] {
        let serverDerived = (serverOptions ?? []).map { option in
            MessageOption(
                text: option.message ?? "",
                isSelected: option.isActive ?? false,
                isCustom: !(option.isPreset ?? true),
                serverId: option.id
            )
        }

        let customTexts = UserDefaults.standard.stringArray(forKey: customKey) ?? []
        let localCustom = customTexts
            .filter { text in !serverDerived.contains { $0.text.caseInsensitiveCompare(text) == .orderedSame } }
            .map { MessageOption(text: $0, isSelected: false, isCustom: true) }

        return serverDerived + localCustom
    }

    private func ensureAtLeastOneSelected(_ options: inout [MessageOption]) {
        guard !options.isEmpty, !options.contains(where: { $0.isSelected }) else { return }
        options[0].isSelected = true
    }

    private func applySavedSelection(_ options: inout [MessageOption], savedText: String?) {
        guard let savedText else { return }
        for i in options.indices {
            options[i].isSelected = (options[i].text == savedText)
        }
    }

  
    private func addCustomMessage(_ text: String, options: Binding<[MessageOption]>, customKey: String, category: VoiceMessageCategory) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard !options.wrappedValue.contains(where: { $0.text.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            toastManager.show(message: "This message already exists", type: .error, duration: 1.5)
            return
        }

        guard !addMessageVM.isLoading else { return }

        Task {
            await addMessageVM.addMessage(category: category.rawValue, message: trimmed)

            if addMessageVM.addSuccess {
             
                await profileViewModel.fetchUserProfile()

                let previouslySelectedText = options.wrappedValue.first(where: { $0.isSelected })?.text
                var rebuilt = optionsList(serverOptions: serverOptions(for: category), customKey: customKey)
                if let previouslySelectedText {
                    for i in rebuilt.indices {
                        rebuilt[i].isSelected = (rebuilt[i].text == previouslySelectedText)
                    }
                }
                ensureAtLeastOneSelected(&rebuilt)

                options.wrappedValue = rebuilt
                persistCustomMessages(rebuilt, key: customKey)
                toastManager.show(message: "Message added", type: .success, duration: 1.2)
            } else {
                let failureMessage = addMessageVM.errorMessage.isEmpty
                    ? "Failed to add message to \(category.title)"
                    : addMessageVM.errorMessage
                toastManager.show(message: failureMessage, type: .error, duration: 1.5)
            }
        }
    }

    private func serverOptions(for category: VoiceMessageCategory) -> [VoiceMessageOption]? {
        switch category {
        case .accessGranted: return voiceMessage?.access_granted
        case .accessDenied: return voiceMessage?.access_denied
        case .accessUnauthorized: return voiceMessage?.access_unauthorized
        case .welcome: return voiceMessage?.welcome
        }
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
        guard !saveVoicePreferenceVM.isLoading else { return }

        let granted = grantedOptions.first(where: { $0.isSelected })
        let denied = deniedOptions.first(where: { $0.isSelected })
        let unauthorized = unauthorizedOptions.first(where: { $0.isSelected })
        let greeting = greetingOptions.first(where: { $0.isSelected })

        guard let grantedId = granted?.serverId,
              let deniedId = denied?.serverId,
              let unauthorizedId = unauthorized?.serverId,
              let greetingId = greeting?.serverId
        else {
            toastManager.show(message: "Can't save yet — one of the selected messages isn't synced with the server.", type: .error, duration: 2)
            return
        }

        Task {
            await saveVoicePreferenceVM.saveFullVoiceSetting(
                isActiveVoiceGranted: isGrantedVoiceEnabled,
                isActiveVoiceDenied: isDeniedVoiceEnabled,
                isActiveVoiceUnauthorized: isUnauthorizedVoiceEnabled,
                isActiveVoiceWelcome: isGreetingVoiceEnabled,
                accessGrantedId: grantedId,
                accessDeniedDId: deniedId,
                accessUnauthorizedId: unauthorizedId,
                welcomeId: greetingId
            )

            if saveVoicePreferenceVM.addSuccess {
                UserDefaults.standard.set(granted?.text, forKey: "voice_granted")
                UserDefaults.standard.set(denied?.text, forKey: "voice_denied")
                UserDefaults.standard.set(unauthorized?.text, forKey: "voice_unauthorized")
                UserDefaults.standard.set(greeting?.text, forKey: "voice_greeting")

                UserDefaults.standard.set(isGrantedVoiceEnabled, forKey: "voice_enabled_granted")
                UserDefaults.standard.set(isDeniedVoiceEnabled, forKey: "voice_enabled_denied")
                UserDefaults.standard.set(isUnauthorizedVoiceEnabled, forKey: "voice_enabled_unauthorized")
                UserDefaults.standard.set(isGreetingVoiceEnabled, forKey: "voice_enabled_greeting")

                UserDefaults.standard.set(selectedPlaybackPattern.rawValue, forKey: VoicePlaybackPattern.storageKey)

                toastManager.show(message: "Saved successfully", type: .success, duration: 1.5)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } else {
                let failureMessage = saveVoicePreferenceVM.errorMessage.isEmpty
                    ? "Failed to save"
                    : saveVoicePreferenceVM.errorMessage
                toastManager.show(message: failureMessage, type: .error, duration: 1.5)
            }
        }
    }
 
    func ResetMessages() {
        guard !saveVoicePreferenceVM.isLoading else { return }

        func defaultOption(in options: [MessageOption]) -> MessageOption? {
            options.first(where: { !$0.isCustom }) ?? options.first
        }

        let defaultGranted = defaultOption(in: grantedOptions)
        let defaultDenied = defaultOption(in: deniedOptions)
        let defaultUnauthorized = defaultOption(in: unauthorizedOptions)
        let defaultGreeting = defaultOption(in: greetingOptions)
        // Reset always turns voice announcements back on, regardless of the
        // server's current per-category `is_voice_active_*` flags.
        let resetToggle = true
        let resetPattern = VoicePlaybackPattern.withGreeting

        guard let grantedId = defaultGranted?.serverId,
              let deniedId = defaultDenied?.serverId,
              let unauthorizedId = defaultUnauthorized?.serverId,
              let greetingId = defaultGreeting?.serverId
        else {
            toastManager.show(message: "Can't reset yet — default messages aren't synced with the server.", type: .error, duration: 2)
            return
        }

        isResetting = true

        Task {
            await saveVoicePreferenceVM.saveFullVoiceSetting(
                isActiveVoiceGranted: resetToggle,
                isActiveVoiceDenied: resetToggle,
                isActiveVoiceUnauthorized: resetToggle,
                isActiveVoiceWelcome: resetToggle,
                accessGrantedId: grantedId,
                accessDeniedDId: deniedId,
                accessUnauthorizedId: unauthorizedId,
                welcomeId: greetingId
            )

            if saveVoicePreferenceVM.addSuccess {
                grantedOptions = grantedOptions.map { MessageOption(text: $0.text, isSelected: $0.serverId == grantedId, isCustom: $0.isCustom, serverId: $0.serverId) }
                deniedOptions = deniedOptions.map { MessageOption(text: $0.text, isSelected: $0.serverId == deniedId, isCustom: $0.isCustom, serverId: $0.serverId) }
                unauthorizedOptions = unauthorizedOptions.map { MessageOption(text: $0.text, isSelected: $0.serverId == unauthorizedId, isCustom: $0.isCustom, serverId: $0.serverId) }
                greetingOptions = greetingOptions.map { MessageOption(text: $0.text, isSelected: $0.serverId == greetingId, isCustom: $0.isCustom, serverId: $0.serverId) }

                isGrantedVoiceEnabled = resetToggle
                isDeniedVoiceEnabled = resetToggle
                isUnauthorizedVoiceEnabled = resetToggle
                isGreetingVoiceEnabled = resetToggle
                selectedPlaybackPattern = resetPattern

                UserDefaults.standard.set(defaultGranted?.text, forKey: "voice_granted")
                UserDefaults.standard.set(defaultDenied?.text, forKey: "voice_denied")
                UserDefaults.standard.set(defaultUnauthorized?.text, forKey: "voice_unauthorized")
                UserDefaults.standard.set(defaultGreeting?.text, forKey: "voice_greeting")
                UserDefaults.standard.set(resetToggle, forKey: "voice_enabled_granted")
                UserDefaults.standard.set(resetToggle, forKey: "voice_enabled_denied")
                UserDefaults.standard.set(resetToggle, forKey: "voice_enabled_unauthorized")
                UserDefaults.standard.set(resetToggle, forKey: "voice_enabled_greeting")
                UserDefaults.standard.set(resetPattern.rawValue, forKey: VoicePlaybackPattern.storageKey)

                toastManager.show(message: "Successfully reset to defaults", type: .success, duration: 1.5)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } else {
                let failureMessage = saveVoicePreferenceVM.errorMessage.isEmpty
                    ? "Failed to reset"
                    : saveVoicePreferenceVM.errorMessage
                toastManager.show(message: failureMessage, type: .error, duration: 1.5)
            }

            isResetting = false
        }
    }
    
    
}





struct MessageSection: View {
    let id: Int
    let title: String
    let description: String
    @Binding var options: [MessageOption]
    @Binding var openSection: Int?
    @Binding var isVoiceEnabled: Bool
    var isAdding: Bool = false
    var deletingOptionId: UUID? = nil
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

    private let maxCustomMessages = 5

    private var customMessageCount: Int {
        options.filter { $0.isCustom }.count
    }

    private var canAddMoreCustomMessages: Bool {
        customMessageCount < maxCustomMessages
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)

                Spacer()

                Text("Enable Voice")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.7))

                Toggle("", isOn: $isVoiceEnabled)
                    .labelsHidden()
                    .tint(.green)
                    .padding(.trailing, 4)
            }

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
                                if deletingOptionId == options[idx].id {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red.opacity(0.85)))
                                        .frame(width: 13, height: 13)
                                } else {
                                    Button {
                                        print("🗑️ Trash tapped — text: \"\(options[idx].text)\", serverId: \(options[idx].serverId ?? "nil")")
                                        onRequestDelete(options[idx])
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundColor(.red.opacity(0.85))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(deletingOptionId != nil)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        //  .background(idx % 2 == 0 ? Color.white.opacity(0.03) : Color.white.opacity(0.05))

                    }

                    // Add-your-own-message row — hidden once this category already has
                    // the max number of custom (deletable) messages.
                    if canAddMoreCustomMessages {
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 8) {
                                Image("message")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white.opacity(0.5))

                                TextField("", text: $newMessageText, prompt: Text("Add your own message...").foregroundColor(.white.opacity(0.4)))
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Regular", size: 14))
                                    .submitLabel(.done)
                                    .disabled(isAdding)
                                    .onSubmit(addCustomMessage)
                                    .onChange(of: newMessageText) { newValue in

                                        if newValue.count > maxMessageLength {
                                            newMessageText = String(newValue.prefix(maxMessageLength))
                                        }
                                    }

                                if isAdding {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 22, height: 22)
                                } else {
                                    Button(action: addCustomMessage) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(trimmedNewMessage.isEmpty ? .white.opacity(0.25) : .green)
                                    }
                                    .disabled(trimmedNewMessage.isEmpty)
                                }
                            }

                            Text("\(remainingCharacters) characters left")
                                .font(.custom("Inter-Regular", size: 11))
                                .foregroundColor(remainingCharacters <= 10 ? .orange : .white.opacity(0.4))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                }
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity)
                .padding(.top,-9)
            }

        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )

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
        guard !isAdding, !trimmedNewMessage.isEmpty else { return }
        onAddCustom(trimmedNewMessage)
        newMessageText = ""
        UIApplication.shared.hideKeyboard()
    }
}
