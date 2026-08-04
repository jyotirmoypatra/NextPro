//
//  InfoScreenView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/07/26.
//

import SwiftUI

struct InfoScreenView: View {
    @Environment(\.dismiss) private var dismiss
    let infoType: String


    private var titleText: String {
        switch infoType {
        case "device_config_info":
            return "How to Configure Device"
        case "user_add_info":
            return "How to Add User"
        default:
            return "Info"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("backgroundimg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                Color.black.opacity(0.9)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack {
                        Text(titleText)
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 40)

                        HStack {
                            Spacer()

                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 15)

                    ScrollView(.vertical, showsIndicators: false) {
                        if infoType == "device_config_info" {
                            HowToConfigureDeviceContent()
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                        } else if infoType == "user_add_info" {
                            HowToAddUserContent()
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - How to Configure Device (device_config_info)

private struct StepNote: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

private struct ConfigurationStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    let badge: String
    let imageName: String
    let isSuccess: Bool
    let notes: [StepNote]
}

private let configurationSteps: [ConfigurationStep] = [
    ConfigurationStep(
        id: 1,
        title: "Select Your Device",
        description: "Power on your device and select it from the available device list, then tap Next — the app will scan for it over Bluetooth for up to 15 seconds.",
        badge: "Bluetooth Required",
        imageName: "config_1",
        isSuccess: false,
        notes: [
            StepNote(
                title: "If your device isn't found:",
                text: "Make sure it's powered on and within range, then try again."
            )
        ]
    ),
    ConfigurationStep(
        id: 2,
        title: "Choose Wi-Fi",
        description: "The app detects the Wi-Fi network your phone is currently connected to. Confirm it's the correct 2.4 GHz network, then tap Next.",
        badge: "2.4 GHz Wi-Fi",
        imageName: "config_2",
        isSuccess: false,
        notes: [
            StepNote(
                title: "Why is location required?",
                text: "iOS uses your location to identify the connected Wi-Fi network — this is an Apple requirement, not something the app can bypass."
            ),
            StepNote(
                title: "If no network appears:",
                text: "Check that your phone is connected to Wi-Fi and location permissions are granted."
            )
        ]
    ),
    ConfigurationStep(
        id: 3,
        title: "Enter Password",
        description: "Enter the password for the selected Wi-Fi network and tap Next.",
        badge: "Secure Connection",
        imageName: "config_3",
        isSuccess: false,
        notes: [
            StepNote(
                title: "What happens next:",
                text: "Your location is saved as the install address, credentials are sent to your device over Bluetooth, and the configuration is saved to the cloud once connected."
            ),
            StepNote(
                title: "If configuration fails:",
                text: "Check your Wi-Fi password is correct and that your device is still powered on and nearby."
            )
        ]
    ),
    ConfigurationStep(
        id: 4,
        title: "Configure Device",
        description: "Keep your device powered on while the Wi-Fi credentials are sent.",
        badge: "Keep App Open",
        imageName: "config_4",
        isSuccess: false,
        notes: [
            StepNote(
                title: "Tip:",
                text: "Setup may take up to a minute — avoid closing the app or locking your phone during this time."
            )
        ]
    ),
    ConfigurationStep(
        id: 5,
        title: "Setup Complete",
        description: "Once configuration succeeds, your device is ready to use. Tap Continue to return to your devices.",
        badge: "Configured",
        imageName: "config_5",
        isSuccess: true,
        notes: []
    )
]

private struct HowToConfigureDeviceContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            BeforeYouStartCard()
                .padding(.bottom, 20)

            VStack(spacing: 0) {
                ForEach(Array(configurationSteps.enumerated()), id: \.element.id) { index, step in
                    ConfigurationStepCard(
                        step: step,
                        isLast: index == configurationSteps.count - 1
                    )
                }
            }
            .padding(.bottom, 20)

            SetupNotesCard()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Follow these steps to connect your device to Wi-Fi.")
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(.gray)

            Text("5 SIMPLE STEPS")
                .font(.custom("Inter-SemiBold", size: 10))
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }
}

private struct ConfigurationStepCard: View {
    let step: ConfigurationStep
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill((step.isSuccess ? Color.green : Color.blue).opacity(0.15))
                        .frame(width: 34, height: 34)
                    Circle()
                        .stroke(step.isSuccess ? Color.green : Color.blue, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                    Text(String(format: "%02d", step.id))
                        .font(.custom("Inter-Bold", size: 12))
                        .foregroundColor(step.isSuccess ? .green : .white)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 34)

            // Card content
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.title)
                            .font(.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(.white)

                        Text(step.description)
                            .font(.custom("Inter-Regular", size: 12.5))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)

                        RequirementBadge(text: step.badge, isSuccess: step.isSuccess)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                    ConfigurationScreenshot(imageName: step.imageName)
                        .frame(width: 92)
                }

