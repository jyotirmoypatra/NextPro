# 🚪 Door Opening Guide - Using DoorMasterSDK

## ✅ What's Been Implemented

I've created a complete door opening system in the **Open Doors** tab with:

1. **DoorManager.swift** - Handles all SDK operations
2. **OpenDoorsTabContent.swift** - Beautiful UI with door controls
3. **Hardcoded values** - Ready for testing (just update your real values)

---

## 📋 Setup Instructions

### Step 1: Update Hardcoded Values

Open `/NextPro/BLE/DoorManager.swift` and update these values in the `DoorConfig` struct:

```swift
struct DoorConfig {
    // Device Information
    static let devSn = "123456"              // ← Your device serial number
    static let devMac = "AA:BB:CC:DD:EE:FF"  // ← Your device BLE MAC address
    static let devType: Int32 = 1            // ← 1=reader, 2=all-in-one, 5=BLE module
    
    // User Credentials
    static let eKey = "YOUR_ELECTRONIC_KEY_HERE"  // ← Your electronic key from server
    static let cardno = "1234567890"         // ← Your NFC card number
    
    // Optional Settings (can keep defaults)
    static let privilege: Int32 = 4          // 4=normal user
    static let verified: Int32 = 1           // 1=by date
    static let startDate = "20240101000000"
    static let endDate = "20251231235959"
}
```

### Step 2: Get Your Real Values

#### Device Serial Number (`devSn`):
- Check your door device label/sticker
- Or contact your door system administrator
- Format: Usually 6-8 digits (e.g., "123456", "DM001234")

#### Device MAC Address (`devMac`):
- The Bluetooth MAC address of your door device
- Format: `AA:BB:CC:DD:EE:FF` (6 pairs of hex digits)
- You can scan for devices in the app to see available MAC addresses

#### Electronic Key (`eKey`):
- Provided by your door system server/backend
- This is a unique encrypted key for your user account
- Contact your system administrator to get this

#### Card Number (`cardno`):
- The UID of your NFC card
- If you have a working NFC card detection, use that UID
- Format: Usually 8-10 digits

#### Device Type (`devType`):
According to the SDK documentation:
- `1` = Access control reader (门禁读头)
- `2` = All-in-one device (一体机)
- `3` = Elevator control reader (梯控读头)
- `4` = Wireless network lock (无线联网锁)
- `5` = Bluetooth small module (蓝牙小模块)
- `6` = Access controller (门禁控制器)

### Step 3: Build and Run

1. Open the project in Xcode
2. Build and run on a real device (⌘R)
3. Navigate to **Home → Open Doors** tab

---

## 🎮 Using the App

### Main Interface

The Open Doors tab has:

1. **Status Card** - Shows current operation status
2. **Configuration Card** - Displays your hardcoded values (tap to expand)
3. **Control Buttons**:
   - **Open Door** - Direct door opening with hardcoded values
   - **Scan & Open Nearest** - Scans nearby devices and opens closest one
   - **Scan for Devices** - Manual scan to discover available devices
4. **Instructions** - Quick help guide

### Button Functions

#### 🔑 Open Door
- Uses your hardcoded credentials directly
- Attempts to connect to device and open door
- Best for when you know device is nearby

#### 📡 Scan & Open Nearest
- Scans for nearby devices
- Opens the closest device automatically
- Useful when you have multiple doors

#### 🔍 Scan for Devices
- Just scans without opening
- Shows found devices in console
- Good for discovering device MAC addresses

---

## 📊 Console Logs

Watch Xcode console for detailed logs:

### Successful Open:
```
📲 NFC: start() called
🚪 Opening door with hardcoded values...
📋 Door Config:
   devSn: 123456
   devMac: AA:BB:CC:DD:EE:FF
   devType: 1
   eKey: YOUR_KEY...
   cardno: 1234567890
📤 openDoor() called, result: 0
⏳ Waiting for callback result...
📥 Control result received:
   Return code: 0
✅ SUCCESS: Door opened!
```

### Failed (Device Not Found):
```
🚪 Opening door with hardcoded values...
📤 openDoor() called, result: 0
⏳ Waiting for callback result...
📥 Control result received:
   Return code: 2
❌ DEVICE NOT FOUND
```

