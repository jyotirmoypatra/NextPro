////
////  NFCCardModel.swift
////  NextPro
////
////  Model for NFC card with Keychain-backed storage
////
//
//import Foundation
//import Security
//import Combine
//
//struct NFCCardModel: Identifiable, Codable {
//	let id: UUID
//	var name: String
//	let cardUID: String
//	let cardType: String
//	let dateAdded: Date
//	
//	init(id: UUID = UUID(), name: String, cardUID: String, cardType: String) {
//		self.id = id
//		self.name = name
//		self.cardUID = cardUID
//		self.cardType = cardType
//		self.dateAdded = Date()
//	}
//}
//
//final class CardStorageManager: ObservableObject {
//	static let shared = CardStorageManager()
//	@Published var savedCards: [NFCCardModel] = []
//	
//	private let keychainKey = "com.utl.NextPro.savedCards"
//	
//	init() {
//		loadCards()
//	}
//	
//	func saveCard(_ card: NFCCardModel) {
//		if !savedCards.contains(where: { $0.cardUID == card.cardUID }) {
//			savedCards.append(card)
//			persistToKeychain()
//			print("💾 Card saved: \(card.name) UID=\(card.cardUID)")
//		}
//	}
//	
//	func removeCard(_ card: NFCCardModel) {
//		savedCards.removeAll { $0.id == card.id }
//		persistToKeychain()
//	}
//	
//	private func persistToKeychain() {
//		guard let data = try? JSONEncoder().encode(savedCards) else { return }
//		let query: [String: Any] = [
//			kSecClass as String: kSecClassGenericPassword,
//			kSecAttrAccount as String: keychainKey,
//			kSecValueData as String: data
//		]
//		SecItemDelete(query as CFDictionary)
//		SecItemAdd(query as CFDictionary, nil)
//	}
//	
//	private func loadCards() {
//		let query: [String: Any] = [
//			kSecClass as String: kSecClassGenericPassword,
//			kSecAttrAccount as String: keychainKey,
//			kSecReturnData as String: true
//		]
//		var result: AnyObject?
//		let status = SecItemCopyMatching(query as CFDictionary, &result)
//		guard status == errSecSuccess, let data = result as? Data else { return }
//		savedCards = (try? JSONDecoder().decode([NFCCardModel].self, from: data)) ?? []
//	}
//}
