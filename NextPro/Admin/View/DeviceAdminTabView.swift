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
    @State private var navigateToDeviceInfoView = false
    @State private var selectedDevice: AssignDevice?
    @State private var pullToRefresh = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 10){
                
                HStack {
                    Text("Devices")
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
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )
                
                if !assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
                HStack{
                    Text("Configured device")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.white)
                    
                }.frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.top, 20)
                
                 }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {

                        if !assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
                            ForEach(assignDeviceVM.alredayConfiguredDeviceList) { item in
                                DeviceCardView(device: item)
                                    .onTapGesture {
                                                selectedDevice = item
                                                navigateToDeviceInfoView = true
                                            }
                            }
                        }

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
                    .padding(.bottom, 20)
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
            .padding(.horizontal,10)
            
            
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
            
            
             if !assignDeviceVM.isLoading && assignDeviceVM.alredayConfiguredDeviceList.isEmpty {
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
            SelectDeviceView(devices: assignDeviceVM.assignDeviceDetails?.data ?? [])
        }
        .navigationDestination(isPresented: $navigateToDeviceInfoView) {
            if let device = selectedDevice {
                DeviceInformationView(selectedDevice: device)
            }
        }

        .internetOverlay()
        .task {
            await assignDeviceVM.fetchAssignDevice()

            if let error = assignDeviceVM.errorMessage, !error.isEmpty {
                showAssignDeviceVMErrorAlert = true
            }
        }
        .onDisappear {
            assignDeviceVM.stopHeartbeat()   
            print("Heartbeat stopped!!!!!")
        }

        .onReceive(NetworkManager.shared.$hasInternet) { hasInternet in
            guard hasInternet else { return }

            // Retry ONLY if previous failure was due to no internet
            if assignDeviceVM.isFailedDueToNoInternet {
                Task {
                    await assignDeviceVM.fetchAssignDevice()
                }
            }
        }

        .modernAlert(
                isPresented: Binding(
                    get: { showAssignDeviceVMErrorAlert && !assignDeviceVM.isFailedDueToNoInternet },
                    set: { showAssignDeviceVMErrorAlert = $0 }
                )
            ) {
                ModernAlertView(
                    title: "Error!",
                    message: assignDeviceVM.errorMessage ?? "Something went wrong!",
                    isSuccess: false,
                    buttonTitle: "OK"
                ) {
                    showAssignDeviceVMErrorAlert = false
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
                Text("\(device.modelName) (\(device.serial))")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(2)

//                Text("Serial No : \(device.serial)")
//                    .font(.custom("Inter-Regular", size: 14))
//                    .foregroundColor(.gray.opacity(0.9))
//                    .lineLimit(2)
            }

            Spacer()

            Text(device.status ?? "OFFLINE")
                .font(.custom("Inter-SemiBold", size: 10))
                .foregroundColor(.white)
                .padding(6)
                .background(device.status == "ONLINE" ? Color.green : Color.red)
                .cornerRadius(6)
        }
        .padding(15)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
