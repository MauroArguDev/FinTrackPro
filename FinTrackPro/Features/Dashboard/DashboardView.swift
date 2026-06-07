import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = DashboardViewModel()
    @State private var transactionIntent: TransactionIntent?
    @State private var showSettings = false
    @State private var cardsVisible = false
    @State private var bounceTrigger = 0
    @State private var lastTransactionCount = 0
    @State private var didInitialize = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .keyframeAnimator(initialValue: CGFloat(1), trigger: bounceTrigger) { view, scale in
                        view.scaleEffect(scale)
                    } keyframes: { _ in
                        KeyframeTrack {
                            SpringKeyframe(reduceMotion ? 1 : 1.045, duration: 0.18, spring: .bouncy)
                            SpringKeyframe(1, duration: 0.35, spring: .smooth)
                        }
                    }
                    .opacity(cardsVisible ? 1 : 0)
                    .offset(y: cardsVisible ? 0 : 20)
                    .animation(reduceMotion ? .none : .easeOut(duration: 0.45), value: cardsVisible)

                    QuickActionsView(
                        onAddExpense: { transactionIntent = TransactionIntent(isIncome: false) },
                        onAddIncome:  { transactionIntent = TransactionIntent(isIncome: true) }
                    )
                    .opacity(cardsVisible ? 1 : 0)
                    .offset(y: cardsVisible ? 0 : 20)
                    .animation(reduceMotion ? .none : .easeOut(duration: 0.45).delay(0.08), value: cardsVisible)

                    RecentTransactionsView(
                        transactions: viewModel.recentTransactions,
                        onSeeAll: { selectedTab = .transactions }
                    )
                    .opacity(cardsVisible ? 1 : 0)
                    .offset(y: cardsVisible ? 0 : 20)
                    .animation(reduceMotion ? .none : .easeOut(duration: 0.45).delay(0.16), value: cardsVisible)
                }
                .padding(.horizontal, FTSpacing.lg)
                .padding(.top, FTSpacing.lg)
                .padding(.bottom, FTSpacing.xxxl)
            }
            .scrollIndicators(.hidden)
            .background(FTColors.background)
            .navigationTitle("FinTrack Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(FTColors.textSecondary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            guard !cardsVisible else { return }
            cardsVisible = true
        }
        .onChange(of: transactions, initial: true) { _, updated in
            viewModel.update(with: updated)
            let newCount = updated.count
            if didInitialize && newCount > lastTransactionCount {
                bounceTrigger += 1
            }
            lastTransactionCount = newCount
            didInitialize = true
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
