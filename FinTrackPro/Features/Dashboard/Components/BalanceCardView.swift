import SwiftUI

struct BalanceCardView: View {
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let savingsRate: Double

    var body: some View {
        VStack(alignment: .leading, spacing: FTSpacing.lg) {
            balanceSection
            Rectangle()
                .fill(FTColors.border)
                .frame(height: 0.5)
                .accessibilityHidden(true)
            statsRow
        }
        .padding(FTSpacing.lg)
        .ftCard()
    }

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text("Available Balance")
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
                .kerning(0.5)
            Text(totalBalance.currencyFormatted)
                .font(FTTypo.amountLg())
                .foregroundStyle(totalBalance >= 0 ? FTColors.positive : FTColors.negative)
                .contentTransition(.numericText())
                .accessibilityLabel("Available balance \(totalBalance.absoluteCurrencyFormatted)")
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatItem(title: "Income", value: monthlyIncome.absoluteCurrencyFormatted, color: FTColors.positive)
            verticalDivider
            StatItem(title: "Expenses", value: monthlyExpenses.absoluteCurrencyFormatted, color: FTColors.negative)
            verticalDivider
            StatItem(title: "Saved", value: savingsRate.percentFormatted, color: savingsColor)
        }
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(FTColors.border)
            .frame(width: 0.5, height: 28)
            .accessibilityHidden(true)
    }

    private var savingsColor: Color {
        if savingsRate >= 0.2 { return FTColors.positive }
        if savingsRate >= 0.05 { return FTColors.warning }
        return FTColors.negative
    }
}

private struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: FTSpacing.xs) {
            Text(title)
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textSecondary)
            Text(value)
                .font(FTTypo.bodySemi())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BalanceCardView(totalBalance: 3500, monthlyIncome: 6200, monthlyExpenses: 1850, savingsRate: 0.70)
        .padding()
        .background(FTColors.background)
}
