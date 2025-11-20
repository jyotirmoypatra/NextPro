
//
//  DoorModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 12/11/25.
//

import Foundation
import Combine

// MARK: - Door Model (Unified)
struct CardModelUser: Identifiable, Codable {
    let id: UUID
    let userName: String
    let companyName: String
    let FacilityName: String
    let duration: String
    let cardno: String
    
    init(
        id: UUID = UUID(),
        userName : String,
        companyName: String,
        FacilityName : String,
        duration: String ,
        cardno: String
    ) {
        self.id = id
        self.userName = userName
        self.companyName = companyName
        self.FacilityName = FacilityName
        self.duration = duration
        self.cardno = cardno
    }
}

// MARK: - Door Storage Manager
@MainActor
class UserCardStorageManager: ObservableObject {
    static let shared = UserCardStorageManager()
    
    @Published var card: CardModelUser?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private init() { }
    
    // MARK: - Load Card (Simulated API)
    func loadCards() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
          
            let fetchcard = CardModelUser(id: UUID(), userName: "Peter Parker", companyName: "NextPro", FacilityName: "IRON HIVE GYM", duration: "09/26", cardno: "1557049426")
            
            self.card = fetchcard
            print("✅ Loaded card from API/Mock.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Failed to load card: \(error)")
        }
    }
}
