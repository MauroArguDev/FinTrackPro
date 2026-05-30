import Foundation
import Observation
import SwiftData

enum TransactionFilter: CaseIterable, Hashable {
    case all, income, expense

    var label: String {
        switch self {
        case .all:     return "All"
        case .income:  return "Income"
        case .expense: return "Expenses"
        }
    }
}

@Observable
final class TransactionListViewModel {
    var searchText: String = ""
    var selectedFilter: TransactionFilter = .all
    var selectedCategory: Category? = nil

    private(set) var allTransactions: [Transaction] = []

    func update(with transactions: [Transaction]) {
        allTransactions = transactions
    }

    var filteredTransactions: [Transaction] {
        allTransactions.filter { tx in
            let matchesType: Bool = {
                switch selectedFilter {
                case .all:     return true
                case .income:  return tx.isIncome
                case .expense: return tx.isExpense
                }
            }()
            let matchesCategory = selectedCategory == nil || tx.category?.id == selectedCategory?.id
            let matchesSearch   = searchText.isEmpty || tx.title.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesCategory && matchesSearch
        }
    }

    var groupedTransactions: [(key: String, transactions: [Transaction])] {
        var result: [(key: String, transactions: [Transaction])] = []
        for tx in filteredTransactions {
            let label = tx.date.transactionLabel
            if result.last?.key == label {
                result[result.count - 1].transactions.append(tx)
            } else {
                result.append((key: label, transactions: [tx]))
            }
        }
        return result
    }

    var isEmpty: Bool { filteredTransactions.isEmpty }

    func delete(_ transaction: Transaction, context: ModelContext) throws {
        context.delete(transaction)
        do {
            try context.save()
        } catch {
            throw FinTrackError.deleteFailed(underlying: error)
        }
    }
}
