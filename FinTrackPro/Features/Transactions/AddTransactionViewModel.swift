import Foundation
import Observation
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amountCents: Int = 0
    var title: String = ""
    var note: String = ""
    var selectedCategory: Category?
    var isIncome: Bool
    var date: Date = .now

    init(isIncome: Bool = false) {
        self.isIncome = isIncome
    }

    var displayAmount: String {
        (Double(amountCents) / 100.0).currencyFormatted
    }

    var isValid: Bool {
        amountCents > 0 && !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
    }

    func save(context: ModelContext) throws {
        guard amountCents > 0 else { throw FinTrackError.saveFailed(underlying: ValidationError.invalidAmount) }
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { throw FinTrackError.saveFailed(underlying: ValidationError.emptyTitle) }

        let amount = Double(amountCents) / 100.0
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
        amountCents = 0
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
