import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var budgets: [Budget]
    @State private var viewModel = BudgetViewModel()
    @State private var showEditBudget = false

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { showEditBudget = true }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.positive)
                        .accessibilityLabel("Edit budgets")
                }
            }
        }
        .sheet(isPresented: $showEditBudget) {
            EditBudgetView()
        }
        .onChange(of: transactions, initial: true) { _, tx in
            viewModel.update(transactions: tx, budgets: budgets)
        }
        .onChange(of: budgets) { _, b in
            viewModel.update(transactions: transactions, budgets: b)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.categoryUsages.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: FTSpacing.lg) {
                    ringCard
                    barsSection
                }
                .padding(.horizontal, FTSpacing.lg)
                .padding(.top, FTSpacing.lg)
                .padding(.bottom, FTSpacing.xxxl)
            }
        }
    }

    private var ringCard: some View {
        VStack(spacing: FTSpacing.md) {
            Text("Monthly Overview")
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
                .kerning(0.5)

            BudgetRingView(usagePercent: viewModel.overallUsagePercent)

            if !viewModel.overBudgetCategories.isEmpty {
                overBudgetPills
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FTSpacing.lg)
        .ftCard()
    }

    private var overBudgetPills: some View {
        VStack(spacing: FTSpacing.xs) {
            Text("Over budget")
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.negative)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FTSpacing.sm) {
                    ForEach(viewModel.overBudgetCategories) { usage in
                        PillBadge(label: usage.category.name, color: FTColors.negative)
                    }
                }
                .padding(.horizontal, FTSpacing.lg)
            }
        }
    }

    private var barsSection: some View {
        VStack(spacing: FTSpacing.md) {
            HStack {
                Text("By Category")
                    .font(FTTypo.h2())
                    .foregroundStyle(FTColors.textPrimary)
                Spacer()
            }
            ForEach(viewModel.categoryUsages) { usage in
                BudgetBarView(usage: usage)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: FTSpacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)

            Text("No budgets set")
                .font(FTTypo.h2())
                .foregroundStyle(FTColors.textPrimary)

            Text("Set monthly limits per category to track your spending.")
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FTSpacing.xl)

            Button("Set Budgets") { showEditBudget = true }
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.positive)
                .padding(.top, FTSpacing.sm)
                .accessibilityLabel("Set budgets")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BudgetView()
        .modelContainer(PreviewSampleData.container)
}
