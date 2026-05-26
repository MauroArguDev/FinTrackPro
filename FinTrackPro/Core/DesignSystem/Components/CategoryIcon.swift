import SwiftUI

struct CategoryIcon: View {
    let emoji: String
    let color: Color

    var body: some View {
        Text(emoji)
            .font(.system(size: 16))
            .frame(width: 32, height: 32)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
