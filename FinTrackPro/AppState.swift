import Foundation
@preconcurrency import LocalAuthentication
import Observation

@Observable
@MainActor
final class AppState {
    private(set) var isUnlocked: Bool
    private(set) var biometryType: LABiometryType
    var selectedCurrency: String {
        didSet { UserDefaults.standard.set(selectedCurrency, forKey: Self.currencyKey) }
    }

    private static let biometricKey   = "ft.biometricEnabled"
    private static let promptShownKey = "ft.biometricPromptShown"
    private static let currencyKey    = "ft.currency"

    var biometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.biometricKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.biometricKey)
            if !newValue { isUnlocked = true }
        }
    }

    var hasShownBiometricPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: Self.promptShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.promptShownKey) }
    }

    var biometricName: String {
        switch biometryType {
        case .none:    return "Passcode"
        case .touchID: return "Touch ID"
        case .faceID:  return "Face ID"
        case .opticID: return "Optic ID"
        @unknown default: return "Biometrics"
        }
    }

    var canUseBiometrics: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    init() {
        isUnlocked = !UserDefaults.standard.bool(forKey: Self.biometricKey)
        selectedCurrency = UserDefaults.standard.string(forKey: Self.currencyKey) ?? "USD"
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = ctx.biometryType
    }

    func lock() {
        isUnlocked = false
    }

    func unlock() {
        isUnlocked = true
    }
}
