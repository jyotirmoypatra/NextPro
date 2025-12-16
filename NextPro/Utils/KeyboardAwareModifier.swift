//
//  KeyboardAwareModifier.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 26/11/25.
//


import SwiftUI
import Combine


struct KeyboardAwareModifier: ViewModifier {
    @StateObject private var keyboard = KeyboardHeightHelper()

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .padding(.bottom, max(0, keyboard.keyboardHeight - geo.safeAreaInsets.bottom))
                .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
        }
    }
}




final class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .merge(with:
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in CGFloat(0) }
            )
            .receive(on: RunLoop.main)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancellables)
    }
}


extension View {
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}
