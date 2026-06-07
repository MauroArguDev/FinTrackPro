import AppIntents

struct CheckBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Balance"
    static var description = IntentDescription("See your current balance in FinTrack Pro")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<Double> & ProvidesDialog {
        let balance = WidgetDataService.read()?.balance ?? 0
        let formatted = String(format: "$%.2f", abs(balance))
        let sign = balance < 0 ? "-" : ""
        return .result(
            value: balance,
            dialog: IntentDialog("Your current balance is \(sign)\(formatted)")
        )
    }
}
