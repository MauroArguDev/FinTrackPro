import SwiftUI

struct BudgetBarView: View {
    let usage: CategoryUsage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var categoryColor: Color {
        Color(hexString: usage.category.colorHex) ?? FTColors.accent
    }

    private var barColor: Color {
        if usage.usage >= 0.85 { return FTColors.negative }
        if usage.usage >= 0.60 { return FTColors.warning }
        return FTColors.positive
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            HStack(spacing: FTSpacing.md) {
                CategoryIcon(emoji: usage.category.emoji, color: categoryColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(usage.category.name)
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("\(usage.spent.absoluteCurrencyFormatted) of \(usage.budget.limit.absoluteCurrencyFormatted)")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textSecondary)
                }

                Spacer()

                if usage.isOverBudget {
                    PillBadge(label: "Over budget", color: FTColors.negative)
                } else {
                    Text("\(usage.remaining.absoluteCurrencyFormatted) left")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textSecondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(FTColors.elevated)
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [barColor, barColor.opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(1, max(0, usage.usage)), height: 8)
                }
            }
            .frame(height: 8)
            .animation(
                reduceMotion ? .none : .spring(response: 0.7, dampingFraction: 0.75),
                value: usage.usage
            )
        }
        .padding(FTSpacing.lg)
        .ftCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(usage.category.name), spent \(usage.spent.absoluteCurrencyFormatted) of \(usage.budget.limit.absoluteCurrencyFormatted)")
    }
}
