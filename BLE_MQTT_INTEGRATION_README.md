# BLE + MQTT Door Opening Integration

## 🎯 Overview

This integration combines **BLE (Bluetooth Low Energy)** door control with **MQTT confirmation** to provide reliable, verified door opening with real-time user feedback.

### Key Benefits
✅ **Double confirmation** - BLE command + MQTT verification  
✅ **Visual feedback** - 3-stage animation shows exact status  
✅ **Error detection** - Know if door actually opened or just command sent  
✅ **Timeout protection** - 10-second MQTT timeout with warning  

---

## 🚀 Quick Start

### 1. What Changed

**Three files were modified:**

#### `DoorManager.swift`
- Added MQTT confirmation tracking
- New status: `.bleSuccess` (BLE sent) and `.mqttConfirmed` (door opened)
- 10-second MQTT timeout with warning
- New method: `handleMQTTDoorConfirmation()`

#### `MQTTManager.swift`
- Forwards MQTT messages to `DoorManager`
- Calls `handleMQTTDoorConfirmation()` when door event received

#### `OpenDoorEndUserView.swift`
- 3 new animation stages (blue → orange → green)
- Icon changes: arrow → antenna → checkmark
- Progress ring shows status visually

### 2. How It Works

```
User Taps Button
      ↓
🔵 Blue Animation (BLE Sending)
      ↓
🟠 Orange Animation (BLE Success, Waiting MQTT)
      ↓
🟢 Green Animation (MQTT Confirmed - Door Opened!)
      ↓
Reset after 3 seconds
```

---

## 📊 Status Flow

| Status | Color | Icon | Meaning | Duration |
|--------|-------|------|---------|----------|
| `.starting` | 🔵 Blue | ➡️ | BLE command initiated | 0-3s |
| `.bleSuccess` | 🟠 Orange | 📡 | BLE succeeded, waiting MQTT | 1-10s |
| `.mqttConfirmed` | 🟢 Green | ✅ | Door actually opened | 3s |
| `.failure` | 🔴 Red | ❌ | Operation failed | 3s |

---

## 🔍 Console Logs

### ✅ Success Flow
```
🚪 Opening door: Front Door
📤 openDoor() called, result: 0
✅ SUCCESS: BLE door open command sent!
🎨 Animation: Opening Start
🎨 Animation: BLE Success (waiting for MQTT)
📨 MQTT Message Received on up/4283847520/rtdata
📥 MQTT Confirmation received for door: 4283847520, verified: 200
✅ MQTT CONFIRMED: Door 4283847520 opened successfully!
🎨 Animation: MQTT Confirmed - Door Opened!
🔄 Resetting DoorManager state...
```

### ⚠️ MQTT Timeout
```
🚪 Opening door: Front Door
✅ SUCCESS: BLE door open command sent!
🎨 Animation: BLE Success (waiting for MQTT)
[10 seconds pass...]
⚠️ MQTT confirmation timeout - door may or may not have opened
```

### ❌ BLE Failure
```
🚪 Opening door: Front Door
📤 openDoor() called, result: 0
❌ CONNECTION FAILED
🎨 Animation: Failure
```

---

## 🛠️ Implementation Details

### DoorManager Key Changes

```swift
// New event statuses
enum Status {
    case starting       // Door open initiated
    case bleSuccess     // BLE command succeeded
    case mqttConfirmed  // MQTT confirmed door opened
    case failure        // Operation failed
}

// New method to handle MQTT confirmation
func handleMQTTDoorConfirmation(devSn: String, verified: Int) {
    // Validates device SN matches
    // Checks verified == 200 for success
    // Emits .mqttConfirmed or .failure
    // Cancels MQTT timeout timer
}
```

### MQTTManager Integration

```swift
func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
    // Decode DoorEvent JSON
    let event = try JSONDecoder().decode(DoorEvent.self, from: data)
    
    // Forward to DoorManager
    DoorManager.shared.handleMQTTDoorConfirmation(
        devSn: event.SN, 
        verified: first.verified
    )
}
```

### OpenDoorEndUserView Animations

```swift
.onReceive(doorManager.$doorEvent) { event in
    switch event.status {
    case .starting:
        animateOpeningStart()      // 🔵 Blue
    case .bleSuccess:
        animateBLESuccess()        // 🟠 Orange
    case .mqttConfirmed:
        animateMQTTConfirmed()     // 🟢 Green
    case .failure:
        animateFailure()           // 🔴 Red
    }
}
```

---

## 📱 MQTT Message Format

**Topic:** `up/{deviceSN}/rtdata`

**Expected Message:**
```json
{
  "SN": "4283847520",
  "resource": "events",
  "data": [{
    "doorID": 1,
    "verified": 200,
    "type": 1,
    "time": "2025-11-13T12:34:56"
  }]
}
```

**Verification Codes:**
- `200` = Success ✅ (door opened)
- Other = Failure ❌

---

## 🧪 Testing

### Test 1: Normal Success
1. Ensure MQTT connected
2. Tap door button
3. Expect: Blue → Orange → Green → Reset

### Test 2: MQTT Offline
1. Disconnect WiFi
2. Tap door button
3. Expect: Blue → Orange → Warning after 10s

### Test 3: BLE Failure
1. Turn off Bluetooth
2. Tap door button
3. Expect: Red immediately

### Test 4: Multiple Taps
1. Tap button rapidly 3 times
2. Expect: Previous operations cancelled, only last processes

---

