import Foundation

extension Double {
    var currencyFormatted: String {
        Self.makeCurrencyFormatter().string(from: NSNumber(value: self)) ?? "$0.00"
    }

    var absoluteCurrencyFormatted: String {
        Self.makeCurrencyFormatter().string(from: NSNumber(value: abs(self))) ?? "$0.00"
    }

    var percentFormatted: String {
        Self.percent.string(from: NSNumber(value: self)) ?? "0%"
    }

    private static func makeCurrencyFormatter() -> NumberFormatter {
        let code = UserDefaults.standard.string(forKey: "ft.currency") ?? "USD"
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }

    private static let percent: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        return f
    }()
}
