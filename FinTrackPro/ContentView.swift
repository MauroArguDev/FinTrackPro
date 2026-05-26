import SwiftUI

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
                showAddTransaction = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(FTColors.background)
                    .frame(width: 56, height: 56)
                    .background(FTColors.positive)
                    .clipShape(Circle())
                    .shadow(color: FTColors.positive.opacity(0.35), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(FABStyle())
            .accessibilityLabel("Add transaction")
            .padding(.bottom, 96)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
}
