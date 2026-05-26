import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FTTypo.bodySemi())
            .foregroundStyle(FTColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, FTSpacing.md)
            .background(FTColors.positive)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.7 : isEnabled ? 1 : 0.4)
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: FTSpacing.lg) {
        Button("Save Transaction") {}
            .buttonStyle(PrimaryButtonStyle())
        Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
    }
    .padding(FTSpacing.xl)
    .background(FTColors.background)
}
