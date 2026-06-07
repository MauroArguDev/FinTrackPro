import SwiftUI
import SwiftData
import WidgetKit

enum AppTab: Hashable {
    case dashboard, transactions, budget, charts
}

private struct FABStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.91 : 1)
            .animation(
                reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.55),
                value: configuration.isPressed
            )
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]

    @State private var selectedTab: AppTab = .dashboard
    @State private var transactionIntent: TransactionIntent?
    @State private var showBiometricOnboarding = false

    init() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(FTColors.surface)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().unselectedItemTintColor = UIColor(FTColors.textSecondary)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(FTColors.surface)
        nav.titleTextAttributes = [.foregroundColor: UIColor(FTColors.textPrimary)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }

    var body: some View {
        ZStack {
            mainContent

            if scenePhase != .active && appState.isUnlocked {
                privacyOverlay
                    .transition(.opacity)
                    .animation(.none, value: scenePhase)
            }

            if appState.biometricEnabled && !appState.isUnlocked {
                LockScreenView()
                    .transition(.opacity)
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 0.25),
                        value: appState.isUnlocked
                    )
            }
        }
        .onChange(of: allTransactions, initial: true) { _, txns in
            writeWidgetSnapshot(txns)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetCenter.shared.reloadAllTimelines()
            }
            if phase == .background, appState.biometricEnabled {
                appState.lock()
                dismissAllPresentedSheets()
            }
        }
        .task {
            guard !appState.hasShownBiometricPrompt, appState.canUseBiometrics else { return }
            showBiometricOnboarding = true
        }
        .alert("Protect with \(appState.biometricName)?", isPresented: $showBiometricOnboarding) {
            Button("Enable \(appState.biometricName)") {
                appState.hasShownBiometricPrompt = true
                appState.biometricEnabled = true
                appState.lock()
            }
            Button("Not Now", role: .cancel) {
                appState.hasShownBiometricPrompt = true
                appState.biometricEnabled = false
            }
        } message: {
            Text(
                "FinTrack Pro can use \(appState.biometricName) to keep your financial data private. You can change this anytime in Settings."
            )
        }
    }

    private func dismissAllPresentedSheets() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .dismiss(animated: false)
    }

    private func writeWidgetSnapshot(_ transactions: [Transaction]) {
        let comps = Calendar.current.dateComponents([.year, .month], from: .now)
        let monthStart = Calendar.current.date(from: comps) ?? .now
        var balance = 0.0, income = 0.0, expenses = 0.0
        for tx in transactions {
            balance += tx.signedAmount
            guard tx.date >= monthStart else { continue }
            if tx.isIncome { income += tx.amount } else { expenses += tx.amount }
        }
        WidgetDataService.write(balance: balance, income: income, expenses: expenses, recent: Array(transactions.prefix(3)))
    }

    @ViewBuilder
    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(selectedTab: $selectedTab)
                    .tag(AppTab.dashboard)
                    .tabItem { Label("Home", systemImage: "house.fill") }

                TransactionListView()
                    .tag(AppTab.transactions)
                    .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle.fill") }

                BudgetView()
                    .tag(AppTab.budget)
                    .tabItem { Label("Budget", systemImage: "chart.bar.fill") }

                ChartsView()
                    .tag(AppTab.charts)
                    .tabItem { Label("Charts", systemImage: "chart.pie.fill") }
            }
            .tint(FTColors.positive)
            .preferredColorScheme(.dark)

            Button {
                transactionIntent = TransactionIntent(isIncome: false)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(FTColors.background)
                    .frame(width: 56, height: 56)
                    .background(FTColors.positive)
                    .clipShape(Circle())
                    .shadow(color: FTColors.positive.opacity(0.55), radius: 8,  x: 0, y: 4)
                    .shadow(color: FTColors.positive.opacity(0.20), radius: 24, x: 0, y: 10)
            }
            .buttonStyle(FABStyle())
            .accessibilityLabel("Add transaction")
            .padding(.bottom, 62)
        }
        .sheet(item: $transactionIntent) { intent in
            AddTransactionView(isIncome: intent.isIncome)
        }
    }

    @ViewBuilder
    private var privacyOverlay: some View {
        FTColors.background
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: FTSpacing.lg) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(FTColors.positive)
                        .accessibilityHidden(true)
                    Text("FinTrack Pro")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                }
            }
    }
}
