//
//  ModernAlertView.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 02/12/25.
//


import SwiftUI

struct ModernAlertView: View {
    let title: String
    let message: String
    let isSuccess: Bool
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing:10){
            
            HStack(alignment: .center, spacing: 12){
                // Icon
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(isSuccess ? .green : .red)
                
                // Title
                Text(title)
                    .font(.custom("Inter-Bold", size: 16))
                    .foregroundColor(isSuccess ? .green : .red)
                
                Spacer()
            }
            
            Text(message)
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // Button
            Button(action: action) {
                Text(buttonTitle)
                    .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.black)
                    .background(isSuccess ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
        }
        .padding(15)
        .background(Color(hex: "#292929"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(.horizontal, 30)
        
    }
}


struct ModernAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> ModernAlertView
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                alertView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

extension View {
    func modernAlert(isPresented: Binding<Bool>, @ViewBuilder alertView: @escaping () -> ModernAlertView) -> some View {
        self.modifier(ModernAlertModifier(isPresented: isPresented, alertView: alertView))
    }
}




//Usage


//-----------------------Error--------------------------------
//    .modernAlert(isPresented: $showError) {
//          ModernAlertView(
//              title: "Error!",
//              message: errorMsg,
//              isSuccess: false,
//              buttonTitle: "OK"
//          ) { showError = false }
//      }


//-----------------------Success--------------------------------
//    .modernAlert(isPresented: $showSuccess) {
//          ModernAlertView(
//              title: "Success!",
//              message: "Profile updated successfully.",
//              isSuccess: true,
//              buttonTitle: "Great"
//          ) { showSuccess = false }
//      }


struct BluetoothAlertView: View {
    let onCancel: () -> Void
    let openSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing:15){
            
            
            Image("bluetooth-blue")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.top,5)

            
            
            
            Text("Bluetooth is Off")
                .font(.custom("Inter-Bold", size: 16))
                .foregroundColor(.white)
            
            
            Text("To unlock the door, Bluetooth needs to be enabled. Tap ‘Open Settings’ and turn on Bluetooth on your device.")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            
            
            Divider().background(Color.white.opacity(0.15))
            
            // Button
            Button(action: openSettings) {
                Text("Open Settings")
                    .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.black)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.gray)
//                    .background(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
        }
        .padding(15)
        .background(Color(hex: "#292929"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(.horizontal, 30)
        
    }
}



struct BluetoothAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> BluetoothAlertView
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                alertView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

extension View {
    func bluetoothModernAlert(isPresented: Binding<Bool>, @ViewBuilder alertView: @escaping () -> BluetoothAlertView) -> some View {
        self.modifier(BluetoothAlertModifier(isPresented: isPresented, alertView: alertView))
    }
}
