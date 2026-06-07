import SwiftUI

struct BalanceCardView: View {
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let savingsRate: Double

    @Environment(AppState.self) private var appState

    private func formatted(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = appState.selectedCurrency
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: Swift.abs(value))) ?? "0.00"
    }

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
            Text(formatted(totalBalance))
                .font(FTTypo.amountLg())
                .foregroundStyle(
                    LinearGradient(
                        colors: totalBalance >= 0
                            ? [FTColors.positive, FTColors.positive.opacity(0.65)]
                            : [FTColors.negative,  FTColors.negative.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .contentTransition(.numericText())
                .accessibilityLabel("Available balance \(formatted(totalBalance))")
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatItem(title: "Income", value: formatted(monthlyIncome), color: FTColors.positive)
            verticalDivider
            StatItem(title: "Expenses", value: formatted(monthlyExpenses), color: FTColors.negative)
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

    private enum SavingsThreshold {
        static let healthy: Double = 0.20
        static let minimal: Double = 0.05
    }

    private var savingsColor: Color {
        if savingsRate >= SavingsThreshold.healthy { return FTColors.positive }
        if savingsRate >= SavingsThreshold.minimal { return FTColors.warning }
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
