import SwiftUI

struct CategoryPicker: View {
    let categories: [Category]
    @Binding var selected: Category?
    var onAddTapped: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let columns = Array(repeating: GridItem(.flexible(), spacing: FTSpacing.sm), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: FTSpacing.sm) {
            ForEach(categories, id: \.id) { category in
                tile(for: category)
            }
            if let onAdd = onAddTapped {
                addCell(action: onAdd)
            }
        }
    }

    private func tile(for category: Category) -> some View {
        let isSelected = selected?.id == category.id
        let tileColor = Color(hexString: category.colorHex) ?? FTColors.accent

        return Button {
            selected = isSelected ? nil : category
        } label: {
            VStack(spacing: FTSpacing.xs) {
                Text(category.emoji)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .background(isSelected ? tileColor.opacity(0.25) : FTColors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: FTRadius.md)
                            .strokeBorder(isSelected ? tileColor : Color.clear, lineWidth: 1.5)
                    )
                    .scaleEffect(isSelected && !reduceMotion ? 1.08 : 1)
                    .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                Text(category.name)
                    .font(FTTypo.caption())
                    .foregroundStyle(isSelected ? tileColor : FTColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func addCell(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: FTSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(FTColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(FTColors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: FTRadius.md)
                            .strokeBorder(FTColors.border, lineWidth: 1)
                    )
                Text("New")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add new category")
    }
}
