import Foundation

extension Double {
    var currencyFormatted: String {
        Self.currency.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    var absoluteCurrencyFormatted: String {
        Self.currency.string(from: NSNumber(value: abs(self))) ?? "$0.00"
    }

    var percentFormatted: String {
        Self.percent.string(from: NSNumber(value: self)) ?? "0%"
    }

    private static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    private static let percent: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        return f
    }()
}
