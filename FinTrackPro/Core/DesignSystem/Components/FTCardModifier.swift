import SwiftUI

struct FTCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(FTColors.card)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: FTRadius.lg)
                    .strokeBorder(FTColors.border, lineWidth: 0.5)
            }
    }
}

extension View {
    func ftCard() -> some View {
        modifier(FTCardModifier())
    }
}

#Preview {
    VStack(spacing: FTSpacing.md) {
        AmountText(amount: 12840.50, font: FTTypo.amount())
    }
    .padding(FTSpacing.xl)
    .ftCard()
    .padding(FTSpacing.xl)
    .background(FTColors.background)
}
