//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct DeviceModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let doorName: String
    let status: String
}

let sampledevices: [DeviceModel] = [
  
    DeviceModel(title: "TC434(266253636)",doorName: "UTL-3S/DOOR1", status: "ONLINE"),
    DeviceModel(title: "TC434(266253636)",doorName: "UTL-3S/DOOR1", status: "ONLINE"),
    DeviceModel(title: "TC434(266253636)",doorName: "UTL-3S/DOOR1", status: "OFFLINE"),
    DeviceModel(title: "TC434(266253636)",doorName: "UTL-3S/DOOR1", status: "ONLINE"),
]


struct DeviceAdminTabView: View {
    let devices =  sampledevices
    
    @State private var navigateToDeviceScanView = false
    
    var body: some View {
        ZStack {
            VStack{
                Button(action: {
                    navigateToDeviceScanView = true
                }) {
                    HStack{
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                          
                        Text("Configure device")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white)
                    }
                   
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(devices) { item in
                            DeviceCardView(device: item)
                                .onTapGesture {
                                    // onSelect(item)
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                }
            }
            .padding(.top,10)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDeviceScanView) {
            OnboardPageDeviceScanView()
        }
    }
}


struct DeviceCardView: View {
    let device: DeviceModel

    var body: some View {
        HStack(spacing: 16) {
            Image("smartphone")
                .resizable()
                .frame(width: 33, height: 33)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(device.doorName)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray.opacity(0.9))
                    .lineLimit(2)
            }

            Spacer()

            Text(device.status)
                .font(.custom("Inter-SemiBold", size: 10))
                .foregroundColor(.white)
                .padding(6)
                .background(device.status == "ONLINE" ? Color.green : Color.red)
                .cornerRadius(6)
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
