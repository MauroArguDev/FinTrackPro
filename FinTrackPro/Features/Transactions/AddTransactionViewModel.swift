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
        amountCents > 0
            && !title.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedCategory != nil
    }

    func save(context: ModelContext) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedNote  = note.trimmingCharacters(in: .whitespaces)
        let amount       = Double(amountCents) / 100.0

        guard amountCents > 0 else {
            throw FinTrackError.saveFailed(underlying: SaveError.invalidAmount)
        }
        guard !trimmedTitle.isEmpty else {
            throw FinTrackError.saveFailed(underlying: SaveError.emptyTitle)
        }

        let transaction = Transaction(
            amount: amount,
            title: trimmedTitle,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
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

    private enum SaveError: Error {
        case invalidAmount
        case emptyTitle
    }
}
