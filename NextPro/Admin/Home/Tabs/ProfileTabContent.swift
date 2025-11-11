//
//  ProfileTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct ProfileTabContent: View {
	@State private var showAddCard = false
	
	var body: some View {
		VStack(spacing: 16) {
			VStack(spacing: 10) {
				Text("Profile")
					.font(.headline)
					.foregroundColor(.white)
				Text("Your account details and settings go here.")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			.padding(.vertical, 40)
			.padding(.horizontal, 20)
			.background(Color.black.opacity(0.4))
			.cornerRadius(16)
			
			Button(action: { showAddCard = true }) {
				HStack {
					Image(systemName: "plus.circle.fill").font(.system(size: 20))
					Text("Add Card").font(.headline)
				}
				.foregroundColor(.white)
				.frame(maxWidth: .infinity)
				.frame(height: 52)
				.background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
				.cornerRadius(14)
			}
			.padding(.horizontal, 20)
		}
		.padding(.horizontal, 20)
		.fullScreenCover(isPresented: $showAddCard) {
			AddCardView()
		}
	}
}
