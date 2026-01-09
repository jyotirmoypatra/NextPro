//
//  DeviceInformationView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 30/10/25.
//

import SwiftUI

struct DeviceInformationView: View {
    let selectedDevice:AssignDevice
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("backgroundimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack(spacing: 15) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Back")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-SemiBold", size: 16))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .overlay(
                        Text("\(selectedDevice.modelName) (\(selectedDevice.serial))")
                            .foregroundColor(.white)
                            .font(.custom("Inter-Bold", size: 16))
                    )
                    .padding(.top, 10)
                    .padding(.bottom,10)
                    
                    
                    ScrollView(showsIndicators: false) {
                        //device information
                        Spacer(minLength: 10)
                        VStack(spacing: 20){
                            HStack(){
                                Text("Device SN")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.serial)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Model")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.modelName)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Mac")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.mac)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device eKey")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(selectedDevice.key)
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Dev Type")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(String(selectedDevice.devType ?? 14))
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Device Open Type")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Text(String(selectedDevice.openType ?? 2))
                                    .foregroundColor(Color(hex: "#6D717F"))
                                    .font(.custom("Inter-Medium", size: 16))
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                        }
                        .padding(15)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        
                        //
                        Spacer(minLength: 30)
                        HStack(){
                            Text("DEVICE SETTINGS")
                                .foregroundColor(.white)
                                .font(.custom("Inter-Medium", size: 16))
                                .padding(.trailing,10)
                                .padding(.trailing,5)
                            
                            Spacer()
                            
                        }
                        
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 20){
                            HStack(){
                                Text("Get Device Information")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack(){
                                Text("Configure Wifi")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))
                                
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Upgrade Bluetooth Firmware")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            HStack{
                                Text("Reset Device Configurations")
                                    .foregroundColor(.white)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .padding(.trailing,10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))
                                
                            }
                            
                        }
                        .padding(15)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        
                        Spacer(minLength: 30)
                    }
                   
                }
                .padding(.horizontal,10)
            }
            

        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    SuccessConnctionView()
}

