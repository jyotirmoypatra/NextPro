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
        VStack(spacing: 12) {

            // Icon
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(isSuccess ? .green : .red)

            // Title
            Text(title)
                .font(.custom("Inter-Bold", size: 18))

            // Message
            Text(message)
                .font(.custom("Inter-Medium", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            // Button
            Button(action: action) {
                Text(buttonTitle)
                    .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.black)
                    .background(isSuccess ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color(hex: "#474747"))
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
                Color.black.opacity(0.5)
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
