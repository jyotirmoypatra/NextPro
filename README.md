# NextPro - IoT Door Access Control Application

## Overview
NextPro is an iOS application built with SwiftUI that provides smart door access control through digital keys and remote unlocking capabilities. The app supports two user roles: **Admin** and **End User**, each with distinct functionalities.

---

## Application Flow - Start to End

### 1. Application Launch & Initialization

#### 1.1 Splash Screen
- **File**: `SplashScreen.swift`
- **Duration**: 1 second
- **Function**: Displays splash image while app initializes
- **Flow**: 
  - App launches → Splash screen appears
  - After 1 second → Checks login status
  - Navigates to appropriate screen based on authentication state

#### 1.2 Content View Router
- **File**: `ContentView.swift`
- **Function**: Main navigation controller
- **Logic**:
  - Checks for stored access token in Keychain
  - Checks user ID and admin status from UserDefaults
  - Routes to:
    - **Login Screen** (if not authenticated)
    - **Admin Home** (if authenticated as admin)
    - **End User Home** (if authenticated as regular user)

---

### 2. Authentication Flow

#### 2.1 First-Time User Setup
- **File**: `LoginView.swift`
- **Flow**:
  1. User enters email address
  2. Clicks "VERIFY EMAIL" button
  3. System validates email via API (`/api/facility-user/validate-email/`)
  4. **Three possible outcomes**:
     - **Email not registered**: Error message displayed
     - **Email registered, password not set**: Navigate to `CreateNewPasswordView`
     - **Email registered, password set, agreement not accepted**: Navigate to `UserAgreementScreen`
     - **Email registered, password set, agreement accepted**: Show login form

#### 2.2 Password Creation
- **File**: `CreateNewPasswordView.swift`
- **Flow**:
  1. User enters new password (with validation)
  2. Confirms password
  3. Password is sent to API (`/api/facility-user/reset-password/`)
  4. On success: Navigate back to login screen
  5. User can now log in with email and password

#### 2.3 User Agreement
- **File**: `UserAgreementScreen.swift`
- **Flow**:
  1. User reads terms and conditions
  2. User accepts agreement
  3. Agreement acceptance sent to API (`/api/facility-user/update-agreement/`)
  4. On success: Navigate back to login screen

#### 2.4 Login Process
- **File**: `LoginView.swift` + `LoginViewModel.swift`
- **Flow**:
  1. User enters email and password
  2. Clicks "LOG IN" button
  3. API call to `/api/facility-user/login/`
  4. **On Success**:
     - Access token stored in Keychain
     - User ID and admin status stored in UserDefaults
     - User's initial setup flag set to `true`
     - Navigate to appropriate home screen (Admin/End User)
  5. **On Failure**: Error alert displayed

#### 2.5 Password Reset (Forgot Password)
- **File**: `ResetPassword.swift`
- **Flow**:
  1. User enters email
  2. Clicks "SEND OTP" button
  3. OTP sent to email via API (`/api/facility-user/forgot-password/request/`)
  4. User enters OTP
  5. OTP verified via API (`/api/facility-user/forgot-password/verify/`)
  6. User creates new password
  7. Password updated via API (`/api/facility-user/reset-password/`)
  8. Navigate back to login screen

---

### 3. End User Flow

#### 3.1 Home Screen
- **File**: `HomeViewEndUser.swift`
- **Tabs**:
  - **Tab 0**: Open Doors (`DoorOpenView`)
  - **Tab 1**: Membership (`MembershipEndUserView`)
  - **Tab 2**: Profile (`ProfileEndUserView`)

#### 3.2 Door Opening - Digital Access
- **File**: `DoorOpenView.swift`
- **Functionality**: Proximity-based automatic door unlocking via Bluetooth Low Energy (BLE)
- **Flow**:
  1. **Initialization**:
     - Fetches device details from API (`/api/facility/user/device-access/`)
     - Checks for digital key access permission
     - Loads authorized doors from `DoorStorageManager`
     - Connects to MQTT broker for real-time door events
     - Initializes BLE manager for device scanning
  
  2. **BLE Scanning**:
     - Continuously scans for nearby Thimmo devices (M2, TC, BC, AC, DM, M23, M22, XM prefixes)
     - Monitors RSSI (signal strength) of detected devices
     - Filters devices based on authorized door list
  
  3. **Auto-Unlock Process**:
     - When user approaches door (RSSI > -40 dBm):
       - Identifies closest authorized door device
       - Activates 20-second MQTT event window
       - Sends unlock command via BLE using `DoorManager`
       - Shows progress animation (yellow ring → green checkmark)
       - Waits for MQTT confirmation event
  
  4. **MQTT Event Handling**:
     - Subscribes to device topics: `up/{SN}/rtdata` or `up/{SN}/data`
     - Receives door events with user ID, card number, door ID, event type
     - Validates event matches current user
     - **Success (type 0)**: Green animation, voice announcement, haptic feedback
     - **Failure (types 41-62)**: Red animation, denial message, voice announcement
     - **Unauthorized device**: Orange animation, warning message
  
  5. **Visual Feedback**:
     - Digital card display showing organization name, user name, masked card number, expiry
     - Scanning animation when actively searching
     - Full-screen overlay with lock icon and progress ring
     - Color-coded status: White (idle) → Yellow (verifying) → Green (success) → Red (failure)

