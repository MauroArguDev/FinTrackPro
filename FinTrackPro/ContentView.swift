import SwiftUI

enum AppTab: Hashable {
    case dashboard, transactions, add, budget, charts
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showAddTransaction = false

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
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(AppTab.dashboard)
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            TransactionListView()
                .tag(AppTab.transactions)
                .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle.fill") }

            Color.clear
                .tag(AppTab.add)
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }

            BudgetView()
                .tag(AppTab.budget)
                .tabItem { Label("Budget", systemImage: "chart.bar.fill") }

            ChartsView()
                .tag(AppTab.charts)
                .tabItem { Label("Charts", systemImage: "chart.pie.fill") }
        }
        .tint(FTColors.positive)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .add {
                selectedTab = .dashboard
                showAddTransaction = true
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
}
