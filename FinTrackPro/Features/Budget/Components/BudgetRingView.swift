import SwiftUI

struct BudgetRingView: View {
    let usagePercent: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ringColor: Color {
        if usagePercent >= 0.85 { return FTColors.negative }
        if usagePercent >= 0.60 { return FTColors.warning }
        return FTColors.positive
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FTColors.elevated, lineWidth: 20)
                .accessibilityHidden(true)

            Circle()
                .trim(from: 0, to: min(1, usagePercent))
                .stroke(
                    LinearGradient(
                        colors: [ringColor, ringColor.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    reduceMotion ? .none : .spring(response: 0.8, dampingFraction: 0.75),
                    value: usagePercent
                )
                .accessibilityHidden(true)

            VStack(spacing: FTSpacing.xs) {
                Text(min(usagePercent, 9.99).percentFormatted)
                    .font(FTTypo.h1())
                    .foregroundStyle(ringColor)
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: usagePercent)

                Text("of budget")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
        .frame(width: 180, height: 180)
        .padding(10)
        .accessibilityLabel("Budget usage \(usagePercent.percentFormatted)")
    }
}

#Preview {
    VStack(spacing: FTSpacing.xl) {
        BudgetRingView(usagePercent: 0.42)
        BudgetRingView(usagePercent: 0.73)
        BudgetRingView(usagePercent: 1.12)
    }
    .padding()
    .background(FTColors.background)
}