## 🚨 Troubleshooting

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Stuck on 🔵 blue | BLE timeout | Check Bluetooth enabled |
| Stuck on 🟠 orange | MQTT not responding | Check WiFi/MQTT connection |
| Immediate 🔴 red | Wrong credentials | Verify door configuration |
| No animation | Event not clearing | Check `clearDoorEvent()` call |

### Debug Checklist

**If stuck on blue:**
- [ ] Bluetooth enabled?
- [ ] Device in range?
- [ ] Door credentials correct?

**If stuck on orange:**
- [ ] MQTT connected?
- [ ] Subscribed to `up/{SN}/rtdata`?
- [ ] WiFi working?
- [ ] Device SN matches?

**If immediate red:**
- [ ] Check console for error code
- [ ] Verify eKey, cardno, devMac
- [ ] Try different door

---

## ⚙️ Configuration

### MQTT Setup
```swift
// In your view's .task or .onAppear
mqttManager.connect()
for door in doorStorage.doors {
    mqttManager.subscribeToDevice(door.devSn)
}
```

### Door Model Requirements
```swift
struct DoorModelUser {
    let devSn: String      // Must match MQTT topic
    let devMac: String     // For BLE connection
    let devType: Int32     // Device type
    let eKey: String       // Encryption key
    let cardno: String     // Card number
    let name: String       // Display name
}
```

---

## ⏱️ Timing Expectations

| Stage | Expected Time |
|-------|---------------|
| Button tap → Blue | < 0.1s |
| Blue → Orange (BLE) | 0.5-3s |
| Orange → Green (MQTT) | 1-5s |
| Green → Reset | 3s |
| **Total** | **4.6-11s** |

### Timeout Settings
- **MQTT Confirmation:** 10 seconds
- **Success Reset:** 3 seconds
- **Error Reset:** 10 seconds

---

## 🔄 Component Communication

```
User (UI)
   ↓
OpenDoorEndUserView
   ↓
DoorManager.openSelectedDoor()
   ↓
LibDevModel (BLE SDK)
   ↓
[BLE Success]
   ↓
DoorManager publishes .bleSuccess
   ↓
[Wait for MQTT...]
   ↓
Device → MQTT Broker
   ↓
MQTTManager receives message
   ↓
DoorManager.handleMQTTDoorConfirmation()
   ↓
DoorManager publishes .mqttConfirmed
   ↓
OpenDoorEndUserView updates animation
```

---

## 📝 Code Examples

### Opening a Door

```swift
// In your UI
Button(action: {
    doorManager.openSelectedDoor(door)
}) {
    // Your door card UI
}
```

### Listening to Events

```swift
.onReceive(doorManager.$doorEvent.compactMap({ $0 })) { event in
    guard event.devSn == door.devSn else { return }
    
    switch event.status {
    case .starting:
        // Show blue loading
    case .bleSuccess:
        // Show orange "waiting for confirmation"
    case .mqttConfirmed:
        // Show green success
    case .failure:
        // Show red error
    }
    
    // Clear event after processing
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        doorManager.clearDoorEvent()
    }
}
```

### Manually Checking Status

```swift
print("Current status: \(doorManager.statusMessage)")
print("Last result: \(doorManager.lastResult ?? "none")")
print("Error: \(doorManager.errorMessage ?? "none")")
print("Processing: \(doorManager.isProcessing)")
```

---

## 🎨 UI/UX Guidelines

### Animation Timing
- Use `.easeInOut` for smooth transitions
- Progress ring fills gradually (0% → 50% → 85% → 100%)
- Icon changes should be instant
- Color transitions should be smooth (0.3s duration)

### User Feedback
- **Blue:** "Sending command..."
- **Orange:** "Command sent, confirming..."
- **Green:** "Door opened successfully!"
- **Red:** "Failed: [error message]"

### Accessibility
- Ensure color blind users can distinguish states
- Add haptic feedback for success/failure
- Screen reader announcements for status changes

---

## 🔐 Security Considerations

1. **MQTT Topic Validation**
   - Verify `event.SN` matches expected device
   - Only process events for currently opening door

2. **Timeout Protection**
   - 10-second MQTT timeout prevents indefinite waiting
   - Clears sensitive state after operations

3. **Credential Safety**
   - Never log eKey or sensitive door data
   - Use secure storage for door configurations

---

## 📈 Future Enhancements

- [ ] Add retry logic for failed operations
- [ ] Show MQTT connection status indicator
- [ ] Add haptic feedback for different states
- [ ] Display estimated time until door opens
- [ ] Queue multiple door open requests
- [ ] Add analytics for success/failure rates
- [ ] Background notifications when door opens
- [ ] Support for multiple simultaneous doors

---

## 🐛 Known Issues

None currently. If you encounter issues:
1. Check console logs
2. Verify MQTT connection
3. Confirm door credentials
4. Test with different door
5. Restart app if needed

---

## 📞 Support

For issues or questions:
1. Check console logs for error codes
2. Review troubleshooting section
3. Verify configuration checklist
4. Check MQTT message format

---

## ✅ Acceptance Criteria

Before production deployment:
- [ ] All test cases pass
- [ ] < 11 seconds total time
- [ ] > 90% reliability over 10 attempts
- [ ] No crashes in any scenario
- [ ] Proper cleanup (no memory leaks)
- [ ] UI smooth and responsive
- [ ] Logs accurate and helpful
- [ ] Error messages user-friendly

---

## 📄 Version History

**v1.0** (2025-11-13)
- Initial BLE + MQTT integration
- 3-stage animation system
- MQTT confirmation timeout
- Comprehensive error handling

---

## 🙏 Credits

Integration design and implementation for NextPro door management system.

