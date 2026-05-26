import SwiftUI

struct BudgetView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                VStack(spacing: FTSpacing.sm) {
                    Text("📊")
                        .font(.system(size: 40))
                        .accessibilityHidden(true)
                    Text("Budget")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("Coming in Phase 6")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BudgetView()
}
