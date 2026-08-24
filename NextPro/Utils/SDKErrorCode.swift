//
//  SDKErrorCode.swift
//  NextPro
//

import Foundation

//Maps a Lib DevModel SDK return code to its human-readable reason, per
enum SDKErrorCode {
    private static let reasons: [Int: String] = [
        0: "Success",
        -1: "The user does not have a card number, please assign the card number first",
        -2: "The devSn cannot be empty",
        -3: "devMac cannot be empty",
        -4: "eKey cannot be empty",
        -5: "devType value cannot be empty or undefined",
        -6: "privilege value is invalid (cannot be empty or undefined when devType is all-in-one)",
        -7: "The openMode value is not defined",
        -8: "verified value not defined (cannot be empty or undefined when devType is all-in-one)",
        -9: "startDate has the wrong format",
        -10: "endDate has the wrong format",
        -11: "useCount cannot be empty (if the verified validation mode is 2 or 3)",
        -12: "The operation value is not defined",
        -13: "This operation/function is not open",
        -14: "Illegal time to open the door — outside the validity period",
        -15: "More than the set door opening distance",
        -16: "Wiegand format error — currently only 26 and 34 are supported",
        -17: "Door opening duration out of range — only 1-254 seconds",
        -18: "Electrical switch parameter value error — only 0 (electric lock control) or 1 (electrical switch) supported",
        -19: "The password must be 6 digits",
        -20: "The card number list cannot be empty",
        -21: "Batch card operation is up to 50 card numbers each time",
        -22: "The card number data sent is missing",
        -23: "The incoming callback is empty",
        -25: "The scanTime is empty",
        -26: "Fingerprint data is empty",
        -27: "Fingerprint model data error",
        -28: "Fingerprint user ID error — the number of IDs cannot exceed 50, each ID occupies no more than 4 bytes",
        -93: "Error in incoming parameter",
        -101: "Mobile phone Bluetooth is not on",
        -103: "The function for the callback object does not exist",
        -104: "Open the door failed",
        -105: "The equipment has no response",
        -106: "The equipment is not nearby",
        -107: "Bluetooth is in use, please try again later",
        -108: "Error in sec scan time unit",
        -109: "The sec scan time value can only range from 1-60",
        -110: "The device already has a superuser — you must initialize the device to add it",
        -111: "Device MAC address is incorrect",
        -118: "One-key door open — no permission device",
        -119: "One-key door open — no device scanned",
        -120: "One-key door open — device with permission not matched",
        -121: "One-key door open — a scan is already in progress",
        -122: "Open the door — the door is already open",
        1: "A CRC calibration error",
        2: "The communication command is in the wrong format",
        3: "Device management password error",
        4: "Power error",
        5: "Error reading and writing data",
        6: "The user is not registered in the device",
        7: "Random number detection error",
        8: "Error obtaining a random number",
        9: "Command length does not match",
        10: "The Add Device mode is not entered",
        11: "devKey detection error",
        12: "The function is not supported",
        13: "Insufficient equipment capacity",
        14: "There is no card number in the equipment",
        15: "Error getting the card number length",
        16: "Error getting the data length",
        17: "No open door record",
        19: "Host serial port communication timeout",
        56: "Entering the fingerprint",
        57: "Failed to register fingerprint",
        58: "The fingerprint storage is full",
        59: "Receiving fingerprint module data timeout / fingerprint module exception",
        60: "No fingerprint collected — timeout",
        61: "The fingerprint already exists"
    ]

    //Returns the reason text for `code`, falling back to a generic message with the
    static func reason(for code: Int) -> String {
        reasons[code] ?? "Unknown error (code \(code))"
    }
}
