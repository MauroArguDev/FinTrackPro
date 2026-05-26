import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                VStack(spacing: FTSpacing.sm) {
                    Text("🏠")
                        .font(.system(size: 40))
                        .accessibilityHidden(true)
                    Text("Dashboard")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("Coming in Phase 3")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DashboardView()
}
