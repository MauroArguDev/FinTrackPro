import Foundation

enum FinTrackError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case budgetExceeded(category: String, limit: Double)
    case biometricFailed
    case biometricNotAvailable

    var errorDescription: String? {
        switch self {
        case .saveFailed:           return "Failed to save. Please try again."
        case .deleteFailed:         return "Failed to delete. Please try again."
        case .budgetExceeded(let c, _): return "Budget exceeded for \(c)."
        case .biometricFailed:      return "Biometric authentication failed."
        case .biometricNotAvailable: return "Biometric authentication is not available."
        }
    }
}
