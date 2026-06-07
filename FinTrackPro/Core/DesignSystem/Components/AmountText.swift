import SwiftUI

struct AmountText: View {
    let amount: Double
    var font: Font = FTTypo.data()

    @Environment(AppState.self) private var appState

    private var formatted: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = appState.selectedCurrency
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        let abs = f.string(from: NSNumber(value: Swift.abs(amount))) ?? "0.00"
        return amount >= 0 ? "+\(abs)" : "−\(abs)"
    }

    var body: some View {
        Text(formatted)
            .font(font)
            .foregroundStyle(amount >= 0 ? FTColors.positive : FTColors.negative)
    }
}

#Preview {
    VStack(spacing: FTSpacing.md) {
        AmountText(amount: 12840.50)
        AmountText(amount: -1240.00)
        AmountText(amount: 0)
        AmountText(amount: 5000, font: FTTypo.amount())
    }
    .padding()
    .background(FTColors.background)
}
