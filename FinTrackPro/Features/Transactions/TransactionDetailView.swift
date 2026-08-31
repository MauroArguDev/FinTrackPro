import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    @State private var deleteError: FinTrackError?
    @State private var showDeleteError = false

    private var categoryColor: Color {
        Color(hexString: transaction.category?.colorHex) ?? FTColors.accent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        headerSection
                        infoSection
                        deleteButton
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(transaction.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textSecondary)
                        .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { showEdit = true }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.positive)
                        .accessibilityLabel("Edit transaction")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            AddTransactionView(editing: transaction)
        }
        .alert("Delete Transaction?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { handleDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\"\(transaction.title)\" will be permanently removed.")
        }
        .alert("Error", isPresented: $showDeleteError, presenting: deleteError) { _ in
            Button("OK", role: .cancel) {}
        } message: { err in
            Text(err.errorDescription ?? "Something went wrong.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: FTSpacing.lg) {
            heroIcon
            VStack(spacing: FTSpacing.sm) {
                Text(transaction.isIncome
                     ? "+\(transaction.amount.absoluteCurrencyFormatted)"
                     : "-\(transaction.amount.absoluteCurrencyFormatted)")
                    .font(FTTypo.amountLg())
                    .foregroundStyle(
                        LinearGradient(
                            colors: transaction.isIncome
                                ? [FTColors.positive, FTColors.positive.opacity(0.65)]
                                : [FTColors.negative,  FTColors.negative.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .accessibilityLabel(
                        "\(transaction.isIncome ? "Income" : "Expense") \(transaction.amount.absoluteCurrencyFormatted)"
                    )

                PillBadge(
                    label: transaction.isIncome ? "Income" : "Expense",
                    color: transaction.isIncome ? FTColors.positive : FTColors.negative
                )
                .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FTSpacing.xl)
        .ftCard()
    }

    private var heroIcon: some View {
        Text(transaction.category?.emoji ?? "📌")
            .font(.system(size: 40))
            .frame(width: 80, height: 80)
            .background(
                LinearGradient(
                    colors: [categoryColor.opacity(0.28), categoryColor.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: FTRadius.xl, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: FTRadius.xl, style: .continuous)
                    .strokeBorder(categoryColor.opacity(0.22), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(spacing: 0) {
            infoRow(icon: "text.cursor", label: "Title", value: transaction.title)
            rowDivider
            infoRow(icon: "calendar", label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
            rowDivider
            infoRow(icon: "tag", label: "Category", value: transaction.category?.name ?? "None")
            if let note = transaction.note, !note.isEmpty {
                rowDivider
                infoRow(icon: "note.text", label: "Note", value: note)
            }
        }
        .ftCard()
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: FTSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(FTColors.textSecondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(label)
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
            Spacer()
            Text(value)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, FTSpacing.lg)
        .padding(.vertical, FTSpacing.md)
        .accessibilityElement(children: .combine)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(FTColors.border)
            .frame(height: 0.5)
            .padding(.horizontal, FTSpacing.lg)
            .accessibilityHidden(true)
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Label("Delete Transaction", systemImage: "trash")
                .font(FTTypo.bodySemi())
                .foregroundStyle(FTColors.negative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FTSpacing.md)
                .background(FTColors.negative.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
                .overlay {
                    RoundedRectangle(cornerRadius: FTRadius.lg)
                        .strokeBorder(FTColors.negative.opacity(0.25), lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete transaction")
    }

    private func handleDelete() {
        context.delete(transaction)
        do {
            try context.save()
            dismiss()
        } catch {
            deleteError = .deleteFailed(underlying: error)
            showDeleteError = true
        }
    }
}

#Preview {
    let tx = Transaction(amount: 24.99, title: "Lunch", isIncome: false)
    return TransactionDetailView(transaction: tx)
        .modelContainer(PreviewSampleData.container)
}