#### 3.3 Door Opening - Remote Access
- **File**: `DoorOpenView.swift` + `RemoteDoorCardView.swift`
- **Functionality**: Manual door unlocking via MQTT or BLE from anywhere
- **Flow**:
  1. User views list of available remote access doors
  2. Each door card shows:
     - Door name
     - Device serial number
     - Two unlock buttons: "Remote Open" (MQTT) and "BLE Open"
  
  3. **Remote Open (MQTT)**:
     - Activates 20-second MQTT window
     - Sends command to `down/{serial}` topic
     - Command format: `{"commandid": 1, "operation": "put", "resource": "device/doors/{doorID}/lock/status?value=on&time=5"}`
     - Waits for MQTT success event (type 0, 8, or 19)
     - Shows success animation and voice announcement
  
  4. **BLE Open**:
     - Checks Bluetooth is enabled
     - Connects to door device via BLE
     - Sends unlock command directly to device
     - Waits for MQTT confirmation
     - Shows success animation

#### 3.4 Membership Management
- **File**: `MembershipEndUserView.swift`
- **Functionality**: View active and canceled memberships
- **Features**:
  - Tabbed interface (Active / Canceled)
  - Membership cards showing:
    - Membership name
    - Facility/gym name
    - Renewal duration
    - Monthly price
  - Pull-to-refresh support

#### 3.5 Profile Management
- **File**: `ProfileEndUserView.swift`
- **Functionality**: User profile and settings management
- **Flow**:
  1. **Profile Display**:
     - Fetches user profile from API (`/api/facility-user/user/detail/`)
     - Shows profile image, full name, phone number
     - Tap image to view full screen
  
  2. **Edit Profile**:
     - Navigate to `EditProfileView`
     - Edit full name, phone number
     - Upload new profile image
     - Save changes via API (`/api/facility-user/user/update/`)
  
  3. **Update Password**:
     - Navigate to `CreateNewPasswordView`
     - Enter current password, new password, confirm password
     - Update via API (`/api/facility-user/reset-password/`)
  
  4. **Voice Messages**:
     - Navigate to `VoiceAnnouncementsDoor`
     - Configure custom voice announcements for:
     - Access granted messages
     - Access denied messages
     - Unauthorized access messages
     - Greeting messages
     - Messages stored in UserDefaults
  
  5. **Settings**:
     - Notifications toggle
     - Privacy Policy (WebView)
     - Terms and Conditions (WebView)
     - Support
     - Delete Account (confirmation sheet)
     - Logout (confirmation sheet → clears Keychain and UserDefaults)

---

### 4. Admin Flow

#### 4.1 Home Screen
- **File**: `HomeViewAdmin.swift`
- **Tabs**:
  - **Tab 0**: Open Doors (`DoorOpenView` - same as End User)
  - **Tab 1**: Devices (`DeviceAdminTabView`)
  - **Tab 2**: Profile (`ProfileEndUserView` - same as End User)

#### 4.2 Device Management
- **File**: `DeviceAdminTabView.swift`
- **Functionality**: View and configure door access devices
- **Features**:
  - List of all configured devices
  - Device status (ONLINE/OFFLINE)
  - Device model and serial number
  - Door name associated with device
  - "Configure device" button to add new devices

#### 4.3 Device Onboarding Flow
- **Files**: 
  - `OnboardPageDeviceScanView.swift`
  - `OnboardPageWiFiListView.swift`
  - `OnboardPageWifiPasswordView.swift`
  - `SuccessConnctionView.swift`

**Step 1: Device Scanning**
- **File**: `OnboardPageDeviceScanView.swift`
- **Flow**:
  1. Check Bluetooth permissions
  2. Start BLE scanning for Thimmo devices
  3. Display list of discovered devices with:
     - Device serial number
     - Signal strength (RSSI)
     - Configuration status (configured/unconfigured)
  4. User selects device
  5. Click "Next" to proceed

