import WidgetKit
import Foundation

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

struct WidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct FinTrackWidgetProvider: TimelineProvider {
    private static let suiteID = "group.com.argudev.FinTrackPro"
    private static let key = "ft.widgetSnapshot"

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: .now, snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: .now, snapshot: cachedSnapshot() ?? .preview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: .now, snapshot: cachedSnapshot() ?? .preview)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func cachedSnapshot() -> WidgetSnapshot? {
        guard
            let defaults = UserDefaults(suiteName: Self.suiteID),
            let data = defaults.data(forKey: Self.key)
        else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}

extension WidgetSnapshot {
    static let preview = WidgetSnapshot(
        balance: 3_240.50,
        monthlyIncome: 5_000.00,
        monthlyExpenses: 1_759.50,
        recentTransactions: [
            WidgetSnapshotTransaction(title: "Groceries", amount: 85.20,   isIncome: false, emoji: "🍔"),
            WidgetSnapshotTransaction(title: "Salary",    amount: 5_000.00, isIncome: true,  emoji: "💼"),
            WidgetSnapshotTransaction(title: "Netflix",   amount: 15.99,   isIncome: false, emoji: "🎮"),
        ]
    )
}
