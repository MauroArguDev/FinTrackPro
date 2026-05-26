import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]

    @State private var viewModel = AddTransactionViewModel()
    @State private var error: FinTrackError?
    @State private var showError = false
    @FocusState private var amountFocused: Bool
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        typeToggle
                        amountSection
                        formSection
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
            }
            .navigationTitle(viewModel.isIncome ? "Add Income" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("Error", isPresented: $showError, presenting: error) { _ in
                Button("OK", role: .cancel) {}
            } message: { err in
                Text(err.errorDescription ?? "Something went wrong.")
            }
        }
        .onAppear { amountFocused = true }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var typeToggle: some View {
        HStack(spacing: 0) {
            toggleButton(label: "Expense", isSelected: !viewModel.isIncome, color: FTColors.negative) {
                viewModel.isIncome = false
            }
            toggleButton(label: "Income", isSelected: viewModel.isIncome, color: FTColors.positive) {
                viewModel.isIncome = true
            }
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
    }

    private func toggleButton(label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(FTTypo.bodySemi())
                .foregroundStyle(isSelected ? FTColors.background : FTColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FTSpacing.sm)
                .background(isSelected ? color : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var amountSection: some View {
        VStack(spacing: FTSpacing.xs) {
            Text("AMOUNT")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(FTTypo.h1())
                    .foregroundStyle(amountColor.opacity(0.7))
                TextField("0.00", text: $viewModel.amountText)
                    .font(FTTypo.amountLg())
                    .foregroundStyle(amountColor)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .focused($amountFocused)
                    .accessibilityLabel("Amount")
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, FTSpacing.lg)
        }
    }

    private var amountColor: Color {
        viewModel.isIncome ? FTColors.positive : FTColors.negative
    }

    private var formSection: some View {
        VStack(spacing: FTSpacing.md) {
            titleField
            categorySection
            dateSection
            noteField
        }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text("TITLE")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
            TextField("e.g. Grocery run", text: $viewModel.title)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .focused($titleFocused)
                .submitLabel(.done)
                .onSubmit { titleFocused = false }
                .accessibilityLabel("Transaction title")
                .padding(FTSpacing.md)
                .background(FTColors.card)
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            Text("CATEGORY")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
            if categories.isEmpty {
                Text("No categories available")
                    .font(FTTypo.body())
                    .foregroundStyle(FTColors.textDisabled)
            } else {
                CategoryPicker(categories: categories, selected: $viewModel.selectedCategory)
            }
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text("DATE")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
            DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(FTColors.positive)
                .accessibilityLabel("Transaction date")
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text("NOTE (OPTIONAL)")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
            TextField("Add a note…", text: $viewModel.note, axis: .vertical)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(3)
                .accessibilityLabel("Note")
                .padding(FTSpacing.md)
                .background(FTColors.card)
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textSecondary)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") { save() }
                .font(FTTypo.bodySemi())
                .foregroundStyle(viewModel.isValid ? FTColors.positive : FTColors.textDisabled)
                .disabled(!viewModel.isValid)
        }
    }

    private func save() {
        do {
            try viewModel.save(context: context)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        } catch let ftError as FinTrackError {
            error = ftError
            showError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        } catch {
            self.error = .saveFailed(underlying: error)
            showError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewSampleData.container)
}
