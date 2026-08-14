//
//  PassPresentationSuppressionManager.swift
//  NextPro
//

import Foundation
import PassKit

/// Wraps PassKit's automatic pass presentation suppression (requires the
/// com.apple.developer.passkit.pass-presentation-suppression entitlement).
/// Start/stop are idempotent so callers can invoke them freely from tab
/// selection and scene-phase changes without tracking state themselves.
@MainActor
final class PassPresentationSuppressionManager {

    static let shared = PassPresentationSuppressionManager()

    private init() {}

    private var suppressionToken: PKSuppressionRequestToken?

    /// Starts suppression if not already active/in-flight. Safe to call repeatedly.
    func start() {
        guard suppressionToken == nil else { return }

        suppressionToken = PKPassLibrary.requestAutomaticPassPresentationSuppression { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    print("🔕 Pass presentation suppression started")
                case .denied:
                    print("⚠️ Pass presentation suppression denied")
                    self.suppressionToken = nil
                case .notSupported:
                    print("⚠️ Pass presentation suppression not supported on this device")
                    self.suppressionToken = nil
                @unknown default:
                    self.suppressionToken = nil
                }
            }
        }
    }

    /// Ends suppression if active. Safe to call repeatedly / when nothing is active.
    func stop() {
        guard let token = suppressionToken else { return }
        PKPassLibrary.endAutomaticPassPresentationSuppression(withRequestToken: token)
        suppressionToken = nil
        print("🔔 Pass presentation suppression stopped")
    }
}
