//
//  NFCTagReaderService.swift
//  NextPro
//
//  Simple tag reader that exposes UID and tag type
//

import Foundation
import CoreNFC
import Combine

final class NFCTagReaderService: NSObject, ObservableObject {
	@Published var isScanning: Bool = false
	@Published var lastUIDHex: String?
	@Published var lastTagType: String?
	@Published var statusMessage: String = "Ready"
	@Published var errorMessage: String?
	@Published var timestamp: Date?
	
	private var session: NFCTagReaderSession?
	
	func start() {
		print("📲 NFC: start() called")
		guard NFCTagReaderSession.readingAvailable else {
			statusMessage = "NFC not available on this device"
			errorMessage = statusMessage
			print("❌ NFC: readingAvailable == false (device or iOS version not supported)")
			return
		}
		errorMessage = nil
		statusMessage = "Hold iPhone near the NFC card"
		lastUIDHex = nil
		lastTagType = nil
		timestamp = nil
		
		//session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self, queue: .main)
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self, queue: .main)

		session?.alertMessage = "Hold your iPhone near the NFC card"
		session?.begin()
		print("🔎 NFC: session.begin()")
		isScanning = true
	}
	
	func stop() {
		print("🛑 NFC: stop() – invalidating session")
		session?.invalidate()
		isScanning = false
	}
}

extension NFCTagReaderService: NFCTagReaderSessionDelegate {
	func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
		statusMessage = "Scanning..."
		print("✅ NFC: session did become active")
	}
	
	func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
		isScanning = false
		if let nfcErr = error as? NFCReaderError {
			print("❌ NFC: session invalidated – code=\(nfcErr.code.rawValue) (\(nfcErr.code)) message=\(nfcErr.localizedDescription)")
			if nfcErr.code == .readerSessionInvalidationErrorUserCanceled {
				statusMessage = "Cancelled"
				return
			}
		} else {
			print("❌ NFC: session invalidated – \(error.localizedDescription)")
		}
		errorMessage = error.localizedDescription
		statusMessage = "Error: \(error.localizedDescription)"
	}
	
	func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
		guard let first = tags.first else {
			print("⚠️ NFC: didDetect called with 0 tags")
			session.invalidate(errorMessage: "No tag detected")
			return
		}
		print("🎯 NFC: tag detected, attempting connect…")
		session.connect(to: first) { [weak self] err in
			if let err = err {
				print("❌ NFC: connect error – \(err.localizedDescription)")
				session.invalidate(errorMessage: err.localizedDescription)
				return
			}
			guard let self = self else { return }
			let (uidHex, typeStr): (String?, String)
			switch first {
			case .miFare(let tag):
				uidHex = tag.identifier.map { String(format: "%02X", $0) }.joined()
				typeStr = "MiFare"
				print("📇 NFC: MiFare UID=\(uidHex ?? "nil")")
			case .iso15693(let tag):
				uidHex = tag.identifier.map { String(format: "%02X", $0) }.joined()
				typeStr = "ISO15693"
				print("📇 NFC: ISO15693 UID=\(uidHex ?? "nil")")
			case .iso7816(let tag):
				uidHex = tag.identifier.map { String(format: "%02X", $0) }.joined()
				typeStr = "ISO7816"
				print("📇 NFC: ISO7816 UID=\(uidHex ?? "nil")")
			case .feliCa(let tag):
				uidHex = tag.currentIDm.map { String(format: "%02X", $0) }.joined()
				typeStr = "FeliCa"
				print("📇 NFC: FeliCa IDm=\(uidHex ?? "nil")")
			@unknown default:
				uidHex = nil
				typeStr = "Unknown"
				print("⚠️ NFC: Unknown tag type")
			}
			DispatchQueue.main.async {
				self.lastUIDHex = uidHex
				self.lastTagType = typeStr
				self.timestamp = Date()
				self.statusMessage = uidHex != nil ? "Tag detected" : "Unsupported tag"
				print("✅ NFC: Tag processed – type=\(typeStr) uid=\(uidHex ?? "nil")")
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				print("ℹ️ NFC: invalidating session after detection")
				session.invalidate()
			}
		}
	}
}
