import SwiftUI
import Charts

struct TrendLineChart: View {
    let points: [DailyPoint]

    private var lineColor: Color {
        (points.last?.netAmount ?? 0) >= 0 ? FTColors.positive : FTColors.negative
    }

    var body: some View {
        if points.isEmpty {
            emptyState
        } else {
            chart
        }
    }

    private var chart: some View {
        Chart(points) { point in
            AreaMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Net", point.netAmount)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [lineColor.opacity(0.30), lineColor.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Net", point.netAmount)
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))

            RuleMark(y: .value("Zero", 0))
                .foregroundStyle(FTColors.border)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine().foregroundStyle(FTColors.border)
                AxisValueLabel(format: .dateTime.month(.abbreviated))
                    .font(FTTypo.label())
                    .foregroundStyle(FTColors.textDisabled)
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
        let sign = value < 0 ? "-" : ""
        switch a {
        case 1_000_000...: return "\(sign)$\(String(format: "%.1f", a / 1_000_000))M"
        case 1_000...:     return "\(sign)$\(String(format: "%.0f", a / 1_000))k"
        default:           return "\(sign)$\(String(format: "%.0f", a))"
        }
    }

    private var emptyState: some View {
        Text("No data for this period")
            .font(FTTypo.body())
            .foregroundStyle(FTColors.textDisabled)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
}