                if !step.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(step.notes) { note in
                            StepNoteRow(note: note)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.bottom, isLast ? 0 : 14)
        }
    }
}

private struct StepNoteRow: View {
    let note: StepNote

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue.opacity(0.8))
                .padding(.top, 1)

            (
                Text(note.title + " ")
                    .font(.custom("Inter-SemiBold", size: 11.5))
                    .foregroundColor(.white.opacity(0.85))
                +
                Text(note.text)
                    .font(.custom("Inter-Regular", size: 11.5))
                    .foregroundColor(.gray)
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.blue.opacity(0.08))
        )
    }
}

private struct ConfigurationScreenshot: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

private struct RequirementBadge: View {
    let text: String
    let isSuccess: Bool

    var body: some View {
        Text(text)
            .font(.custom("Inter-SemiBold", size: 11))
            .foregroundColor(isSuccess ? .green : .blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill((isSuccess ? Color.green : Color.blue).opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke((isSuccess ? Color.green : Color.blue).opacity(0.3), lineWidth: 1)
            )
    }
}

private struct BeforeYouStartCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before You Start")
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 14) {
                BeforeYouStartRow(
                    icon: "antenna.radiowaves.left.and.right",
                    text: "Turn on Bluetooth",
                    subtext: "The app uses it to find your device nearby."
                )
                BeforeYouStartRow(
                    icon: "location.fill",
                    text: "Turn on Location Services with Precise Location",
                    subtext: "Required to detect your Wi-Fi network."
                )
                BeforeYouStartRow(
                    icon: "wifi",
                    text: "Connect your phone to the 2.4 GHz Wi-Fi network",
                    subtext: "Most smart devices only support 2.4 GHz, not 5 GHz."
                )
            }

            Text("Keep the app open and your device powered on during configuration.")
                .font(.custom("Inter-Regular", size: 11.5))
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct BeforeYouStartRow: View {
    let icon: String
    let text: String
    var subtext: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 20, alignment: .center)

            VStack(alignment: .leading, spacing: 3) {
                Text(text)
                    .font(.custom("Inter-Regular", size: 12.5))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                if let subtext {
                    Text(subtext)
                        .font(.custom("Inter-Regular", size: 11))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct SetupNotesCard: View {
    private let notes: [String] = [
        "Keep the app open and your device powered on throughout the setup process.",
        "Only 2.4 GHz networks are supported. If your phone is on a 5 GHz network, switch to your router's 2.4 GHz band first.",
        "Location permission is required only to detect Wi-Fi network details, as required by iOS — it is also used to tag the device's saved address in Step 3.",
        "If Bluetooth or Location permission was denied earlier, enable it from Settings → Privacy & Security.",
        "Setup may take up to a minute — avoid closing the app or locking your phone during configuration."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)

                Text("Notes")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(notes, id: \.self) { note in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)

                        Text(note)
                            .font(.custom("Inter-Regular", size: 11.5))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - How to Add User (user_add_info)

private struct AddUserStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    let badge: String
    let isSuccess: Bool
    let notes: [StepNote]
}

private let addUserSteps: [AddUserStep] = [
    AddUserStep(
        id: 1,
        title: "Add Basic Details",
        description: "Fill in the user's Full Name and Email address — both are required to create the account.",
        badge: "Name & Email Required",
        isSuccess: false,
        notes: [
            StepNote(
                title: "Phone number:",
                text: "Optional, unless Share Link access is enabled below."
            )
        ]
    ),
    AddUserStep(
        id: 2,
        title: "Choose Device Access",
        description: "Select at least one way this user will unlock doors — Mobile App, Key Fob / Card, or Share Link.",
        badge: "At Least 1 Required",
        isSuccess: false,
        notes: []
    ),
    AddUserStep(
        id: 3,
        title: "Mobile App Access",
        description: "Turn this on to enable Phone Tap and/or Remote unlock from the app. A Digital Card ID is generated automatically.",
        badge: "Phone Tap or Remote",
        isSuccess: false,
        notes: [
            StepNote(
                title: "Remote enabled:",
                text: "Also lets the user unlock over Bluetooth as a backup option."
            )
        ]
    ),
    AddUserStep(
        id: 4,
        title: "Key Fob / Card Access",
        description: "Turn this on to give the user a physical key fob or card. You'll need to enter its unique Physical ID.",
        badge: "Physical ID Required",
        isSuccess: false,
        notes: [
            StepNote(
                title: "Access limitation:",
                text: "Key Fob / Card users can only be granted access through an Access Group, not individual Doors."
            )
        ]
    ),
    AddUserStep(
        id: 5,
        title: "Share Link Access",
        description: "Turn this on to send the user a temporary access link instead of app or key fob access.",
        badge: "Phone Number Required",
        isSuccess: false,
        notes: []
    ),
    AddUserStep(
        id: 6,
        title: "Set Access Configuration",
        description: "Choose Access Group to assign one or more predefined door groups, or Select Doors to grant access to specific doors individually.",
        badge: "Pick One",
        isSuccess: false,
        notes: []
    ),
    AddUserStep(
        id: 7,
        title: "Configure Door Access",
        description: "For individually selected doors, choose an Access Date, an Access Time, and (for Schedule) which days it repeats on. See the comparison and validation rules below.",
        badge: "Doors Only",
        isSuccess: false,
        notes: []
    ),
    AddUserStep(
        id: 8,
        title: "Save the User",
        description: "Once all required fields are filled in, tap Save to create the user and apply the configured access.",
        badge: "Final Step",
        isSuccess: true,
        notes: []
    )
]

private struct HowToAddUserContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            VStack(spacing: 0) {
                ForEach(Array(addUserSteps.enumerated()), id: \.element.id) { index, step in
                    AddUserStepCard(
                        step: step,
                        isLast: index == addUserSteps.count - 1
                    )
                }
            }
            .padding(.bottom, 20)

            AccessTypeCompareCard()
                .padding(.bottom, 16)

            DateTimeValidationCard()
                .padding(.bottom, 16)

            AddUserNotesCard()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Everything you need to know to add a new user.")
                .font(.custom("Inter-Regular", size: 13))
                .foregroundColor(.gray)

            Text("\(addUserSteps.count) STEPS")
                .font(.custom("Inter-SemiBold", size: 10))
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }
}

