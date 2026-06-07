import Foundation
import SwiftData

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var monthYear: String
    var limit: Double
    @Relationship(deleteRule: .nullify) var category: Category?

    init(monthYear: String, limit: Double, category: Category? = nil) {
        self.id = UUID()
        self.monthYear = monthYear
        self.limit = limit
        self.category = category
    }

    func usage(spent: Double) -> Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    static func currentMonthYear() -> String {
        monthYear(for: .now)
    }

    static func monthYear(for date: Date) -> String {
        formatter.string(from: date)
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
