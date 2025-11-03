//
//  ProfileTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct ProfileTabContent: View {
    var body: some View {
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
        .padding(.horizontal, 20)
    }
}
