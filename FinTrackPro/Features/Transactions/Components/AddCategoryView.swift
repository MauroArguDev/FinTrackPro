import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var onCreated: ((Category) -> Void)? = nil

    @State private var name = ""
    @State private var emoji = ""
    @State private var selectedColorHex = "#00D68F"
    @State private var didAttemptSave = false
    @State private var showSaveError = false
    @FocusState private var nameFocused: Bool

    private let presetColors: [(hex: String, label: String)] = [
        ("#00D68F", "Emerald"),
        ("#1AAFBF", "Teal"),
        ("#B026FF", "Purple"),
        ("#FF4B6E", "Coral"),
        ("#F0A500", "Amber"),
        ("#00A86B", "Forest"),
        ("#4A90E2", "Sky"),
        ("#8FA3BF", "Silver"),
    ]

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var trimmedEmoji: String { emoji.trimmingCharacters(in: .whitespaces) }

    private var isNameValid: Bool { !trimmedName.isEmpty && trimmedName.count <= 24 }
    private var isEmojiValid: Bool {
        guard trimmedEmoji.count == 1 else { return false }
        return trimmedEmoji.unicodeScalars.contains {
            $0.properties.isEmojiPresentation || $0.value > 0x2600
        }
    }
    private var isValid: Bool { isNameValid && isEmojiValid }

    private var previewColor: Color {
        Color(hexString: selectedColorHex) ?? FTColors.accent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        previewBadge
                        nameSection
                        emojiSection
                        colorSection
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .onAppear { nameFocused = true }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert("Save Failed", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not save the category. Please try again.")
        }
    }

    // MARK: - Preview

    private var previewBadge: some View {
        VStack(spacing: FTSpacing.sm) {
            Text(trimmedEmoji.isEmpty ? "?" : trimmedEmoji)
                .font(.system(size: 32))
                .frame(width: 72, height: 72)
                .background(previewColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: FTRadius.lg)
                        .strokeBorder(previewColor.opacity(0.5), lineWidth: 1.5)
                }
            Text(trimmedName.isEmpty ? "Category Name" : trimmedName)
                .font(FTTypo.bodySemi())
                .foregroundStyle(trimmedName.isEmpty ? FTColors.textDisabled : FTColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FTSpacing.md)
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.15), value: trimmedEmoji)
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.15), value: selectedColorHex)
    }

    // MARK: - Sections

    private func sectionHeader(_ label: String, isError: Bool = false) -> some View {
        Text(label)
            .font(FTTypo.data())
            .foregroundStyle(isError ? FTColors.negative : FTColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FTSpacing.md)
            .padding(.vertical, FTSpacing.sm)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(FTColors.border)
            .frame(height: 0.5)
    }

    private var nameSection: some View {
        let isError = didAttemptSave && !isNameValid
        return VStack(spacing: 0) {
            sectionHeader("NAME", isError: isError)
            sectionDivider
            TextField("e.g. Groceries", text: $name)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .focused($nameFocused)
                .submitLabel(.next)
                .onChange(of: name) { _, new in
                    if new.count > 24 { name = String(new.prefix(24)) }
                }
                .accessibilityLabel("Category name")
                .padding(FTSpacing.md)
            if isError {
                sectionDivider
                Text(trimmedName.isEmpty ? "Name is required" : "Maximum 24 characters")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.negative)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, FTSpacing.md)
                    .padding(.vertical, FTSpacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: FTRadius.lg)
                .strokeBorder(isError ? FTColors.negative : Color.clear, lineWidth: 1.5)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    private var emojiSection: some View {
        let isError = didAttemptSave && !isEmojiValid
        return VStack(spacing: 0) {
            sectionHeader("EMOJI", isError: isError)
            sectionDivider
            TextField("e.g. 🍔", text: $emoji)
                .font(.system(size: 28))
                .multilineTextAlignment(.center)
                .onChange(of: emoji) { _, new in
                    if new.count > 1 { emoji = String(new.suffix(1)) }
                }
                .accessibilityLabel("Category emoji")
                .padding(FTSpacing.md)
            if isError {
                sectionDivider
                Text("Enter a single emoji")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.negative)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, FTSpacing.md)
                    .padding(.vertical, FTSpacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: FTRadius.lg)
                .strokeBorder(isError ? FTColors.negative : Color.clear, lineWidth: 1.5)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    private var colorSection: some View {
        VStack(spacing: 0) {
            sectionHeader("COLOR")
            sectionDivider
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: FTSpacing.md
            ) {
                ForEach(presetColors, id: \.hex) { preset in
                    colorSwatch(hex: preset.hex, label: preset.label)
                }
            }
            .padding(FTSpacing.md)
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
    }

    private func colorSwatch(hex: String, label: String) -> some View {
        let color = Color(hexString: hex) ?? FTColors.accent
        let isSelected = selectedColorHex == hex
        return Button {
            selectedColorHex = hex
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2.5)
                        .frame(width: 44, height: 44)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(isSelected && !reduceMotion ? 1.1 : 1)
            .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textSecondary)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") { attemptSave() }
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.positive)
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            keyboardDoneButton
        }
    }

    private var keyboardDoneButton: some View {
        Button("Done") {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
        .font(FTTypo.bodySemi())
        .foregroundStyle(FTColors.textPrimary)
        .padding(.horizontal, FTSpacing.md)
        .padding(.vertical, FTSpacing.xs)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        .accessibilityLabel("Dismiss keyboard")
    }

    private func attemptSave() {
        guard isValid else {
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                didAttemptSave = true
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        let category = Category(name: trimmedName, emoji: trimmedEmoji, colorHex: selectedColorHex)
        context.insert(category)
        do {
            try context.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onCreated?(category)
            dismiss()
        } catch {
            showSaveError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
