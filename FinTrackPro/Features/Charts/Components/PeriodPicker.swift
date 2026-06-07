import SwiftUI

struct PeriodPicker: View {
    @Binding var selected: ChartPeriod
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: FTSpacing.sm) {
            ForEach(ChartPeriod.allCases, id: \.self) { period in
                pill(for: period)
            }
        }
    }

    private func pill(for period: ChartPeriod) -> some View {
        let isSelected = selected == period
        return Button {
            withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                selected = period
            }
        } label: {
            Text(period.label)
                .font(FTTypo.caption())
                .foregroundStyle(isSelected ? FTColors.background : FTColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FTSpacing.xs)
                .background(
                    Group {
                        if isSelected {
                            Capsule().fill(FTColors.positive)
                        } else {
                            Capsule().fill(.ultraThinMaterial)
                        }
                    }
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Color.clear : FTColors.border, lineWidth: 0.5
                    )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(period.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var period = ChartPeriod.threeMonths
    PeriodPicker(selected: $period)
        .padding()
        .background(FTColors.background)
}
