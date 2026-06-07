import WidgetKit
import SwiftUI

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0x1AAFBF))
                Text("FinTrack")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0x8FA3BF))
            }

            Spacer()

            Text(entry.snapshot.balance.widgetFormatted)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(entry.snapshot.balance >= 0 ? Color(widgetHex: 0x00D68F) : Color(widgetHex: 0xFF4B6E))
                .minimumScaleFactor(0.55)
                .lineLimit(1)

            Text("Balance")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(widgetHex: 0x4A6080))
                .padding(.top, 2)

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("In")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(widgetHex: 0x8FA3BF))
                    Text(entry.snapshot.monthlyIncome.widgetFormatted)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(widgetHex: 0x00D68F))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Out")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(widgetHex: 0x8FA3BF))
                    Text(entry.snapshot.monthlyExpenses.widgetFormatted)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(widgetHex: 0xFF4B6E))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "fintrackpro://dashboard"))
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            balancePanel
            Rectangle()
                .fill(Color(widgetHex: 0x152A42))
                .frame(width: 0.5)
                .padding(.vertical, 4)
            recentPanel
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "fintrackpro://dashboard"))
    }

    private var balancePanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0x1AAFBF))
                Text("FinTrack")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0x8FA3BF))
            }

            Spacer()

            Text("Balance")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(widgetHex: 0x4A6080))

            Text(entry.snapshot.balance.widgetFormatted)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(entry.snapshot.balance >= 0 ? Color(widgetHex: 0x00D68F) : Color(widgetHex: 0xFF4B6E))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer()

            HStack(spacing: 3) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0x00D68F))
                Text(entry.snapshot.monthlyIncome.widgetFormatted)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(widgetHex: 0x00D68F))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.top, 4)

            HStack(spacing: 3) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color(widgetHex: 0xFF4B6E))
                Text(entry.snapshot.monthlyExpenses.widgetFormatted)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(widgetHex: 0xFF4B6E))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.top, 2)
        }
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    private var recentPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(widgetHex: 0x8FA3BF))

            if entry.snapshot.recentTransactions.isEmpty {
                Spacer()
                Text("No transactions")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(widgetHex: 0x4A6080))
                Spacer()
            } else {
                ForEach(Array(entry.snapshot.recentTransactions.prefix(3).enumerated()), id: \.offset) { _, tx in
                    WidgetTransactionRow(transaction: tx)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Transaction Row

private struct WidgetTransactionRow: View {
    let transaction: WidgetSnapshotTransaction

    var body: some View {
        HStack(spacing: 6) {
            Text(transaction.emoji)
                .font(.system(size: 13))
                .frame(width: 24, height: 24)
                .background(Color(widgetHex: 0x152A42))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(transaction.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(widgetHex: 0xEEF2F7))
                .lineLimit(1)

            Spacer()

            Text(transaction.isIncome
                 ? "+\(transaction.amount.widgetFormatted)"
                 : "-\(transaction.amount.widgetFormatted)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(transaction.isIncome
                    ? Color(widgetHex: 0x00D68F)
                    : Color(widgetHex: 0xFF4B6E))
                .lineLimit(1)
        }
    }
}

// MARK: - Widget Configurations

struct FinTrackSmallWidget: Widget {
    let kind = "FinTrackSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinTrackWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(Color(widgetHex: 0x0C1F34), for: .widget)
        }
        .configurationDisplayName("Balance")
        .description("Monthly balance at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct FinTrackMediumWidget: Widget {
    let kind = "FinTrackMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinTrackWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(Color(widgetHex: 0x0C1F34), for: .widget)
        }
        .configurationDisplayName("Balance & Transactions")
        .description("Balance and your last 3 transactions.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget-scoped helpers

private extension Double {
    var widgetFormatted: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: abs(self))) ?? "$0"
    }
}

private extension Color {
    init(widgetHex hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:     Double((hex >> 16) & 0xff) / 255,
            green:   Double((hex >> 08) & 0xff) / 255,
            blue:    Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