private struct AddUserStepCard: View {
    let step: AddUserStep
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill((step.isSuccess ? Color.green : Color.blue).opacity(0.15))
                        .frame(width: 34, height: 34)
                    Circle()
                        .stroke(step.isSuccess ? Color.green : Color.blue, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                    Text(String(format: "%02d", step.id))
                        .font(.custom("Inter-Bold", size: 12))
                        .foregroundColor(step.isSuccess ? .green : .white)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 34)

            // Card content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(step.title)
                        .font(.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(.white)

                    Text(step.description)
                        .font(.custom("Inter-Regular", size: 12.5))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)

                    RequirementBadge(text: step.badge, isSuccess: step.isSuccess)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !step.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(step.notes) { note in
                            StepNoteRow(note: note)
                        }
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.bottom, isLast ? 0 : 14)
        }
    }
}

private struct AddUserNotesCard: View {
    private let notes: [String] = [
        "A secure default password is generated automatically — the user isn't required to set one during creation.",
        "The Digital Card ID for Mobile App access is generated automatically once Phone Tap or Remote is enabled.",
        "Key Fob / Card users can only be assigned an Access Group — the Select Doors option is hidden for them.",
        "Start and end times within a time slot can't be the same, and time slots can't overlap or touch each other.",
        "You can edit any user later to change their details or access configuration."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)

                Text("Notes")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(notes, id: \.self) { note in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)

                        Text(note)
                            .font(.custom("Inter-Regular", size: 11.5))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct AccessTypeCompareCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)

                Text("One Time vs Schedule Access")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }

            AccessTypeOptionRow(
                title: "One Time",
                badge: "1 Time Slot",
                points: [
                    "One Access Date section with a Start Date and an End Date.",
                    "Exactly one Access Time — one Start Time and one End Time. There's no + icon to add more.",
                    "No Repeat Every section — access does not recur on a weekly basis."
                ]
            )

            AccessTypeOptionRow(
                title: "Schedule",
                badge: "Up to 3 Time Slots",
                points: [
                    "Same Access Date section — one Start Date and one End Date.",
                    "Tap the + icon under Access Time to add more slots — up to 3 in total.",
                    "Each slot shows a − icon to remove it once there's more than 1.",
                    "A Repeat Every section appears — select the day(s) the access repeats on."
                ]
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct AccessTypeOptionRow: View {
    let title: String
    let badge: String
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 13))
                    .foregroundColor(.white)

                Spacer()

                RequirementBadge(text: badge, isSuccess: false)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)

                        Text(point)
                            .font(.custom("Inter-Regular", size: 11.5))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct DateTimeValidationCard: View {
    private let rules: [String] = [
        "Start Date is required. End Date is optional, but if set it can't be earlier than the Start Date.",
        "Every time slot must have both a Start Time and an End Time filled in before saving.",
        "A slot's Start Time and End Time can't be exactly the same.",
        "A slot's End Time must be later than its own Start Time.",
        "Time slots can't overlap — one slot's time range can't cross into another slot's range.",
        "One slot's End Time can't be exactly equal to another slot's Start Time (no back-to-back touching).",
        "For Schedule access, at least one Repeat Every day must be selected.",
        "At least one door must be selected before the user can be saved."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)

                Text("Date & Time Validation Rules")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.custom("Inter-SemiBold", size: 11.5))
                            .foregroundColor(.blue.opacity(0.85))

                        Text(rule)
                            .font(.custom("Inter-Regular", size: 11.5))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
