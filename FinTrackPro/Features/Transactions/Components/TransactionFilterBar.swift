import SwiftUI

struct TransactionFilterBar: View {
    @Binding var selectedFilter: TransactionFilter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FTSpacing.sm) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    pill(for: filter)
                }
            }
            .padding(.horizontal, FTSpacing.lg)
            .padding(.vertical, FTSpacing.sm)
        }
    }

    private func pill(for filter: TransactionFilter) -> some View {
        let isSelected = selectedFilter == filter
        return Button {
            withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.label)
                .font(FTTypo.caption())
                .foregroundStyle(isSelected ? FTColors.background : FTColors.textSecondary)
                .padding(.horizontal, FTSpacing.md)
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
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : FTColors.border, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(filter.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var filter = TransactionFilter.all
    TransactionFilterBar(selectedFilter: $filter)
        .padding(.vertical)
        .background(FTColors.background)
}
