//
//  HomeTabContent.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 31/10/25.
//

import SwiftUI

struct DeviceAdminTabView: View {
    @StateObject private var assignDeviceVM = AssignedDeviceViewModel()
    @State private var showAssignDeviceVMErrorAlert = false
    @State private var navigateToDeviceScanView = false
    @State private var pullToRefresh = false
    
    var body: some View {
        ZStack {
            VStack{
                
                HStack {
                    Text("Profile")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .padding(.top, 16)
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

                        if !assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
                            ForEach(assignDeviceVM.alredayConfiguredDeviceList) { item in
                                DeviceCardView(device: item)
                            }
                        }

//                        // 🔑 THIS IS THE IMPORTANT PART
//                        Color.clear
//                            .frame(minHeight: 400)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                }
                .refreshable {
                    pullToRefresh = true
                    await assignDeviceVM.fetchAssignDevice()
                    pullToRefresh = false
                    if let error = assignDeviceVM.errorMessage, !error.isEmpty {
                        showAssignDeviceVMErrorAlert = true
                    }
                }


            }
            
            
            if assignDeviceVM.isLoading && !pullToRefresh{
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false) 
            }
            
            
            if assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
                ZStack {
                VStack(spacing: 14) {
                    Image("smartphone")
                        .resizable()
                        .frame(width: 50, height: 50)

                    Text("No Configured Devices Found")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)

                    Text("You haven’t configured any devices yet.\nTap “Configure device” to get started.")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
            
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDeviceScanView) {
            SelectDeviceView(devices: assignDeviceVM.assignDeviceDetails?.devices ?? [])
        }
        .internetOverlay()
        .task {
            await assignDeviceVM.fetchAssignDevice()

            if let error = assignDeviceVM.errorMessage, !error.isEmpty {
                showAssignDeviceVMErrorAlert = true
            }
        }

        .modernAlert(isPresented: $showAssignDeviceVMErrorAlert) {
              ModernAlertView(
                  title: "Error!",
                  message: assignDeviceVM.errorMessage ?? "Something went wrong!",
                  isSuccess: false,
                  buttonTitle: "OK"
              ) { showAssignDeviceVMErrorAlert = false
                 
              }
        }
    }
}


struct DeviceCardView: View {
    let device: AssignDevice

    var body: some View {
        HStack(spacing: 16) {
            Image("smartphone")
                .resizable()
                .frame(width: 33, height: 33)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.modelName)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text("Serial No : \(device.serial)")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray.opacity(0.9))
                    .lineLimit(2)
            }

            Spacer()

            Text(device.status ?? "OFFLINE")
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
