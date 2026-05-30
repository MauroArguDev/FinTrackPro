import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private(set) var totalBalance: Double = 0
    private(set) var monthlyIncome: Double = 0
    private(set) var monthlyExpenses: Double = 0
    private(set) var savingsRate: Double = 0
    private(set) var recentTransactions: [Transaction] = []

    func update(with transactions: [Transaction]) {
        guard !transactions.isEmpty else { reset(); return }

        let comps = Calendar.current.dateComponents([.year, .month], from: .now)
        let monthStart = Calendar.current.date(from: comps) ?? .now

        var balance = 0.0
        var income = 0.0
        var expenses = 0.0

        for tx in transactions {
            balance += tx.signedAmount
            guard tx.date >= monthStart else { continue }
            if tx.isIncome { income += tx.amount } else { expenses += tx.amount }
        }

        totalBalance = balance
        monthlyIncome = income
        monthlyExpenses = expenses
        savingsRate = income > 0 ? max(0, min(1, (income - expenses) / income)) : 0
        recentTransactions = Array(transactions.prefix(5))
    }

    private func reset() {
        totalBalance = 0
        monthlyIncome = 0
        monthlyExpenses = 0
        savingsRate = 0
        recentTransactions = []
    }
}
