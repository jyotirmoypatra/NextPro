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
                .padding(.horizontal, 10)
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
    
    let doors: [DoorModelUser] = [
        DoorModelUser(
            name: "Iron Hive Gym: Main Gate",
            devSn: "4282184653",
            devMac: "a0:76:4e:5a:ae:a2",
            doorID: 2,
            eKey: "ad8ffbf81283b55c89b3bcf184b8294d000000000000000000000000000000001000",
            cardno: "2988462596"
        )
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
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(doors) { door in
                            EntranceDoorCardView(
                                door: door,
                                onRemoteOpen: {
                                   // handleRemoteOpen(for: door)
                                },
                                onBLEOpen: {
                                   // handleBLEOpen(for: door)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                }


            }
            
            
        }
        .navigationBarBackButtonHidden()
        
    }
}



struct EntranceDoorCardView: View {
    let door: DoorModelUser
    let onRemoteOpen: () -> Void
    let onBLEOpen: () -> Void

    var body: some View {
        HStack(spacing: 16) {

            // Door name
            Text(door.name)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Remote Open
            Button(action: onRemoteOpen) {
                VStack(spacing: 4) {
                    Image("antenna-signal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("Remote Open")
                        .font(.custom("Inter-SemiBold", size: 13))
                        .foregroundColor(.white)
                }
            }

            
            // BLE Open
            Button(action: onBLEOpen) {
                VStack(spacing: 4) {
                    Image("bluetooth-white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("BLE Open")
                        .font(.custom("Inter-SemiBold", size: 13))
                        .foregroundColor(.white)
                }
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
