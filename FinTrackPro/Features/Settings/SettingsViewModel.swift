import Foundation
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {

    let currencies: [(code: String, label: String)] = [
        ("USD", "US Dollar"),
        ("CAD", "Canadian Dollar"),
        ("EUR", "Euro"),
    ]

    var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "v\(v) (\(b))"
    }

    func exportCSV(transactions: [Transaction]) -> String {
        var lines = ["Date,Title,Category,Amount,Type"]
        let iso = ISO8601DateFormatter()
        for tx in transactions {
            let date   = iso.string(from: tx.date)
            let title  = tx.title.replacingOccurrences(of: ",", with: ";")
            let cat    = (tx.category?.name ?? "Uncategorized").replacingOccurrences(of: ",", with: ";")
            let amount = String(format: "%.2f", tx.amount)
            let type   = tx.isIncome ? "Income" : "Expense"
            lines.append("\(date),\(title),\(cat),\(amount),\(type)")
        }
        return lines.joined(separator: "\n")
    }

    func deleteAllData(context: ModelContext) throws {
        try context.delete(model: Transaction.self)
        try context.delete(model: Budget.self)
        try context.save()
    }
}
