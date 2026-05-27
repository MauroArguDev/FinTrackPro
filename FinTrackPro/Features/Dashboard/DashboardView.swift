import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = DashboardViewModel()
    @State private var transactionIntent: TransactionIntent?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FTSpacing.lg) {
                    BalanceCardView(
                        totalBalance: viewModel.totalBalance,
                        monthlyIncome: viewModel.monthlyIncome,
                        monthlyExpenses: viewModel.monthlyExpenses,
                        savingsRate: viewModel.savingsRate
                    )
                    QuickActionsView(
                        onAddExpense: { transactionIntent = TransactionIntent(isIncome: false) },
                        onAddIncome:  { transactionIntent = TransactionIntent(isIncome: true) }
                    )
                    RecentTransactionsView(
                        transactions: viewModel.recentTransactions,
                        onSeeAll: { selectedTab = .transactions }
                    )
                }
                .padding(.horizontal, FTSpacing.lg)
                .padding(.top, FTSpacing.lg)
                .padding(.bottom, FTSpacing.xxxl)
            }
            .background(FTColors.background)
            .navigationTitle("FinTrack Pro")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: transactions, initial: true) { _, updated in
            viewModel.update(with: updated)
        }
        .sheet(item: $transactionIntent) { intent in
            AddTransactionView(isIncome: intent.isIncome)
        }
    }
}

#Preview {
    DashboardView(selectedTab: .constant(.dashboard))
        .modelContainer(PreviewSampleData.container)
}
