import Foundation
import Observation
import SwiftData

@Observable
final class DashboardViewModel {
    private(set) var totalBalance: Double = 0
    private(set) var monthlyIncome: Double = 0
    private(set) var monthlyExpenses: Double = 0
    private(set) var savingsRate: Double = 0
    private(set) var recentTransactions: [Transaction] = []

    func update(with transactions: [Transaction]) {
        let comps = Calendar.current.dateComponents([.year, .month], from: .now)
        let monthStart = Calendar.current.date(from: comps) ?? .now

        totalBalance = transactions.reduce(0) { $0 + $1.signedAmount }

        let thisMonth = transactions.filter { $0.date >= monthStart }
        monthlyIncome = thisMonth.filter(\.isIncome).reduce(0) { $0 + $1.amount }
        monthlyExpenses = thisMonth.filter(\.isExpense).reduce(0) { $0 + $1.amount }
        savingsRate = monthlyIncome > 0
            ? max(0, min(1, (monthlyIncome - monthlyExpenses) / monthlyIncome))
            : 0

        recentTransactions = Array(transactions.sorted { $0.date > $1.date }.prefix(5))
    }
}
