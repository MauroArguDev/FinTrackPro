import Foundation
import Observation
import SwiftData

struct CategoryUsage: Identifiable {
    var id: UUID { category.id }
    let category: Category
    let budget: Budget
    let spent: Double

    var usage: Double    { budget.usage(spent: spent) }
    var isOverBudget: Bool { spent > budget.limit }
    var remaining: Double  { max(0, budget.limit - spent) }
}

@Observable
final class BudgetViewModel {
    private(set) var categoryUsages: [CategoryUsage] = []
    private(set) var overallUsagePercent: Double = 0
    private(set) var overBudgetCategories: [CategoryUsage] = []

    func update(transactions: [Transaction], budgets: [Budget]) {
        let currentMonth = Budget.currentMonthYear()

        let comps = Calendar.current.dateComponents([.year, .month], from: .now)
        let monthStart = Calendar.current.date(from: comps) ?? .now

        let monthExpenses = transactions.filter { !$0.isIncome && $0.date >= monthStart }

        var spentByCategory: [UUID: Double] = [:]
        for tx in monthExpenses {
            guard let cid = tx.category?.id else { continue }
            spentByCategory[cid, default: 0] += tx.amount
        }

        var usages: [CategoryUsage] = []
        for budget in budgets where budget.monthYear == currentMonth {
            guard let category = budget.category else { continue }
            let spent = spentByCategory[category.id] ?? 0
            usages.append(CategoryUsage(category: category, budget: budget, spent: spent))
        }

        usages.sort { $0.usage > $1.usage }

        categoryUsages = usages
        overBudgetCategories = usages.filter { $0.isOverBudget }

        let totalLimit = usages.reduce(0) { $0 + $1.budget.limit }
        let totalSpent = usages.reduce(0) { $0 + $1.spent }
        overallUsagePercent = totalLimit > 0 ? totalSpent / totalLimit : 0
    }
}
