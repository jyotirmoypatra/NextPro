//
//  ThemeSettingsView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 17/09/26.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("theme_preference") private var themePreferenceRaw: String = ThemePreference.dark.rawValue

    private var selectedTheme: ThemePreference {
        ThemePreference(rawValue: themePreferenceRaw) ?? .dark
    }
    private var isEffectivelyDark: Bool {
        switch selectedTheme {
        case .dark: return true
        case .light: return false
        case .system: return systemColorScheme == .dark
        }
    }

    private var primaryText: Color { isEffectivelyDark ? .white : .black }
    private var secondaryText: Color { .gray }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if isEffectivelyDark {
                    Image("backgroundimg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()

                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                } else {
                    Image("backgroundlight")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                    Color.white.opacity(0.7)
                        .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    // Nav bar
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(primaryText)
                            }
                        }
                        Spacer()
                    }
                    .overlay(
                        Text("Theme")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(primaryText)
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Live preview of the currently active appearance.
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(primaryText.opacity(0.1))
                                        .frame(width: 92, height: 92)

                                    Circle()
                                        .stroke(primaryText.opacity(0.25), lineWidth: 1.5)
                                        .frame(width: 92, height: 92)

                                    Image(systemName: selectedTheme.systemImage)
                                        .font(.system(size: 34, weight: .semibold))
                                        .foregroundColor(primaryText)
                                }

                                Text(selectedTheme.title)
                                    .font(.custom("Inter-Bold", size: 18))
                                    .foregroundColor(primaryText)

                                Text("Currently active appearance")
                                    .font(.custom("Inter-Regular", size: 13))
                                    .foregroundColor(secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)

                            VStack(alignment: .leading, spacing: 14) {
                                Text("CHOOSE APPEARANCE")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(secondaryText)
                                    .padding(.horizontal, 6)

                                VStack(spacing: 12) {
                                    ForEach(ThemePreference.allCases, id: \.self) { option in
                                        ThemeOptionRow(
                                            option: option,
                                            isSelected: selectedTheme == option,
                                            primaryText: primaryText,
                                            secondaryText: secondaryText
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                themePreferenceRaw = option.rawValue
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isEffectivelyDark)
            .navigationBarBackButtonHidden()
        }
    }
}

private struct ThemeOptionRow: View {
    let option: ThemePreference
    let isSelected: Bool
    let primaryText: Color
    let secondaryText: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(primaryText.opacity(isSelected ? 0.15 : 0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: option.systemImage)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(isSelected ? primaryText : primaryText.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(primaryText)

                    Text(option.subtitle)
                        .font(.custom("Inter-Regular", size: 12.5))
                        .foregroundColor(secondaryText)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? primaryText : primaryText.opacity(0.25), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(primaryText)
                            .frame(width: 13, height: 13)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(primaryText.opacity(isSelected ? 0.1 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(primaryText.opacity(isSelected ? 0.3 : 0.1), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}




enum ThemePreference: String, CaseIterable {
    case dark
    case light
    case system

    var title: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .system: return "System Preference"
        }
    }

    /// `nil` lets SwiftUI fall back to the device's own appearance setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }

    var subtitle: String {
        switch self {
        case .dark: return "Always use the dark appearance"
        case .light: return "Always use the light appearance"
        case .system: return "Match your device's appearance setting"
        }
    }

    var systemImage: String {
        switch self {
        case .dark: return "moon.stars.fill"
        case .light: return "sun.max.fill"
        case .system: return "circle.righthalf.filled"
        }
    }
}
