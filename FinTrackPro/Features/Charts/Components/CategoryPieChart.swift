import SwiftUI
import Charts

struct CategoryPieChart: View {
    let slices: [CategorySlice]

    var body: some View {
        if slices.isEmpty {
            emptyState
        } else {
            VStack(spacing: FTSpacing.lg) {
                donut
                legendList
            }
        }
    }

    private var donut: some View {
        Chart(slices) { slice in
            SectorMark(
                angle: .value("Amount", slice.total),
                innerRadius: .ratio(0.58),
                angularInset: 2
            )
            .foregroundStyle(Color(hexString: slice.colorHex) ?? FTColors.accent)
            .cornerRadius(4)
        }
        .chartLegend(.hidden)
        .frame(height: 220)
    }

    private var legendList: some View {
        VStack(spacing: 0) {
            ForEach(slices) { slice in
                legendRow(slice)
                if slice.id != slices.last?.id {
                    Rectangle()
                        .fill(FTColors.border)
                        .frame(height: 0.5)
                        .padding(.horizontal, FTSpacing.sm)
                }
            }
        }
    }

    private func legendRow(_ slice: CategorySlice) -> some View {
        HStack(spacing: FTSpacing.sm) {
            Circle()
                .fill(Color(hexString: slice.colorHex) ?? FTColors.accent)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            Text(slice.emoji)
                .font(.system(size: 14))
                .accessibilityHidden(true)

            Text(slice.name)
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(slice.total.absoluteCurrencyFormatted)
                    .font(FTTypo.data())
                    .foregroundStyle(FTColors.textPrimary)
                Text(slice.percent.percentFormatted)
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
        .padding(.vertical, FTSpacing.sm)
        .padding(.horizontal, FTSpacing.sm)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(slice.name), \(slice.total.absoluteCurrencyFormatted), \(slice.percent.percentFormatted)")
    }

    private var emptyState: some View {
        Text("No expenses for this period")
            .font(FTTypo.body())
            .foregroundStyle(FTColors.textDisabled)
            .frame(maxWidth: .infinity, minHeight: 220)
    }
}
