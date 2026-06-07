import Foundation
import WidgetKit

struct WidgetSnapshot: Codable {
    let balance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let recentTransactions: [WidgetSnapshotTransaction]
}

struct WidgetSnapshotTransaction: Codable {
    let title: String
    let amount: Double
    let isIncome: Bool
    let emoji: String
}

enum WidgetDataService {
    private static let suiteID = "group.com.argudev.FinTrackPro"
    private static let key = "ft.widgetSnapshot"

    @MainActor
    static func write(
        balance: Double,
        income: Double,
        expenses: Double,
        recent: [Transaction]
    ) {
        guard let defaults = UserDefaults(suiteName: suiteID) else { return }
        let snapshot = WidgetSnapshot(
            balance: balance,
            monthlyIncome: income,
            monthlyExpenses: expenses,
            recentTransactions: recent.map {
                WidgetSnapshotTransaction(
                    title: $0.title,
                    amount: $0.amount,
                    isIncome: $0.isIncome,
                    emoji: $0.category?.emoji ?? "📌"
                )
            }
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
        defaults.synchronize()
        #if DEBUG
        let written = defaults.data(forKey: key) != nil
        print("WidgetDataService: wrote snapshot — balance=\(balance), readable=\(written), suite=\(suiteID)")
        #endif
        WidgetCenter.shared.reloadAllTimelines()
    }

    nonisolated static func read() -> WidgetSnapshot? {
        guard
            let defaults = UserDefaults(suiteName: "group.com.argudev.FinTrackPro"),
            let data = defaults.data(forKey: "ft.widgetSnapshot")
        else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