**Step 2: WiFi Network Selection**
- **File**: `OnboardPageWiFiListView.swift`
- **Flow**:
  1. Request location permission (required for WiFi scanning on iOS)
  2. Fetch currently connected WiFi network
  3. Display WiFi network name
  4. User selects WiFi network
  5. Click "Next" to proceed

**Step 3: WiFi Password Entry**
- **File**: `OnboardPageWifiPasswordView.swift`
- **Flow**:
  1. User enters WiFi password
  2. Click "Connect" button
  3. WiFi credentials sent to device via BLE
  4. Device connects to WiFi network
  5. On success: Navigate to success screen

**Step 4: Success Confirmation**
- **File**: `SuccessConnctionView.swift`
- **Flow**:
  1. Display success message
  2. Device is now configured and connected
  3. User can return to device list

---

### 5. Core Managers & Services

#### 5.1 MQTT Manager
- **File**: `MQTTManager.swift`
- **Functionality**: Real-time communication with door devices
- **Features**:
  - Connects to MQTT broker (13.223.139.54:1883)
  - Subscribes to device event topics
  - Publishes door unlock commands
  - Handles reconnection on disconnect
  - Parses door events and posts notifications
  - Topic formats:
    - Subscribe: `up/{serial}/rtdata` or `up/{serial}/data`
    - Publish: `down/{serial}`

#### 5.2 BLE Manager
- **File**: `BLEManager.swift`
- **Functionality**: Bluetooth Low Energy device communication
- **Features**:
  - Scans for Thimmo devices (M2, TC, BC, AC, DM, M23, M22, XM prefixes)
  - Monitors RSSI for proximity detection
  - Connects to devices
  - Continuous scanning mode
  - RSSI monitoring for auto-unlock
  - Device filtering and validation

#### 5.3 Door Manager
- **File**: `DoorManager.swift`
- **Functionality**: Door SDK operations and door event management
- **Features**:
  - Opens doors via BLE using DoorMaster SDK
  - Manages 20-second MQTT event window
  - Tracks door events and status
  - Handles door unlock commands

#### 5.4 Door Storage Manager
- **File**: `DoorStorageManager.swift`
- **Functionality**: Manages authorized doors for current user
- **Features**:
  - Stores list of authorized doors
  - Resolves door names from device serial numbers
  - Provides door lookup functionality

#### 5.5 Network Manager
- **File**: `NetworkManager.swift`
- **Functionality**: Internet connectivity monitoring
- **Features**:
  - Checks internet availability
  - Shows overlay when offline
  - Triggers UI updates on connectivity changes

#### 5.6 Keychain Manager
- **File**: `KeychainManager.swift`
- **Functionality**: Secure storage for sensitive data
- **Features**:
  - Stores access tokens securely
  - Retrieves stored tokens
  - Clears all user data on logout
  - Resets app to login state

#### 5.7 Speech Manager
- **File**: `SpeechManager.swift`
- **Functionality**: Voice announcements for door events
- **Features**:
  - Text-to-speech for access granted/denied messages
  - Customizable voice messages
  - Supports door name prefixes in messages

#### 5.8 WiFi Configurator
- **File**: `WiFiConfigurator.swift`
- **Functionality**: WiFi network configuration for devices
- **Features**:
  - Sends WiFi credentials to devices via BLE
  - Handles WiFi connection process
  - Validates WiFi setup

---

### 6. API Integration

#### 6.1 Base Configuration
- **File**: `APIConfig.swift`
- **Base URL**: `https://devapi.nextprotechnologies.com`
- **Endpoints**:
  - `/api/facility-user/login/` - User login
  - `/api/facility-user/validate-email/` - Email validation
  - `/api/facility-user/reset-password/` - Password reset/update
  - `/api/facility-user/forgot-password/request/` - Request OTP
  - `/api/facility-user/forgot-password/verify/` - Verify OTP
  - `/api/facility-user/update-agreement/` - Accept user agreement
  - `/api/facility/user/device-access/` - Get device details and door access
  - `/api/facility-user/user/detail/` - Get user profile
  - `/api/facility-user/user/update/` - Update user profile
  - `/api/facility-user/upload-image/` - Upload profile image

#### 6.2 Authentication
- All API requests include access token in headers (from Keychain)
- Token-based authentication
- Automatic token refresh handling

---

### 7. User Interface Components

#### 7.1 Common Views
- **Modern Alert View**: Custom alert dialogs with success/error states
- **Toast Manager**: Toast notifications for user feedback
- **Keyboard Aware Modifier**: Adjusts UI when keyboard appears
- **Internet Overlay**: Shows when device is offline
- **Web View Modal**: Displays Privacy Policy and Terms & Conditions

