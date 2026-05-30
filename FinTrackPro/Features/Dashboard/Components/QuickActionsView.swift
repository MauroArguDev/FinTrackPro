import SwiftUI

struct QuickActionsView: View {
    let onAddExpense: () -> Void
    let onAddIncome: () -> Void

    var body: some View {
        HStack(spacing: FTSpacing.md) {
            actionButton(label: "Add Expense", icon: "minus.circle.fill", color: FTColors.negative, action: onAddExpense)
            actionButton(label: "Add Income",  icon: "plus.circle.fill",  color: FTColors.positive, action: onAddIncome)
        }
    }

    @ViewBuilder
    private func actionButton(
        label: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: FTSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(FTTypo.bodySemi())
                    .foregroundStyle(FTColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, FTSpacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: FTRadius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: FTRadius.lg)
                    .strokeBorder(FTColors.border, lineWidth: 0.5)
            }
        }
        .buttonStyle(QuickActionStyle())
        .accessibilityLabel(label)
    }
}

private struct QuickActionStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

#Preview {
    QuickActionsView(onAddExpense: {}, onAddIncome: {})
        .padding()
        .background(FTColors.background)
}
