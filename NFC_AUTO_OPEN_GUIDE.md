# NFC-Style Auto-Open Door Feature Guide

## 📱 Overview

This document describes the new NFC-style automatic door opening feature that opens doors automatically based on BLE signal strength (RSSI), mimicking the user experience of NFC tap-to-open.

---

## ✨ Features

### Core Functionality
- **Automatic Opening**: No button press required - door opens when you're close enough
- **Live RSSI Monitoring**: Real-time signal strength display with quality indicator
- **Smart Cooldown**: 5-second cooldown prevents accidental re-opening
- **Visual Feedback**: Animated NFC-style scanning interface with color-coded status
- **Door Information**: Shows complete door details and configuration
- **Safety First**: Automatic timeout and error handling

---

## 🎯 How It Works

### User Flow

1. **Select a Door**: Choose your door from the "Open Doors" tab
2. **Tap "Open Door as NFC"**: Navigate to the auto-open screen
3. **Move Close**: Walk toward the door
4. **Automatic Opening**: When RSSI ≥ -70 dBm, door opens automatically
5. **Cooldown Period**: 5-second wait before next open attempt
6. **Repeat**: System ready for next approach

### Technical Flow

```
┌─────────────────────────────────────────────────────────┐
│ 1. Start Continuous BLE Scanning (every 1 second)      │
│    └─> LibDevModel.scanDevice(500ms)                   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 2. Receive Scan Results via Callback                   │
│    └─> LibDevModel.onScanOverSort()                    │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 3. Find Selected Door in Results                       │
│    └─> Match by devSn                                  │
│    └─> Extract RSSI value                              │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 4. Check RSSI Against Threshold                        │
│    └─> Current RSSI ≥ -70 dBm?                        │
└─────────────────────────────────────────────────────────┘
                         │
                   YES   │   NO
                    ▼    │    ▼
      ┌──────────────┐   │   Continue
      │ AUTO OPEN!   │   │   Scanning
      └──────────────┘   │
            │            │
            ▼            │
      ┌──────────────┐   │
      │ Start 5s     │   │
      │ Cooldown     │◄──┘
      └──────────────┘
            │
            ▼
      ┌──────────────┐
      │ Reset &      │
      │ Resume Scan  │
      └──────────────┘
```

---

## ⚙️ Configuration

### RSSI Threshold
```swift
private let rssiThreshold: Int = -70  // dBm
```

**Signal Quality Reference:**
- **-40 to -50 dBm**: Excellent (very close)
- **-50 to -65 dBm**: Good (normal opening range)
- **-65 to -75 dBm**: Fair (threshold zone)
- **-75 to -85 dBm**: Weak (too far)
- **-85 to -100 dBm**: Very Weak (out of range)

**Recommended Threshold**: `-70 dBm`
- Close enough for reliable opening
- Far enough to prevent premature triggering
- Typical range: 2-5 meters from device

### Scan Interval
```swift
private let scanInterval: TimeInterval = 1.0  // seconds
```
- Scans every 1 second for responsive detection
- Balance between battery life and responsiveness
- Quick 500ms scan per cycle

### Cooldown Duration
```swift
private let cooldownDuration: TimeInterval = 5.0  // seconds
```
- Prevents accidental double-opening
- Gives user time to pass through door
- Allows door mechanism to reset

---

## 🎨 UI Components

### 1. NFC Scanning Animation
- **3 Animated Rings**: Pulse effect to simulate NFC scanning
- **Color Coding**:
  - Blue: Scanning/searching
  - Green: In range and ready/opened
- **Center Icon**:
  - Radio waves: Scanning
  - Lock opening: Processing
  - Checkmark: Success

### 2. RSSI Display
- **Live RSSI Value**: Updates every scan (e.g., "-65 dBm")
- **Signal Bar**: Visual representation of signal strength
- **Quality Label**: "Excellent", "Good", "Fair", "Weak", "Very Weak"
- **Threshold Indicator**: Shows required signal level
- **In Range Badge**: Green checkmark when threshold met

### 3. Door Information Card
Shows:
- Door name
- Device serial number (devSn)
- MAC address (devMac)
- Card number (cardno)

### 4. Status Card
Displays:
- Current operation status
- Success/error messages
- Processing indicator
- Cooldown notification

