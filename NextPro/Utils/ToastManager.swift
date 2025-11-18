//
//  ToastManager.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 18/11/25.
//

import SwiftUI
import Combine

// MARK: - Toast Model
struct ToastModel: Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: TimeInterval
    
    enum ToastType {
        case success
        case error
        case info
        case warning
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            case .warning: return .orange
            }
        }
    }
}

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var currentToast: ToastModel?
    
    private init() {}
    
    func show(message: String, type: ToastModel.ToastType = .info, duration: TimeInterval = 3.0) {
        currentToast = ToastModel(message: message, type: type, duration: duration)
        
        // Auto dismiss after duration
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if currentToast?.message == message {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        withAnimation {
            currentToast = nil
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastModel
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 20))
                .foregroundColor(toast.type.color)
            
            Text(toast.message)
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
//            Button(action: onDismiss) {
//                Image(systemName: "xmark")
//                    .font(.system(size: 14))
//                    .foregroundColor(.white.opacity(0.7))
//            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.85))
                .shadow(color: toast.type.color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(toast.type.color.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.currentToast {
                VStack {
                    ToastView(toast: toast) {
                        toastManager.dismiss()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.currentToast)
                    
                    Spacer()
                }
                .padding(.top, 50)
                .zIndex(999)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func toast() -> some View {
        modifier(ToastModifier())
    }
}

