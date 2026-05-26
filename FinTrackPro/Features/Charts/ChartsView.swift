import SwiftUI

struct ChartsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                VStack(spacing: FTSpacing.sm) {
                    Text("📈")
                        .font(.system(size: 40))
                        .accessibilityHidden(true)
                    Text("Charts")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("Coming in Phase 7")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChartsView()
}
