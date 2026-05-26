import SwiftUI

struct PillBadge: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(FTTypo.caption())
            .foregroundStyle(color)
            .padding(.horizontal, FTSpacing.sm)
            .padding(.vertical, FTSpacing.xs)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: FTSpacing.sm) {
        PillBadge(label: "Income", color: FTColors.positive)
        PillBadge(label: "Expense", color: FTColors.negative)
        PillBadge(label: "Warning", color: FTColors.warning)
        PillBadge(label: "Neutral", color: FTColors.accent)
    }
    .padding()
    .background(FTColors.background)
}
