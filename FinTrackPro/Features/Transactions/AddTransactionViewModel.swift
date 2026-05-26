import Foundation
import Observation
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amountText: String = ""
    var title: String = ""
    var note: String = ""
    var selectedCategory: Category?
    var isIncome: Bool = false
    var date: Date = .now

    var isValid: Bool {
        parsedAmount != nil && !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
    }

    var parsedAmount: Double? {
        let cleaned = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value > 0 else { return nil }
        return value
    }

    func save(context: ModelContext) throws {
        guard let amount = parsedAmount else { throw FinTrackError.saveFailed(underlying: ValidationError.invalidAmount) }
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { throw FinTrackError.saveFailed(underlying: ValidationError.emptyTitle) }

        let transaction = Transaction(
            amount: amount,
            title: title.trimmingCharacters(in: .whitespaces),
            note: note.isEmpty ? nil : note.trimmingCharacters(in: .whitespaces),
            date: date,
            isIncome: isIncome,
            category: selectedCategory
        )
        context.insert(transaction)

        do {
            try context.save()
        } catch {
            context.delete(transaction)
            throw FinTrackError.saveFailed(underlying: error)
        }
    }

    func reset() {
        amountText = ""
        title = ""
        note = ""
        selectedCategory = nil
        isIncome = false
        date = .now
    }

    private enum ValidationError: Error {
        case invalidAmount
        case emptyTitle
    }
}
