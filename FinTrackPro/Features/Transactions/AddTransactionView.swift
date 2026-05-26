import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: AddTransactionViewModel
    @State private var ftError: FinTrackError?
    @State private var showError = false
    @State private var didAttemptSave = false
    @State private var rawDigits: String = ""
    @FocusState private var amountFocused: Bool
    @FocusState private var titleFocused: Bool

    init(isIncome: Bool = false) {
        _viewModel = State(wrappedValue: AddTransactionViewModel(isIncome: isIncome))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        typeToggle
                        amountSection
                        formFields
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
            }
            .navigationTitle(viewModel.isIncome ? "Add Income" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("Error", isPresented: $showError, presenting: ftError) { _ in
                Button("OK", role: .cancel) {}
            } message: { err in
                Text(err.errorDescription ?? "Something went wrong.")
            }
        }
        .onAppear {
            amountFocused = true
            applySegmentedStyle()
        }
        .onChange(of: rawDigits) { _, new in
            let digits = String(new.filter { $0.isNumber }.prefix(8))
            viewModel.amountCents = Int(digits) ?? 0
            if digits != new { rawDigits = digits }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Toggle

    private var typeToggle: some View {
        Picker("Transaction type", selection: $viewModel.isIncome) {
            Text("Expense").tag(false)
            Text("Income").tag(true)
        }
        .pickerStyle(.segmented)
        .tint(viewModel.isIncome ? FTColors.positive : FTColors.negative)
        .accessibilityLabel("Transaction type")
    }

    // MARK: - Segmented Appearance

    private func applySegmentedStyle() {
        UISegmentedControl.appearance().backgroundColor = UIColor(FTColors.surface)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(FTColors.textSecondary)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
    }

    // MARK: - Amount

    private var amountColor: Color { viewModel.isIncome ? FTColors.positive : FTColors.negative }

    private var amountSection: some View {
        VStack(spacing: FTSpacing.xs) {
            Text("AMOUNT")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)

            Text(viewModel.displayAmount)
                .font(FTTypo.amountLg())
                .foregroundStyle(viewModel.amountCents == 0 ? FTColors.textDisabled : amountColor)
                .contentTransition(.numericText())
                .animation(reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.8), value: viewModel.amountCents)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay {
                    TextField("", text: $rawDigits)
                        .keyboardType(.numberPad)
                        .focused($amountFocused)
                        .opacity(0.001)
                        .accessibilityLabel("Amount in cents")
                }

            if didAttemptSave && viewModel.amountCents == 0 {
                Text("Enter an amount greater than zero")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.negative)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: FTSpacing.lg) {
            titleField
            categorySection
            dateRow
            noteField
        }
    }

    private var titleField: some View {
        let isEmpty = didAttemptSave && viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty
        return VStack(alignment: .leading, spacing: FTSpacing.xs) {
            Text("TITLE")
                .font(FTTypo.data())
                .foregroundStyle(isEmpty ? FTColors.negative : FTColors.textDisabled)
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
                .overlay {
                    RoundedRectangle(cornerRadius: FTRadius.md)
                        .strokeBorder(isEmpty ? FTColors.negative : Color.clear, lineWidth: 1.5)
                }
            if isEmpty {
                Text("Title is required")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.negative)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    private var categorySection: some View {
        let needsSelection = didAttemptSave && viewModel.selectedCategory == nil
        return VStack(alignment: .leading, spacing: FTSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("CATEGORY")
                    .font(FTTypo.data())
                    .foregroundStyle(needsSelection ? FTColors.negative : FTColors.textDisabled)
                Spacer()
                if needsSelection {
                    Text("Select a category")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.negative)
                        .transition(.opacity)
                }
            }
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)

            if categories.isEmpty {
                Text("No categories available")
                    .font(FTTypo.body())
                    .foregroundStyle(FTColors.textDisabled)
            } else {
                CategoryPicker(categories: categories, selected: $viewModel.selectedCategory)
                    .padding(FTSpacing.sm)
                    .background(FTColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
                    .overlay {
                        RoundedRectangle(cornerRadius: FTRadius.md)
                            .strokeBorder(needsSelection ? FTColors.negative : Color.clear, lineWidth: 1.5)
                    }
                    .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
            }
        }
    }

    private var dateRow: some View {
        HStack {
            Text("DATE")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
            Spacer()
            DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(FTColors.positive)
                .accessibilityLabel("Transaction date")
        }
        .padding(.horizontal, FTSpacing.md)
        .padding(.vertical, FTSpacing.sm + 2)
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
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
    }

    private func attemptSave() {
        guard viewModel.isValid else {
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                didAttemptSave = true
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if viewModel.amountCents == 0 { amountFocused = true }
            else if viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty { titleFocused = true }
            return
        }
        do {
            try viewModel.save(context: context)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        } catch let err as FinTrackError {
            ftError = err
            showError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        } catch {
            ftError = .saveFailed(underlying: error)
            showError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewSampleData.container)
}
