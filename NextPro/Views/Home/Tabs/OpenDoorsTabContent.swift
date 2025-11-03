//
//  OpenDoorsTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI
struct OpenDoorsTabContent: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Open Doors")
                .font(.headline)
                .foregroundColor(.white)
            Text("Here you can manage and open doors.")
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
