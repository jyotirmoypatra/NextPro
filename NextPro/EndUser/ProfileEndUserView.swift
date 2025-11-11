//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct ProfileEndUserView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("WELCOME Profile")
                .font(.headline)
                .foregroundColor(.white)

            Text("no data")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: {
                // Add Facility Action
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add")
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
