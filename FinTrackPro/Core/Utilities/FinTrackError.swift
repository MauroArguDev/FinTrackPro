import Foundation

enum FinTrackError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case budgetExceeded(category: String, limit: Double)
    case biometricFailed
    case biometricNotAvailable
    case biometricCancelled

    var errorDescription: String? {
        switch self {
        case .saveFailed:            return "Failed to save. Please try again."
        case .deleteFailed:          return "Failed to delete. Please try again."
        case .budgetExceeded(let c, _): return "Budget exceeded for \(c)."
        case .biometricFailed:       return "Authentication failed. Please try again."
        case .biometricNotAvailable: return "Biometric authentication is not available."
        case .biometricCancelled:    return nil
        }
    }
}
