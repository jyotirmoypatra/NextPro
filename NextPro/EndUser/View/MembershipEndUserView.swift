//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct MembershipEndUserView: View {
    @State private var memberships = [
        UserMembershipModel(
            name: "Unlimited Gym VIP PLUS",
            gymName: "Iron Hive Gym",
            duration: "19 days until renewal",
            price: "$50/month"
        )
    ]

    @State private var selectedTab = "Active"
    
    var body: some View {
        ZStack {

            VStack(spacing: 5) {
                // MARK: - Header
                HStack {
                    Text("Active Membership")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 30)

                // MARK: - Tabs
                HStack {
                    VStack {
                        Button(action: { selectedTab = "Active" }) {
                            Text("Active")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedTab == "Active" ? .white : .gray)
                        }
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == "Active" ? .white : .clear)
                    }

                    Spacer()

                    VStack {
                        Button(action: { selectedTab = "Canceled" }) {
                            Text("Canceled")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(selectedTab == "Canceled" ? .white : .gray)
                        }
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == "Canceled" ? .white : .clear)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 12)
              

                Divider()
                    .background(Color.white.opacity(0.15))
                    .padding(.bottom, 10)

                // MARK: - Membership Cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(memberships, id: \.name) { membership in
                            UserMembershipCardView(membership: membership)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.black.opacity(0.4))
        .internetOverlay() 
    }
}

struct UserMembershipCardView: View {
    let membership: UserMembershipModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Icon
            Image("dooricon")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .padding(.leading, 6)

            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(membership.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(membership.gymName)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Text(membership.duration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 2) {
                Text(membership.price)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}


struct UserMembershipModel {
    let name: String
    let gymName: String
    let duration: String
    let price: String
}
