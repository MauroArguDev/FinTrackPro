import Foundation
@preconcurrency import LocalAuthentication

protocol BiometricServiceProtocol: Sendable {
    var biometryType: LABiometryType { get }
    func canAuthenticate() -> Bool
    func authenticate() async throws
}

final class BiometricService: BiometricServiceProtocol, @unchecked Sendable {

    var biometryType: LABiometryType {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }

    func canAuthenticate() -> Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func authenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            throw FinTrackError.biometricNotAvailable
        }

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Authenticate to access FinTrack Pro"
            ) { success, error in
                if success {
                    cont.resume()
                    return
                }
                switch (error as? LAError)?.code {
                case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
                    cont.resume(throwing: FinTrackError.biometricNotAvailable)
                case .userCancel, .systemCancel, .appCancel:
                    cont.resume(throwing: FinTrackError.biometricCancelled)
                default:
                    cont.resume(throwing: FinTrackError.biometricFailed)
                }
            }
        }
    }
}
