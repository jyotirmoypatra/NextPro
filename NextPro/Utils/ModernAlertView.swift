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
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .font(.system(size: 50))
                .foregroundColor(isSuccess ? .green : .red)

            // Title
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            // Message
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            // Button
            Button(action: action) {
                Text(buttonTitle)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSuccess ? Color.green.opacity(0.5) : Color.red.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(.horizontal, 40)
    }
}


struct ModernAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alertView: () -> ModernAlertView

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(0.4)
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
