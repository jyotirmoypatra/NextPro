//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct AdminFacilityListView: View {
    var onSelect: (String) -> Void
    let facilitis = [
        "IRON HIVE GYM: LOCATION 1",
        "IRON HIVE GYM: LOCATION 2"
    ]
    
    var body: some View {
        
        ZStack{
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(facilitis, id: \.self) { item in
                        FacilityCardView(title: item)
                            .onTapGesture {
                                onSelect(item)
                            }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
    }
}



struct FacilityCardView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading){
                Image("dooricon")
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
    var onBack: () -> Void
    
    let doors = [
        "MAIN ENTRANCE",
        "BACK ENTRANCE",
        "SAUNA ACCESS",
        
    ]
    
    var body: some View {
        ZStack{
            
            VStack{
                HStack{
                    Button(action: {
                        onBack()
                    }) {
                        HStack{
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                
                                
                            
                            Text("Back")
                                .foregroundColor(.white)
                                .font(.custom("Inter-SemiBold", size: 16))
                        }
                       // .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(10)
                        
                    }
                     
                    Spacer()
                    
                    Text(facilityName)
                        .foregroundColor(.white)
                        .font(.custom("Inter-Medium", size: 16))
                    
                    Spacer()
                    
                    Image("dooricon")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .cornerRadius(5)
                }
                .padding(.horizontal,5)
                .padding(.top,5)
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(doors, id: \.self) { item in
                            EntranceDoorCardView(title: item)
                                
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            
            
        }
        .navigationBarBackButtonHidden()
        
    }
}


struct EntranceDoorCardView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack{
                Image("antenna-signal")
                    .foregroundColor(.gray)
                    .frame(width: 24 , height: 24)
                Text("Remote Open")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }
          
            VStack{
                Image("bluetooth-white")
                    .foregroundColor(.gray)
                    .frame(width: 24 , height: 24)
                Text("BLE Open")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(.white)
            }
           
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
