import SwiftUI

struct CategoryIcon: View {
    let emoji: String
    let color: Color

    var body: some View {
        Text(emoji)
            .font(.system(size: 22))
            .frame(width: 44, height: 44)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.28), color.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: FTRadius.lg, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: FTRadius.lg, style: .continuous)
                    .strokeBorder(color.opacity(0.22), lineWidth: 1)
            }
    }
}

#Preview {
    HStack(spacing: FTSpacing.sm) {
        CategoryIcon(emoji: "🍔", color: FTColors.positive)
        CategoryIcon(emoji: "🚗", color: FTColors.accent)
        CategoryIcon(emoji: "💊", color: FTColors.negative)
        CategoryIcon(emoji: "🛍️", color: FTColors.warning)
        CategoryIcon(emoji: "💼", color: FTColors.positive)
    }
    .padding()
    .background(FTColors.background)
}
