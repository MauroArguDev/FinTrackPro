import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: FTSpacing.md) {
            CategoryIcon(
                emoji: transaction.category?.emoji ?? "📌",
                color: Color(hexString: transaction.category?.colorHex) ?? FTColors.textSecondary
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(FTTypo.bodySemi())
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Text(transaction.date.transactionLabel)
                    .font(FTTypo.data())
                    .foregroundStyle(FTColors.textDisabled)
            }

            Spacer()

            AmountText(amount: transaction.signedAmount)
        }
        .padding(.vertical, FTSpacing.sm)
        .accessibilityElement(children: .combine)
    }
}
