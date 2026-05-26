import SwiftUI

struct TransactionListView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                VStack(spacing: FTSpacing.sm) {
                    Text("📋")
                        .font(.system(size: 40))
                        .accessibilityHidden(true)
                    Text("Transactions")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("Coming in Phase 5")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TransactionListView()
}
