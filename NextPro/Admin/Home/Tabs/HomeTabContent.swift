//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct HomeTabContent: View {
    
    let gyms = [
        "IRON HIVE GYM: LOCATION 1",
        "IRON HIVE GYM: LOCATION 2"
    ]
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    ForEach(gyms, id: \.self) { gym in
                        GymCardView(title: gym)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
}



struct GymCardView: View {
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            
            VStack(alignment: .leading){
                Image("dooricon") // your blue gym logo
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 18, weight: .medium))
        }
        .padding(20)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
