import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                VStack(spacing: FTSpacing.sm) {
                    Text("➕")
                        .font(.system(size: 40))
                        .accessibilityHidden(true)
                    Text("Add Transaction")
                        .font(FTTypo.h2())
                        .foregroundStyle(FTColors.textPrimary)
                    Text("Coming in Phase 4")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FTColors.textSecondary)
                        .font(FTTypo.body())
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
