//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct AdminFacilityListView: View {
    
    let facilitis = [
        "IRON HIVE GYM: LOCATION 1",
        "IRON HIVE GYM: LOCATION 2"
    ]
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    ForEach(facilitis, id: \.self) { facility in
                        NavigationLink(value: facility) {
                            FacilityCardView(title: facility)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationDestination(for: String.self) { facilityName in
            FacilityDetailView(facilityName: facilityName)
        }
    }
}



struct FacilityCardView: View {
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




struct FacilityDetailView: View {
    let facilityName: String
    
    var body: some View {
        VStack {
            Text(facilityName)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}
