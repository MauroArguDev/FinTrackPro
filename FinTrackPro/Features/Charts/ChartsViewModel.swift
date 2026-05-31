import Foundation
import Observation

enum ChartPeriod: CaseIterable, Hashable {
    case oneMonth, threeMonths, sixMonths, oneYear

    var label: String {
        switch self {
        case .oneMonth:    return "1M"
        case .threeMonths: return "3M"
        case .sixMonths:   return "6M"
        case .oneYear:     return "1Y"
        }
    }

    var months: Int {
        switch self {
        case .oneMonth:    return 1
        case .threeMonths: return 3
        case .sixMonths:   return 6
        case .oneYear:     return 12
        }
    }
}

struct MonthlyBar: Identifiable {
    let id = UUID()
    let date: Date
    let monthLabel: String
    let income: Double
    let expenses: Double
}

struct CategorySlice: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let colorHex: String
    let total: Double
    let percent: Double
}

struct DailyPoint: Identifiable {
    let id = UUID()
    let date: Date
    let netAmount: Double
}

@Observable
final class ChartsViewModel {
    private(set) var monthlyBarData: [MonthlyBar] = []
    private(set) var categoryPieData: [CategorySlice] = []
    private(set) var dailyTrendData: [DailyPoint] = []
    private(set) var totalIncome: Double = 0
    private(set) var totalExpenses: Double = 0

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM yy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    func update(transactions: [Transaction], period: ChartPeriod) {
        let calendar = Calendar.current
        let now = Date.now
        let startDate = calendar.date(
            byAdding: .month, value: -period.months,
            to: calendar.startOfDay(for: now)
        ) ?? now

        let filtered = transactions.filter { $0.date >= startDate }

        monthlyBarData = buildMonthlyBars(filtered, from: startDate, calendar: calendar)
        categoryPieData = buildCategorySlices(filtered)
        dailyTrendData  = buildDailyTrend(filtered, from: startDate, to: now, calendar: calendar)
        totalIncome     = filtered.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
        totalExpenses   = filtered.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    private func buildMonthlyBars(_ transactions: [Transaction], from start: Date, calendar: Calendar) -> [MonthlyBar] {
        let startComps = calendar.dateComponents([.year, .month], from: start)
        let nowComps   = calendar.dateComponents([.year, .month], from: .now)
        guard let firstMonth = calendar.date(from: startComps),
              let lastMonth  = calendar.date(from: nowComps) else { return [] }

        var months: [Date] = []
        var cursor = firstMonth
        while cursor <= lastMonth {
            months.append(cursor)
            cursor = calendar.date(byAdding: .month, value: 1, to: cursor) ?? cursor
        }

        var income:   [Date: Double] = [:]
        var expenses: [Date: Double] = [:]
        for tx in transactions {
            let mc = calendar.dateComponents([.year, .month], from: tx.date)
            guard let m = calendar.date(from: mc) else { continue }
            if tx.isIncome { income[m, default: 0]   += tx.amount }
            else           { expenses[m, default: 0] += tx.amount }
        }

        return months.map { m in
            MonthlyBar(
                date: m,
                monthLabel: Self.monthFormatter.string(from: m),
                income:   income[m]   ?? 0,
                expenses: expenses[m] ?? 0
            )
        }
    }

    private func buildCategorySlices(_ transactions: [Transaction]) -> [CategorySlice] {
        let expenses = transactions.filter { $0.isExpense }
        guard !expenses.isEmpty else { return [] }

        var totals: [UUID: (cat: Category, total: Double)] = [:]
        for tx in expenses {
            guard let cat = tx.category else { continue }
            totals[cat.id, default: (cat, 0)].total += tx.amount
        }

        let grand = totals.values.reduce(0) { $0 + $1.total }
        guard grand > 0 else { return [] }

        return totals.values
            .sorted { $0.total > $1.total }
            .map { entry in
                CategorySlice(
                    id: entry.cat.id,
                    name: entry.cat.name,
                    emoji: entry.cat.emoji,
                    colorHex: entry.cat.colorHex,
                    total: entry.total,
                    percent: entry.total / grand
                )
            }
    }

    private func buildDailyTrend(_ transactions: [Transaction], from start: Date, to end: Date, calendar: Calendar) -> [DailyPoint] {
        let startDay = calendar.startOfDay(for: start)
        let endDay   = calendar.startOfDay(for: end)

        var netByDay: [Date: Double] = [:]
        for tx in transactions {
            let day = calendar.startOfDay(for: tx.date)
            netByDay[day, default: 0] += tx.signedAmount
        }

        var points: [DailyPoint] = []
        var running = 0.0
        var cursor = startDay
        while cursor <= endDay {
            running += netByDay[cursor] ?? 0
            points.append(DailyPoint(date: cursor, netAmount: running))
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return points
    }
}