### Common Error Codes:
- `0` = ✅ Success
- `1` = ⏱️ Timeout (device didn't respond)
- `2` = ❌ Device not found (not in range or wrong MAC)
- `3` = ❌ Connection failed (BLE connection issue)
- `4` = ❌ Authentication failed (wrong eKey or permissions)
- `5` = ❌ Invalid parameters (check your config)

---

## 🐛 Troubleshooting

### Issue 1: "Device Not Found"

**Possible Causes:**
- Device is not nearby (BLE range ~10-30 meters)
- Wrong MAC address configured
- Device is powered off
- Bluetooth is off on phone

**Solutions:**
1. ✅ Check Bluetooth is ON
2. ✅ Move closer to door device
3. ✅ Use "Scan for Devices" to discover actual MAC
4. ✅ Verify device is powered and working
5. ✅ Check MAC address format (needs colons: `AA:BB:CC:DD:EE:FF`)

### Issue 2: "Authentication Failed"

**Possible Causes:**
- Wrong eKey
- Wrong devSn
- Expired credentials
- Insufficient permissions

**Solutions:**
1. ✅ Verify eKey from server/admin
2. ✅ Check devSn matches device label
3. ✅ Confirm dates (startDate/endDate) are valid
4. ✅ Check privilege level (should be 4 for normal user)

### Issue 3: "Connection Failed"

**Possible Causes:**
- Device is paired to another phone
- BLE connection timeout
- Device firmware issue

**Solutions:**
1. ✅ Unpair device from Bluetooth settings
2. ✅ Restart Bluetooth on phone
3. ✅ Try multiple times
4. ✅ Restart app
5. ✅ Power cycle the door device if possible

### Issue 4: "Timeout"

**Possible Causes:**
- Weak signal
- Device not responding
- Too far from device

**Solutions:**
1. ✅ Move very close to device (<5 meters)
2. ✅ Try again (sometimes first attempt fails)
3. ✅ Use "Scan & Open Nearest" instead
4. ✅ Check device is operational (test with physical card)

---

## 🔍 Finding Your Device

### Method 1: Use "Scan for Devices" Button

1. Go to Open Doors tab
2. Tap "Scan for Devices"
3. Check Xcode console for results:
```
🔍 Manual device scan...
📊 Scan results: 3 devices found
   Device 1: {devSn: 123456, rssi: -65}
   Device 2: {devSn: 789012, rssi: -72}
   Device 3: {devSn: 345678, rssi: -80}
```

### Method 2: Use BLEManager Scan

The existing BLE scanner in the app shows:
- Device names
- MAC addresses
- Signal strength (RSSI)

---

## 📱 SDK Functions Used

### Primary Functions:
- `LibDevModel.initBluetoothNotShowPower()` - Initialize SDK
- `LibDevModel.openDoor()` - Direct door opening
- `LibDevModel.scanAndOpenDoor()` - Scan and open nearest
- `LibDevModel.scanDevice()` - Manual device scan

### Callbacks:
- `LibDevModel.onControlOver()` - Get operation results
- `LibDevModel.onBluetoothStateOver()` - Monitor Bluetooth state
- `LibDevModel.onScanOverSort()` - Get scan results

---

## 📖 According to SDK Documentation

From the DoorMasterSDK documentation:

### Required Parameters:
✅ `devSn` - Device serial number (必须)  
✅ `devMac` - Device MAC address (必须)  
✅ `devType` - Device type (必须)  
✅ `eKey` - Electronic key (必须)

### Optional Parameters:
- `cardno` - Card number (for card-based opening)
- `privilege` - User privilege level
- `verified` - Verification method (1=date, 2=count, 3=both)
- `startDate` / `endDate` - Validity period
- `useCount` - Number of allowed uses

### Opening Methods:

**Method 1: Direct Open (`openDoor`)**
```swift
LibDevModel.openDoor(devModel)
```
- Fast and simple
- Requires device to be nearby
- Uses provided credentials

**Method 2: Scan and Open (`scanAndOpenDoor`)**
```swift
LibDevModel.scanAndOpenDoor(devList, timeout: 5000) { ret, msgDict in
    // Handle result
}
```
- Scans first, then opens
- Opens nearest device with permissions
- Good for multiple doors

---

## 🎯 Next Steps

### Testing Checklist:

- [ ] Updated `devSn` with real value
- [ ] Updated `devMac` with real value
- [ ] Updated `devType` with correct type
- [ ] Got `eKey` from server/admin
- [ ] Updated `cardno` with card UID
- [ ] Bluetooth is ON
- [ ] App is running on real device
- [ ] Near the door device (<10 meters)
- [ ] Tried "Open Door" button
- [ ] Checked console logs
- [ ] Verified door opened successfully

### If Successful:
🎉 Great! You can now:
- Integrate with saved NFC cards
- Add multiple door support
- Implement door list from server
- Add user authentication

### If Not Working:
📞 Gather this info for support:
1. All console logs
2. Your hardcoded values (hide eKey)
3. Device type and model
4. Error codes received
5. Distance from door
6. Bluetooth scan results

---

## 💡 Tips

1. **Start Simple**: Test with just "Open Door" button first
2. **Check Logs**: Always watch console for detailed info
3. **Signal Strength**: Closer is better (RSSI > -70 is good)
4. **Multiple Attempts**: First attempt may fail, try again
5. **Device Ready**: Ensure door device is powered and working
6. **Permissions**: App needs Bluetooth permissions enabled

---

## 🔐 Security Notes

- ⚠️ **Never commit real eKey values** to version control
- ⚠️ **Hardcoded values are for testing only**
- ⚠️ In production, fetch credentials from secure server
- ⚠️ Store eKeys in Keychain, not in code
- ⚠️ Implement proper user authentication

---

## 📞 Need Help?

**Check:**
1. Console logs (most errors are explained there)
2. SDK documentation PDF (in project folder)
3. Device manufacturer support
4. System administrator for credentials

**Common Questions:**

**Q: Can I use this without eKey?**
A: No, eKey is required by the SDK.

**Q: Where do I get the eKey?**
A: From your door system's server/backend or admin.

**Q: Can I use NFC card UID instead of BLE?**
A: The SDK uses BLE for communication. Card UID is sent as data.

**Q: Will this work on simulator?**
A: No, requires real device with Bluetooth.

**Q: How far can I be from the door?**
A: Typically 10-30 meters for BLE, but closer is better.

---

**Last Updated**: November 10, 2025  
**SDK Version**: 1.9  
**Status**: ✅ Ready for testing with real credentials

