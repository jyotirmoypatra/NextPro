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
    
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing:20){
            
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
//            Button(action: action) {
//                Text(buttonTitle)
//                    .font(.custom("Inter-Bold", size: 16))
//                    .frame(maxWidth: .infinity)
//                    .padding(10)
//                    .foregroundColor(.black)
//                    .background(isSuccess ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
            
            // MARK: Buttons

            if let secondaryTitle = secondaryButtonTitle,
               let secondaryAction = secondaryAction {
                
                HStack(spacing: 10) {
                    
                    
                    // Secondary Button
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                            .font(.custom("Inter-Medium", size: 15))
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Primary Button
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
                
            } else {
                
                // Only Primary Button (default)
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
            
        }
        .padding(15)
        .background(Color(hex: "#292929"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(.horizontal, 30)
        
    }
}


struct ModernAlertModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                alertView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

struct ModernAlertItemModifier<Item: Identifiable, AlertContent: View>: ViewModifier {
    @Binding var item: Item?
    let alertView: (Item) -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let item {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                alertView(item)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(), value: item != nil)
    }
}

extension View {
    func modernAlert<AlertContent: View>(isPresented: Binding<Bool>, @ViewBuilder alertView: @escaping () -> AlertContent) -> some View {
        self.modifier(ModernAlertModifier(isPresented: isPresented, alertView: alertView))
    }
    
    func modernAlert<Item: Identifiable, AlertContent: View>(item: Binding<Item?>, @ViewBuilder alertView: @escaping (Item) -> AlertContent) -> some View {
        self.modifier(ModernAlertItemModifier(item: item, alertView: alertView))
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

//    .modernAlert(item: $locationAlertPayload) { payload in
//        ModernAlertView(
//            title: "Location Required",
//            message: payload.message,
//            isSuccess: false,
//            buttonTitle: "Cancel",
//            action: {
//                locationAlertPayload = nil
//            },
//            secondaryButtonTitle: "Open Settings",
//            secondaryAction: {
//                openAppSettings()
//            }
//        )
//    }


struct BluetoothAlertView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Icon
                Image("bluetooth-red")
                    .resizable()
                    .frame(width: 48,height: 48)

                // Message
                Text("Bluetooth is turned off.\nPlease enable Bluetooth to proceed")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // OK Button
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding(25)
            .background(Color(hex: "#292929"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(.horizontal, 30)
        }
        //.transition(.opacity)
    }
}


struct BluetoothAlertModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                   // .transition(.opacity)
                
                alertView()
                    .transition(.scale)
            }
        }
     // .animation(.spring(), value: isPresented)
    }
}

extension View {
    func bluetoothModernAlert<AlertContent: View>(isPresented: Binding<Bool>, @ViewBuilder alertView: @escaping () -> AlertContent) -> some View {
        self.modifier(BluetoothAlertModifier(isPresented: isPresented, alertView: alertView))
    }
}


struct SessionExpiredAlertView: View {
    let title: String
    let message: String
    let isSuccess: Bool
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            
            // MARK: Header
            HStack(spacing: 15) {
                
                ZStack {
                    Circle()
                        .fill((isSuccess ? Color.green : Color.red).opacity(0.15))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: isSuccess ? "checkmark" : "exclamationmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isSuccess ? .green : .red)
                }
                
                Text(title)
                    .font(.custom("Inter-Bold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            
            // MARK: Message
            Text(message)
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            // MARK: Button
            Button(action: action) {
                Text(buttonTitle)
                    .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: isSuccess
                            ? [Color.green, Color.green.opacity(0.7)]
                            : [Color.red, Color.red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(
                        color: (isSuccess ? Color.green : Color.red).opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 20)
        .padding(.horizontal, 28)
    }
}


struct SessionExpiredAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> SessionExpiredAlertView
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.8)
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
    func SessionExpiredAlert(isPresented: Binding<Bool>, @ViewBuilder alertView: @escaping () -> SessionExpiredAlertView) -> some View {
        self.modifier(SessionExpiredAlertModifier(isPresented: isPresented, alertView: alertView))
    }
}
