import SwiftUI

struct AmountText: View {
    let amount: Double
    var font: Font = FTTypo.data()

    private var formatted: String {
        let value = abs(amount).absoluteCurrencyFormatted
        return amount >= 0 ? "+\(value)" : "−\(value)"
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
