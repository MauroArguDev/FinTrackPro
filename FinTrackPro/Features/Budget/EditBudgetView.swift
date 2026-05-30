import SwiftUI
import SwiftData

struct EditBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    @Query private var budgets: [Budget]

    @State private var limits: [UUID: String] = [:]
    @FocusState private var focusedCategory: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        hint
                        categoryForm
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
            }
            .navigationTitle("Edit Budgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.positive)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedCategory = nil }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.textPrimary)
                        .padding(.horizontal, FTSpacing.md)
                        .padding(.vertical, FTSpacing.xs)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.35), .white.opacity(0.08)],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                        )
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                        .accessibilityLabel("Dismiss keyboard")
                }
            }
        }
        .onAppear { loadCurrentLimits() }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var hint: some View {
        Text("Set a monthly spending limit per category. Leave blank to remove a budget.")
            .font(FTTypo.caption())
            .foregroundStyle(FTColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryForm: some View {
        VStack(spacing: 0) {
            ForEach(categories) { category in
                categoryRow(category)
                if category.id != categories.last?.id {
                    Rectangle()
                        .fill(FTColors.border)
                        .frame(height: 0.5)
                        .padding(.horizontal, FTSpacing.md)
                }
            }
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: FTRadius.lg)
                .strokeBorder(FTColors.border, lineWidth: 0.5)
        }
    }

    private func categoryRow(_ category: Category) -> some View {
        let color = Color(hexString: category.colorHex) ?? FTColors.accent
        return HStack(spacing: FTSpacing.md) {
            CategoryIcon(emoji: category.emoji, color: color)

            Text(category.name)
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.textPrimary)

            Spacer()

            HStack(spacing: FTSpacing.xs) {
                Text("$")
                    .font(FTTypo.data())
                    .foregroundStyle(FTColors.textSecondary)
                TextField("No limit", text: limitBinding(for: category))
                    .font(FTTypo.data())
                    .foregroundStyle(FTColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedCategory, equals: category.id)
                    .frame(width: 72)
                    .accessibilityLabel("\(category.name) budget limit")
            }
        }
        .padding(.vertical, FTSpacing.sm)
        .padding(.horizontal, FTSpacing.md)
    }

    private func limitBinding(for category: Category) -> Binding<String> {
        Binding(
            get: { limits[category.id] ?? "" },
            set: { limits[category.id] = $0 }
        )
    }

    private func loadCurrentLimits() {
        let month = Budget.currentMonthYear()
        for budget in budgets where budget.monthYear == month {
            guard let cid = budget.category?.id else { continue }
            let value = budget.limit
            limits[cid] = value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value))
                : String(format: "%.2f", value)
        }
    }

    private func save() {
        let month = Budget.currentMonthYear()
        for category in categories {
            let text = limits[category.id] ?? ""

            if text.isEmpty {
                if let existing = budgets.first(where: {
                    $0.category?.id == category.id && $0.monthYear == month
                }) {
                    context.delete(existing)
                }
                continue
            }

            guard let limit = Double(text), limit > 0 else { continue }

            if let existing = budgets.first(where: {
                $0.category?.id == category.id && $0.monthYear == month
            }) {
                existing.limit = limit
            } else {
                context.insert(Budget(monthYear: month, limit: limit, category: category))
            }
        }
        try? context.save()
    }
}

#Preview {
    EditBudgetView()
        .modelContainer(PreviewSampleData.container)
}
