import AppIntents
import SwiftData
import WidgetKit

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Log a new expense in FinTrack Pro")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Amount", description: "Expense amount in dollars")
    var amount: Double

    @Parameter(title: "Category", description: "Expense category name", default: "Other")
    var category: String

    @Parameter(title: "Description", description: "What the expense was for")
    var note: String?

    @MainActor
    func perform() async throws -> some ReturnsValue<Double> & ProvidesDialog {
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
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        let catName = category
        let catDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate<Category> { $0.name == catName }
        )
        let matched = try? context.fetch(catDescriptor).first

        let txTitle = note ?? category
        let transaction = Transaction(amount: amount, title: txTitle, isIncome: false, category: matched)
        context.insert(transaction)
        try context.save()

        let allDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let allTx = (try? context.fetch(allDescriptor)) ?? []
        let balance = allTx.reduce(0.0) { $0 + $1.signedAmount }
        let monthStart = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: .now)
        ) ?? .now
        let income = allTx.filter { $0.isIncome && $0.date >= monthStart }.reduce(0.0) { $0 + $1.amount }
        let expenses = allTx.filter { !$0.isIncome && $0.date >= monthStart }.reduce(0.0) { $0 + $1.amount }
        let recent = Array(allTx.prefix(3))
        WidgetDataService.write(balance: balance, income: income, expenses: expenses, recent: recent)

        let formatted = amount.currencyFormatted
        return .result(
            value: amount,
            dialog: IntentDialog("Added \(formatted) for \(txTitle)")
        )
    }
}
