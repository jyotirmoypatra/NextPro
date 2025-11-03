//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct HomeTabContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("WELCOME JAMES!")
                .font(.headline)
                .foregroundColor(.white)

            Text("Looks like you do not have a facility yet.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: {
                // Add Facility Action
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Facility")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 30)
        .padding(.horizontal)
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