#### 7.2 Animations
- **Progress Ring**: Circular progress indicator for door unlocking
- **Lock Icon Animations**: Animated lock/unlock states
- **Shimmer Effects**: Loading placeholders for images and text
- **Wave Animation**: Scanning indicator for BLE activity

---

### 8. Data Models

#### 8.1 User Models
- `LoginResponseModel`: Login API response
- `UserProfileResponse`: User profile data
- `DeviceDetailsResponse`: Device and door access information
- `ForgetPasswordModel`: Password reset request/response

#### 8.2 Device Models
- `DeviceConfig`: Device configuration (serial, MAC, encryption key)
- `DeviceConfigList`: List of configured devices
- `RemoteDoorItem`: Remote access door information

#### 8.3 MQTT Models
- `DoorEvent`: MQTT door event structure
- `DoorEventData`: Individual door event data

---

### 9. Permissions Required

1. **Bluetooth**: Required for BLE device scanning and communication
2. **Location**: Required for WiFi network scanning (iOS requirement)
3. **Internet**: Required for API calls and MQTT communication

---

### 10. Key Features Summary

#### For End Users:
- ✅ Digital key access (proximity-based auto-unlock)
- ✅ Remote door access (MQTT/BLE manual unlock)
- ✅ Profile management
- ✅ Membership viewing
- ✅ Voice announcements
- ✅ Password management
- ✅ Privacy & Terms access

#### For Admins:
- ✅ All End User features
- ✅ Device management
- ✅ Device onboarding (scan, WiFi config)
- ✅ Device status monitoring

---

### 11. Technical Stack

- **Framework**: SwiftUI
- **Language**: Swift
- **Networking**: URLSession, CocoaMQTT
- **Bluetooth**: CoreBluetooth
- **Storage**: Keychain (tokens), UserDefaults (settings)
- **Image Loading**: SDWebImageSwiftUI
- **Speech**: AVFoundation (AVSpeechSynthesizer)

---

### 12. State Management

- **ObservableObject**: ViewModels for API calls and state
- **@StateObject**: Shared managers (MQTT, BLE, Door, Network)
- **@Published**: Reactive properties for UI updates
- **NotificationCenter**: Door event notifications
- **Combine**: Reactive programming for state changes

---

### 13. Error Handling

- Network errors: Displayed via Modern Alert View
- API errors: Parsed and shown to user
- BLE errors: Bluetooth state messages
- MQTT errors: Automatic reconnection
- Validation errors: Inline form validation

---

### 14. Security Features

- Access tokens stored in Keychain (encrypted)
- Secure password fields
- API authentication via tokens
- BLE device filtering and validation
- MQTT event validation (user ID, card number matching)

---

## Application Architecture

```
NextProApp
├── ContentView (Router)
│   ├── SplashScreen
│   ├── LoginView
│   │   ├── CreateNewPasswordView
│   │   ├── ResetPassword
│   │   └── UserAgreementScreen
│   ├── HomeViewAdmin
│   │   ├── DoorOpenView
│   │   ├── DeviceAdminTabView
│   │   │   └── OnboardPageDeviceScanView
│   │   │       └── OnboardPageWiFiListView
│   │   │           └── OnboardPageWifiPasswordView
│   │   │               └── SuccessConnctionView
│   │   └── ProfileEndUserView
│   │       ├── EditProfileView
│   │       ├── VoiceAnnouncementsDoor
│   │       └── PrivacyAndTermsView
│   └── HomeViewEndUser
│       ├── DoorOpenView
│       │   └── RemoteDoorCardView
│       ├── MembershipEndUserView
│       └── ProfileEndUserView
│
└── Managers
    ├── MQTTManager
    ├── BLEManager
    ├── DoorManager
    ├── DoorStorageManager
    ├── NetworkManager
    ├── KeychainManager
    ├── SpeechManager
    └── WiFiConfigurator
```

---

## Development Notes

- **Testing Accounts**: Admin test account (email: "admin", password: "admin")
- **MQTT Broker**: 13.223.139.54:1883
- **API Base**: https://devapi.nextprotechnologies.com
- **Device Prefixes**: M2, TC, BC, AC, DM, M23, M22, XM
- **RSSI Threshold**: -40 dBm for auto-unlock
- **MQTT Window**: 20 seconds for event processing

---

## Future Enhancements (Potential)

- Push notifications for door events
- Door access history/logs
- Multi-facility support
- Guest access management
- Scheduled access permissions
- Device firmware updates
- Analytics dashboard

---

## Support & Contact

For issues, questions, or feature requests, please contact the development team.

---

**Version**: 1.0  
**Last Updated**: 2025  
**Platform**: iOS  
**Minimum iOS Version**: iOS 14.0+
