import Foundation

struct TransactionIntent: Identifiable {
    let id = UUID()
    let isIncome: Bool
}
