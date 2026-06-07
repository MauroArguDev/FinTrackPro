import SwiftUI
import SwiftData

struct ChartsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = ChartsViewModel()
    @State private var selectedPeriod: ChartPeriod = .threeMonths

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                if transactions.isEmpty {
                    emptyState
                } else {
                    scrollContent
                }
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: transactions, initial: true) { _, tx in
            viewModel.update(transactions: tx, period: selectedPeriod)
        }
        .onChange(of: selectedPeriod) { _, period in
            viewModel.update(transactions: transactions, period: period)
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: FTSpacing.lg) {
                PeriodPicker(selected: $selectedPeriod)
                    .padding(.horizontal, FTSpacing.lg)

                summaryRow

                chartCard("Income vs Expenses") {
                    MonthlyBarChart(bars: viewModel.monthlyBarData)
                }

                chartCard("Spending by Category") {
                    CategoryPieChart(slices: viewModel.categoryPieData)
                }

                chartCard("Balance Trend") {
                    TrendLineChart(points: viewModel.dailyTrendData)
                }
            }
            .padding(.top, FTSpacing.lg)
            .padding(.bottom, FTSpacing.xxxl)
        }
        .scrollIndicators(.hidden)
    }

    private var summaryRow: some View {
        HStack(spacing: FTSpacing.md) {
            summaryCard(
                title: "Income",
                value: viewModel.totalIncome.absoluteCurrencyFormatted,
                color: FTColors.positive
            )
            summaryCard(
                title: "Expenses",
                value: viewModel.totalExpenses.absoluteCurrencyFormatted,
                color: FTColors.negative
            )
        }
        .padding(.horizontal, FTSpacing.lg)
    }

    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text(title)
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
            Text(value)
                .font(FTTypo.bodySemi())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FTSpacing.md)
        .ftCard()
    }

    @ViewBuilder
    private func chartCard<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: FTSpacing.md) {
            Text(title)
                .font(FTTypo.h2())
                .foregroundStyle(FTColors.textPrimary)
            content()
        }
        .padding(FTSpacing.lg)
        .ftCard()
        .padding(.horizontal, FTSpacing.lg)
    }

    private var emptyState: some View {
        VStack(spacing: FTSpacing.md) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)
            Text("No data yet")
                .font(FTTypo.h2())
                .foregroundStyle(FTColors.textPrimary)
            Text("Add transactions to see your charts.")
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FTSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ChartsView()
        .modelContainer(PreviewSampleData.container)
}
