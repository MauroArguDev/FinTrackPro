import SwiftUI
import Charts

struct MonthlyBarChart: View {
    let bars: [MonthlyBar]

    var body: some View {
        if bars.allSatisfy({ $0.income == 0 && $0.expenses == 0 }) {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: FTSpacing.md) {
                legend
                chart
            }
        }
    }

    private var legend: some View {
        HStack(spacing: FTSpacing.lg) {
            legendDot(FTColors.positive, "Income")
            legendDot(FTColors.negative, "Expenses")
            Spacer()
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: FTSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 14, height: 5)
            Text(label)
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(bars) { bar in
                BarMark(
                    x: .value("Month", bar.monthLabel),
                    y: .value("Income", bar.income)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [FTColors.positive, FTColors.positive.opacity(0.7)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .position(by: .value("Type", "Income"))
                .cornerRadius(4)

                BarMark(
                    x: .value("Month", bar.monthLabel),
                    y: .value("Expenses", bar.expenses)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [FTColors.negative, FTColors.negative.opacity(0.7)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .position(by: .value("Type", "Expenses"))
                .cornerRadius(4)
            }
        }
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let s = value.as(String.self) {
                        Text(s)
                            .font(FTTypo.label())
                            .foregroundStyle(FTColors.textDisabled)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(FTColors.border)
                AxisValueLabel {
                    if let d = value.as(Double.self) {
                        Text(abbreviated(d))
                            .font(FTTypo.label())
                            .foregroundStyle(FTColors.textDisabled)
                    }
                }
            }
        }
        .frame(height: 200)
    }

    private func abbreviated(_ value: Double) -> String {
        let a = abs(value)
        switch a {
        case 1_000_000...: return "$\(String(format: "%.1f", a / 1_000_000))M"
        case 1_000...:     return "$\(String(format: "%.0f", a / 1_000))k"
        default:           return "$\(String(format: "%.0f", a))"
        }
    }

    private var emptyState: some View {
        Text("No data for this period")
            .font(FTTypo.body())
            .foregroundStyle(FTColors.textDisabled)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
}