### 5. Instructions Panel
Step-by-step guide for users:
1. Move closer to the door
2. When signal is strong enough
3. Door opens automatically
4. Wait for cooldown

---

## 🔧 Implementation Details

### File Structure
```
NextPro/
└── Views/
    └── Home/
        └── Tabs/
            ├── OpenDoorsTabContent.swift  (Updated: Added NFC button)
            └── AutoOpenDoorView.swift     (New: Main auto-open screen)
```

### Key Components

#### AutoOpenDoorView.swift
Main view implementing the NFC-style auto-open functionality.

**Published State:**
```swift
@State private var currentRSSI: Int = -100
@State private var isScanning = false
@State private var isWithinRange = false
@State private var hasOpenedDoor = false
@State private var statusMessage = "Initializing..."
@State private var isInCooldown = false
```

**Key Methods:**
- `startAutoOpenMonitoring()`: Initializes scanning and callbacks
- `stopAutoOpenMonitoring()`: Cleans up timers and resources
- `performScan()`: Executes BLE scan via SDK
- `handleScanResults()`: Processes scan results and updates RSSI
- `automaticOpenDoor()`: Triggers door opening when threshold met
- `startCooldown()`: Prevents immediate re-opening
- `resetForNextOpen()`: Resets state after cooldown

#### OpenDoorsTabContent.swift
Updated to include navigation button to AutoOpenDoorView.

**New Button:**
```swift
NavigationLink(destination: AutoOpenDoorView(selectedDoor: door)) {
    HStack(spacing: 12) {
        Image(systemName: "sensor.tag.radiowaves.forward.fill")
        Text("Open Door as NFC")
    }
    // ... styling
}
```

### SDK Integration

**Initialization:**
```swift
LibDevModel.onScanOverSort { devRssiArray in
    DispatchQueue.main.async {
        self.handleScanResults(devRssiArray)
    }
}
```

**Scanning:**
```swift
let scanTime: Int32 = 500  // 500ms quick scan
let result = LibDevModel.scanDevice(scanTime)
```

**Opening:**
```swift
doorManager.openSelectedDoor(selectedDoor)
// Uses LibDevModel.openDoor() internally
```

---

## 📊 State Machine

### States

1. **Initializing**
   - Setting up callbacks
   - Starting timers
   - Initial scan

2. **Scanning**
   - Periodic BLE scans
   - RSSI monitoring
   - UI updates

3. **In Range**
   - RSSI ≥ threshold
   - Ready to auto-open
   - Waiting for conditions

4. **Opening**
   - Auto-open triggered
   - SDK command sent
   - Processing feedback

5. **Cooldown**
   - 5-second wait
   - Prevents re-opening
   - Shows countdown

6. **Ready**
   - After cooldown
   - Reset complete
   - Resume scanning

### State Transitions
```
Initializing → Scanning
     ↓
Scanning ⟷ In Range
     ↓
In Range → Opening (when conditions met)
     ↓
Opening → Cooldown
     ↓
Cooldown → Ready
     ↓
Ready → Scanning (loop)
```

---

## 🚨 Error Handling

### Scan Failures
- Silent retry on next scan cycle
- No user notification for minor issues
- Continues monitoring

### Open Failures
- Displayed in status card
- Error message from DoorManager
- Manual retry possible (via cooldown)
- Auto-reset after error display

### Timeout Protection
- Handled by DoorManager (30s)
- Automatic state reset
- Returns to scanning mode

### Edge Cases

**Device Not Found:**
```
Status: "Door not detected - checking..."
RSSI: -100 dBm
Action: Continue scanning
```

**Signal Too Weak:**
```
Status: "Move closer to door (need X dBm stronger)"
RSSI: Current value shown
Action: User moves closer
```

**Processing Conflict:**
```
Condition: Already opening door
Action: Skip scan cycle, wait for completion
```

**Cooldown Active:**
```
Condition: Within 5s of last open
Action: Display cooldown message, block auto-open
```

---

## 🎯 Usage Instructions

### For Users

1. **Navigate to Open Doors Tab**
   - Tap "Open Doors" in bottom tab bar

2. **Select Your Door**
   - Tap on door from list
   - Check mark indicates selection

