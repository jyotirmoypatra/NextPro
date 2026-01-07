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
                        if assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "tray")
                                    .font(.system(size: 44))
                                    .foregroundColor(.gray.opacity(0.8))

                                Text("No Configured Devices Found")
                                    .font(.custom("Inter-SemiBold", size: 18))
                                    .foregroundColor(.white)

                                Text("You haven’t configured any devices yet.\nTap “Configure device” to get started.")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(.top,60)

                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                        } else {
                            ForEach(assignDeviceVM.alredayConfiguredDeviceList) { item in
                                DeviceCardView(device: item)
                            }
                            
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                }
                .refreshable {
                    await assignDeviceVM.fetchAssignDevice()

                    if let error = assignDeviceVM.errorMessage, !error.isEmpty {
                        showAssignDeviceVMErrorAlert = true
                    }
                }

            }
            .padding(.top,10)
            
            if assignDeviceVM.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDeviceScanView) {
           // OnboardPageDeviceScanView()
            StartConfigureDeviceListView(devices: assignDeviceVM.assignDeviceDetails?.devices ?? [])
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

            Text("OFFLINE")
                .font(.custom("Inter-SemiBold", size: 10))
                .foregroundColor(.white)
                .padding(6)
                .background("OFFLINE" == "ONLINE" ? Color.green : Color.red)
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
