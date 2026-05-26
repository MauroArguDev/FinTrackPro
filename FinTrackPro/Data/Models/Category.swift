import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category) var transactions: [Transaction]

    init(name: String, emoji: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.transactions = []
    }

    static func defaults() -> [Category] {
        [
            Category(name: "Food",            emoji: "🍔", colorHex: "#00D68F"),
            Category(name: "Transport",       emoji: "🚗", colorHex: "#1AAFBF"),
            Category(name: "Entertainment",   emoji: "🎮", colorHex: "#B026FF"),
            Category(name: "Health",          emoji: "💊", colorHex: "#FF4B6E"),
            Category(name: "Shopping",        emoji: "🛍️", colorHex: "#F0A500"),
            Category(name: "Home",            emoji: "🏠", colorHex: "#00A86B"),
            Category(name: "Education",       emoji: "📚", colorHex: "#1AAFBF"),
            Category(name: "Salary",          emoji: "💼", colorHex: "#00D68F"),
            Category(name: "Freelance",       emoji: "💻", colorHex: "#00D68F"),
            Category(name: "Other",           emoji: "📌", colorHex: "#8FA3BF"),
        ]
    }
}
