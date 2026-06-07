import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    let onSeeAll: () -> Void

    var body: some View {
        VStack(spacing: FTSpacing.md) {
            header
            content
        }
    }

    private var header: some View {
        HStack {
            Text("Recent")
                .font(FTTypo.h2())
                .foregroundStyle(FTColors.textPrimary)
            Spacer()
            Button("See all", action: onSeeAll)
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.positive)
                .accessibilityLabel("See all transactions")
        }
    }

    @ViewBuilder
    private var content: some View {
        if transactions.isEmpty {
            emptyState
        } else {
            transactionsList
        }
    }

    private var transactionsList: some View {
        VStack(spacing: 0) {
            ForEach(transactions, id: \.id) { transaction in
                TransactionRowView(transaction: transaction)
                    .padding(.horizontal, FTSpacing.md)
                if transaction.id != transactions.last?.id {
                    Rectangle()
                        .fill(FTColors.border)
                        .frame(height: 0.5)
                        .padding(.horizontal, FTSpacing.md)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.vertical, FTSpacing.sm)
        .ftCard()
    }

    private var emptyState: some View {
        VStack(spacing: FTSpacing.sm) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)
            Text("No transactions yet")
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textDisabled)
        }
        .frame(maxWidth: .infinity)
        .padding(FTSpacing.xl)
        .ftCard()
    }
}