3. **Start NFC Auto-Open**
   - Tap green "Open Door as NFC" button
   - Screen transitions to auto-open view

4. **Approach the Door**
   - Watch RSSI indicator
   - Move closer until signal strengthens
   - Green = ready to open

5. **Automatic Opening**
   - Door opens automatically when close enough
   - No button press needed
   - Success confirmation shown

6. **Wait for Cooldown**
   - 5 seconds before next attempt
   - Prevents accidental re-opening
   - Timer shown in status

7. **Exit or Repeat**
   - Tap "Stop & Exit" to leave
   - Or stay for multiple entries

### For Developers

**Testing:**
```swift
// Check logs for scan results
📊 Found door 123456 with RSSI: -65 dBm (threshold: -70 dBm)
✅ Door in range! Auto-opening...
🔓 AUTO-OPENING DOOR: Signal strength sufficient
```

**Adjusting Threshold:**
```swift
// In AutoOpenDoorView.swift
private let rssiThreshold: Int = -70  // Change this value
// Lower (e.g., -80) = Opens from farther away
// Higher (e.g., -60) = Requires closer proximity
```

**Adjusting Scan Rate:**
```swift
private let scanInterval: TimeInterval = 1.0  // seconds
// Faster = more responsive, more battery usage
// Slower = less responsive, less battery usage
```

**Adjusting Cooldown:**
```swift
private let cooldownDuration: TimeInterval = 5.0
// Shorter = can open again sooner
// Longer = more protection against double-open
```

---

## 🔋 Performance Considerations

### Battery Impact
- **Scanning**: Moderate impact (BLE scan every 1s)
- **Duration**: Only active when screen open
- **Auto-stop**: Scanning stops when view dismissed
- **Optimization**: 500ms quick scans vs continuous

### CPU Usage
- **Timer**: Single 1-second timer
- **Callbacks**: Async on main thread
- **UI Updates**: Throttled by scan interval
- **Minimal overhead**: State changes only

### Memory
- **Lightweight**: No data caching
- **Clean lifecycle**: Timers properly invalidated
- **No leaks**: Weak self references in closures

---

## 🐛 Troubleshooting

### Issue: Door Not Auto-Opening

**Check:**
1. Signal strength displayed?
2. RSSI above threshold?
3. Already in cooldown?
4. Door selected correctly?
5. Bluetooth permissions granted?

**Solution:**
- Move closer to door
- Check Xcode console logs
- Verify device credentials
- Ensure Bluetooth is on

### Issue: Opens Too Early/Late

**Solution:**
```swift
// Adjust threshold in AutoOpenDoorView.swift
private let rssiThreshold: Int = -70

// For earlier opening: -80 (farther away)
// For later opening: -60 (closer required)
```

### Issue: Multiple Opens

**Cause:** Cooldown not working

**Check:**
- Console logs for cooldown messages
- Verify timer not being invalidated early

**Solution:**
```swift
// Increase cooldown duration
private let cooldownDuration: TimeInterval = 10.0
```

### Issue: Not Detecting Door

**Check:**
1. Device powered on?
2. Correct devSn configured?
3. Device in BLE range?
4. SDK initialized properly?

**Debug:**
```
Check logs for:
📊 Found door XXX with RSSI: -XX dBm
If not appearing, device is not advertising
```

---

## 🔐 Security Considerations

### Authentication
- Uses existing eKey authentication
- No bypass of security
- Same credentials as manual open

### Cooldown Protection
- Prevents rapid-fire opening
- Time-based rate limiting
- Configurable duration

### Range Control
- RSSI threshold prevents remote opening
- User must be physically close
- Typical effective range: 2-5 meters

### Session Management
- Scanning stops when view dismissed
- No background processing
- Clean resource cleanup

---

## 📈 Future Enhancements

### Potential Features

1. **Adjustable Threshold**
   - User setting for RSSI threshold
   - Per-door configuration
   - Distance presets (Close/Medium/Far)

2. **Background Mode**
   - Open doors with app in background
   - iOS location-based triggers
   - Push notification on open

3. **Multiple Door Support**
   - Auto-select nearest door
   - Switch between doors automatically
   - Priority ordering

4. **Analytics**
   - Track usage patterns
   - Optimize threshold based on success rate
   - Battery usage monitoring

