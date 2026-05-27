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
                .padding(.vertical, FTSpacing.sm)
                .contentShape(Rectangle())
                .onTapGesture { amountFocused = true }

            TextField("", text: $rawDigits)
                .keyboardType(.numberPad)
                .focused($amountFocused)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .accessibilityLabel("Amount input")

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
        VStack(spacing: FTSpacing.xl) {
            titleSection
            categorySection
            dateSection
            noteSection
        }
    }

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

    private var titleSection: some View {
        let isEmpty = didAttemptSave && viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty
        return VStack(spacing: 0) {
            sectionHeader("TITLE", isError: isEmpty)
            sectionDivider
            TextField("e.g. Grocery run", text: $viewModel.title)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .focused($titleFocused)
                .submitLabel(.done)
                .onSubmit { titleFocused = false }
                .accessibilityLabel("Transaction title")
                .padding(FTSpacing.md)
            if isEmpty {
                sectionDivider
                Text("Title is required")
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
                .strokeBorder(isEmpty ? FTColors.negative : Color.clear, lineWidth: 1.5)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    private var categorySection: some View {
        let needsSelection = didAttemptSave && viewModel.selectedCategory == nil
        return VStack(spacing: 0) {
            sectionHeader("CATEGORY", isError: needsSelection)
            sectionDivider
            if categories.isEmpty {
                Text("No categories available")
                    .font(FTTypo.body())
                    .foregroundStyle(FTColors.textDisabled)
                    .padding(FTSpacing.md)
            } else {
                CategoryPicker(categories: categories, selected: $viewModel.selectedCategory)
                    .padding(FTSpacing.sm)
            }
            if needsSelection {
                sectionDivider
                Text("Select a category")
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
                .strokeBorder(needsSelection ? FTColors.negative : Color.clear, lineWidth: 1.5)
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: didAttemptSave)
    }

    private var dateSection: some View {
        VStack(spacing: 0) {
            sectionHeader("DATE")
            sectionDivider
            HStack {
                DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(FTColors.positive)
                    .accessibilityLabel("Transaction date")
                Spacer()
            }
            .padding(FTSpacing.md)
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
    }

    private var noteSection: some View {
        VStack(spacing: 0) {
            sectionHeader("NOTE (OPTIONAL)")
            sectionDivider
            TextField("Add a note…", text: $viewModel.note, axis: .vertical)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(3)
                .accessibilityLabel("Note")
                .padding(FTSpacing.md)
        }
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
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
