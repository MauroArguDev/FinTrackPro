import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double
    var title: String
    var note: String?
    var isIncome: Bool
    @Relationship(deleteRule: .nullify) var category: Category?

    var isExpense: Bool { !isIncome }
    var signedAmount: Double { isIncome ? amount : -amount }

    init(
        amount: Double,
        title: String,
        note: String? = nil,
        date: Date = .now,
        isIncome: Bool = false,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.title = title
        self.note = note
        self.date = date
        self.isIncome = isIncome
        self.category = category
    }
}
