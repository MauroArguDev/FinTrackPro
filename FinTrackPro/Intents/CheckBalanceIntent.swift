import AppIntents
import SwiftData

struct CheckBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Balance"
    static var description = IntentDescription("See your current balance in FinTrack Pro")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some ReturnsValue<Double> & ProvidesDialog {
        let balance = resolveBalance()
        let formatted = balance.currencyFormatted
        return .result(
            value: balance,
            dialog: IntentDialog("Your current balance is \(formatted)")
        )
    }

    @MainActor
    private func resolveBalance() -> Double {
        if let snapshot = WidgetDataService.read() {
            return snapshot.balance
        }
        return balanceFromStore()
    }

    @MainActor
    private func balanceFromStore() -> Double {
        let schema = Schema([Transaction.self, Category.self, Budget.self])
        let config: ModelConfiguration
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.argudev.FinTrackPro"
        ) {
            config = ModelConfiguration(
                schema: schema,
                url: groupURL.appendingPathComponent("fintrackpro.store")
            )
        } else {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else { return 0 }
        let transactions = (try? container.mainContext.fetch(FetchDescriptor<Transaction>())) ?? []
        return transactions.reduce(0.0) { $0 + $1.signedAmount }
    }
}
