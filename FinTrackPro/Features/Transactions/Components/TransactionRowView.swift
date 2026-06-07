import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    private var categoryColor: Color {
        Color(hexString: transaction.category?.colorHex) ?? FTColors.textSecondary
    }

    var body: some View {
        HStack(spacing: FTSpacing.md) {
            CategoryIcon(
                emoji: transaction.category?.emoji ?? "📌",
                color: categoryColor
            )

            VStack(alignment: .leading, spacing: FTSpacing.xs) {
                Text(transaction.title)
                    .font(FTTypo.bodySemi())
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Text(transaction.date.transactionLabel)
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textDisabled)
            }

            Spacer()

            AmountBadge(amount: transaction.amount, isIncome: transaction.isIncome)
        }
        .padding(.vertical, FTSpacing.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(transaction.title), \(transaction.date.transactionLabel), \(transaction.isIncome ? "income" : "expense") \(transaction.amount.absoluteCurrencyFormatted)")
    }
}

private struct AmountBadge: View {
    let amount: Double
    let isIncome: Bool

    private var color: Color { isIncome ? FTColors.positive : FTColors.negative }
    private var label: String {
        let value = abs(amount).absoluteCurrencyFormatted
        return isIncome ? "+\(value)" : "-\(value)"
    }

    var body: some View {
        Text(label)
            .font(FTTypo.data())
            .foregroundStyle(color)
            .padding(.horizontal, FTSpacing.sm)
            .padding(.vertical, FTSpacing.xs)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.20), color.opacity(0.07)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
    }
}