5. **Haptic Feedback**
   - Vibration on successful open
   - Different patterns for states
   - Audio cues option

6. **Geofencing**
   - Start scanning when near location
   - Stop when far away
   - Battery optimization

---

## 📝 Code Documentation

### Main Functions

#### startAutoOpenMonitoring()
```swift
private func startAutoOpenMonitoring()
```
**Purpose**: Initialize scanning and start monitoring  
**Called**: On view appear  
**Actions**:
- Sets up SDK callback
- Starts scan timer
- Performs initial scan
- Resets state variables

#### stopAutoOpenMonitoring()
```swift
private func stopAutoOpenMonitoring()
```
**Purpose**: Clean up resources and stop scanning  
**Called**: On view disappear, manual exit  
**Actions**:
- Invalidates timers
- Stops scanning
- Clears state

#### performScan()
```swift
private func performScan()
```
**Purpose**: Execute single BLE scan cycle  
**Called**: By timer every 1 second  
**Conditions**: Not processing, not in cooldown  
**SDK Call**: `LibDevModel.scanDevice(500)`

#### handleScanResults(_ devRssiArray: NSMutableArray?)
```swift
private func handleScanResults(_ devRssiArray: NSMutableArray?)
```
**Purpose**: Process scan callback results  
**Called**: By SDK callback  
**Actions**:
- Find selected door in results
- Update RSSI value
- Check threshold
- Trigger auto-open if conditions met

#### automaticOpenDoor()
```swift
private func automaticOpenDoor()
```
**Purpose**: Trigger automatic door opening  
**Called**: When RSSI threshold met  
**Actions**:
- Calls DoorManager.openSelectedDoor()
- Sets hasOpenedDoor flag
- Starts cooldown timer

#### startCooldown()
```swift
private func startCooldown()
```
**Purpose**: Begin cooldown period  
**Duration**: 5 seconds  
**Actions**:
- Sets isInCooldown flag
- Schedules resetForNextOpen()

#### resetForNextOpen()
```swift
private func resetForNextOpen()
```
**Purpose**: Reset state after cooldown  
**Called**: After cooldown timer expires  
**Actions**:
- Clears cooldown flag
- Resets opened flag
- Resets DoorManager state
- Resumes normal scanning

---

## 🎓 Learning Resources

### BLE Concepts
- **RSSI**: Received Signal Strength Indicator (dBm)
- **dBm**: Decibel-milliwatts (logarithmic scale)
- **Proximity**: Estimated based on RSSI
- **Scanning**: Discovery of nearby BLE devices

### iOS Development
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming
- **Timer**: Scheduled/recurring tasks
- **NavigationStack**: Modern navigation

### DoorMaster SDK
- **scanDevice()**: Scan for devices
- **onScanOverSort()**: Scan results callback
- **openDoor()**: Open door command
- **onControlOver()**: Operation result callback

---

## 📞 Support

### Common Questions

**Q: Why -70 dBm threshold?**  
A: Balance between convenience and security. Close enough for intent, far enough to prevent premature opening.

**Q: Can I use this with multiple doors?**  
A: Yes, select different door from list before starting NFC mode.

**Q: Battery drain concern?**  
A: Minimal - only scans when screen active, stops automatically on exit.

**Q: Works with all door types?**  
A: Yes, as long as door is in DoorMaster system with BLE support.

**Q: Why 5-second cooldown?**  
A: Prevents accidental double-opening, allows door mechanism to reset.

---

## 📄 License & Credits

**Feature**: NFC-Style Auto-Open Door  
**Version**: 1.0  
**Date**: November 2025  
**Platform**: iOS (SwiftUI)  
**SDK**: DoorMaster BLE SDK

---

## 🎉 Conclusion

The NFC-style auto-open feature provides a seamless, hands-free door opening experience similar to NFC tap-to-open, using BLE RSSI proximity detection. It's secure, user-friendly, and highly configurable for different use cases.

**Key Benefits:**
✅ No button press required  
✅ Natural approach-and-open UX  
✅ Real-time signal monitoring  
✅ Safety cooldown period  
✅ Beautiful visual feedback  
✅ Enterprise-ready security  

**Happy Opening! 🚪✨**

