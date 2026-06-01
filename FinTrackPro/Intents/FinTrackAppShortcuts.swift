import AppIntents

struct FinTrackAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add expense in \(.applicationName)",
                "Log a purchase in \(.applicationName)",
                "Record expense in \(.applicationName)"
            ],
            shortTitle: "Add Expense",
            systemImageName: "dollarsign.circle.fill"
        )
        AppShortcut(
            intent: CheckBalanceIntent(),
            phrases: [
                "Check my balance in \(.applicationName)",
                "What's my balance in \(.applicationName)",
                "Show balance in \(.applicationName)"
            ],
            shortTitle: "Check Balance",
            systemImageName: "chart.bar.fill"
        )
    }
}
