//
//  ToastExampleUsage.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//
//  This file demonstrates how to use ToastManager in any view

import SwiftUI

// MARK: - Example Usage
/*

// 1️⃣ ADD TOAST MODIFIER TO YOUR VIEW
struct YourView: View {
    var body: some View {
        VStack {
            // Your view content
        }
        .toast()  // ⬅️ Add this modifier
    }
}

// 2️⃣ SHOW TOAST FROM ANYWHERE IN YOUR CODE

// Success Toast
ToastManager.shared.show(
    message: "Password updated successfully!",
    type: .success,
    duration: 3.0
)

// Error Toast
ToastManager.shared.show(
    message: "Failed to update password",
    type: .error,
    duration: 3.0
)

// Info Toast
ToastManager.shared.show(
    message: "Please check your email",
    type: .info,
    duration: 3.0
)

// Warning Toast
ToastManager.shared.show(
    message: "Low battery warning",
    type: .warning,
    duration: 3.0
)

// 3️⃣ SHOW TOAST FROM VIEWMODEL
@MainActor
class YourViewModel: ObservableObject {
    
    func someAction() async {
        // After successful operation
        ToastManager.shared.show(
            message: "Operation completed!",
            type: .success
        )
    }
}

// 4️⃣ DISMISS TOAST MANUALLY (optional)
ToastManager.shared.dismiss()

*/

// MARK: - Demo View (for testing)
struct ToastDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Toast Demo")
                .font(.title)
                .padding()
            
            Button("Show Success Toast") {
                ToastManager.shared.show(
                    message: "Operation completed successfully!",
                    type: .success
                )
            }
            .buttonStyle(.bordered)
            
            Button("Show Error Toast") {
                ToastManager.shared.show(
                    message: "Something went wrong!",
                    type: .error
                )
            }
            .buttonStyle(.bordered)
            
            Button("Show Info Toast") {
                ToastManager.shared.show(
                    message: "Here's some information",
                    type: .info
                )
            }
            .buttonStyle(.bordered)
            
            Button("Show Warning Toast") {
                ToastManager.shared.show(
                    message: "Be careful!",
                    type: .warning
                )
            }
            .buttonStyle(.bordered)
        }
        .toast()  // Don't forget to add this modifier!
    }
}

