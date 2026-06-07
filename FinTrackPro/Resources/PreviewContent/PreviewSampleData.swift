import Foundation
import SwiftData

@MainActor
struct PreviewSampleData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(
                for: Transaction.self, Category.self, Budget.self,
                configurations: config
            )
            let ctx = container.mainContext
            let categories = Category.defaults()
            categories.forEach { ctx.insert($0) }
            sampleTransactions(categories: categories).forEach { ctx.insert($0) }
            sampleBudgets(categories: categories).forEach { ctx.insert($0) }
            return container
        } catch {
            fatalError("PreviewSampleData: failed to create container — \(error)")
        }
    }()

    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: .now) ?? .now
    }

    private static func sampleTransactions(categories: [Category]) -> [Transaction] {
        let food          = categories.first { $0.name == "Food" }
        let transport     = categories.first { $0.name == "Transport" }
        let health        = categories.first { $0.name == "Health" }
        let entertainment = categories.first { $0.name == "Entertainment" }
        let shopping      = categories.first { $0.name == "Shopping" }
        let home          = categories.first { $0.name == "Home" }
        let education     = categories.first { $0.name == "Education" }
        let salary        = categories.first { $0.name == "Salary" }
        let freelance     = categories.first { $0.name == "Freelance" }
        let other         = categories.first { $0.name == "Other" }

        return [
            Transaction(amount: 5000.00, title: "Monthly Salary",    date: daysAgo(0),  isIncome: true,  category: salary),
            Transaction(amount: 1200.00, title: "Freelance Project",  date: daysAgo(3),  isIncome: true,  category: freelance),
            Transaction(amount:  800.00, title: "Design Contract",    date: daysAgo(10), isIncome: true,  category: freelance),
            Transaction(amount:  250.00, title: "Cashback Reward",    date: daysAgo(14), isIncome: true,  category: other),
            Transaction(amount:  180.00, title: "Refund",             date: daysAgo(20), isIncome: true,  category: other),

            Transaction(amount:   18.50, title: "Lunch",              date: daysAgo(1),  isIncome: false, category: food),
            Transaction(amount:   32.00, title: "Groceries",          date: daysAgo(2),  isIncome: false, category: food),
            Transaction(amount:   15.75, title: "Coffee & Snacks",    date: daysAgo(5),  isIncome: false, category: food),
            Transaction(amount:   42.00, title: "Dinner Out",         date: daysAgo(8),  isIncome: false, category: food),
            Transaction(amount:   12.00, title: "Bus Pass",           date: daysAgo(1),  isIncome: false, category: transport),
            Transaction(amount:   28.50, title: "Uber",               date: daysAgo(6),  isIncome: false, category: transport),
            Transaction(amount:    8.00, title: "Metro",              date: daysAgo(11), isIncome: false, category: transport),
            Transaction(amount:  120.00, title: "Doctor Visit",       date: daysAgo(4),  isIncome: false, category: health),
            Transaction(amount:   45.00, title: "Pharmacy",           date: daysAgo(9),  isIncome: false, category: health),
            Transaction(amount:   35.00, title: "Cinema",             date: daysAgo(3),  isIncome: false, category: entertainment),
            Transaction(amount:   22.50, title: "Streaming Services", date: daysAgo(15), isIncome: false, category: entertainment),
            Transaction(amount:   89.00, title: "Clothes",            date: daysAgo(7),  isIncome: false, category: shopping),
            Transaction(amount:  156.00, title: "Electronics",        date: daysAgo(12), isIncome: false, category: shopping),
            Transaction(amount:  320.00, title: "Rent",               date: daysAgo(1),  isIncome: false, category: home),
            Transaction(amount:  200.00, title: "Online Course",      date: daysAgo(18), isIncome: false, category: education),
        ]
    }

    private static func sampleBudgets(categories: [Category]) -> [Budget] {
        let month = Budget.currentMonthYear()
        return [
            Budget(monthYear: month, limit: 400,  category: categories.first { $0.name == "Food" }),
            Budget(monthYear: month, limit: 150,  category: categories.first { $0.name == "Transport" }),
            Budget(monthYear: month, limit: 300,  category: categories.first { $0.name == "Health" }),
            Budget(monthYear: month, limit: 100,  category: categories.first { $0.name == "Entertainment" }),
            Budget(monthYear: month, limit: 350,  category: categories.first { $0.name == "Shopping" }),
        ]
    }
}
