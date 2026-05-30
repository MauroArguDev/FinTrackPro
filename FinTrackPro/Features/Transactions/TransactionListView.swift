import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var viewModel = TransactionListViewModel()
    @State private var pendingDelete: Transaction?
    @State private var showDeleteAlert = false
    @State private var deleteError: FinTrackError?
    @State private var showDeleteError = false

    var body: some View {
        NavigationStack {
            content
                .background(FTColors.background)
                .navigationTitle("Transactions")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, prompt: "Search transactions")
                .alert("Delete Transaction?", isPresented: $showDeleteAlert, presenting: pendingDelete) { tx in
                    Button("Delete", role: .destructive) { delete(tx) }
                    Button("Cancel", role: .cancel) { pendingDelete = nil }
                } message: { tx in
                    Text("\"\(tx.title)\" will be permanently removed.")
                }
                .alert("Error", isPresented: $showDeleteError, presenting: deleteError) { _ in
                    Button("OK", role: .cancel) {}
                } message: { err in
                    Text(err.errorDescription ?? "Something went wrong.")
                }
        }
        .onChange(of: transactions, initial: true) { _, updated in
            viewModel.update(with: updated)
        }
    }

    @ViewBuilder
    private var content: some View {
        if transactions.isEmpty {
            emptyState(icon: "tray", message: "No transactions yet")
        } else {
            VStack(spacing: 0) {
                TransactionFilterBar(selectedFilter: $viewModel.selectedFilter)
                    .background(FTColors.surface)

                if viewModel.isEmpty {
                    emptyState(icon: "magnifyingglass", message: "No results")
                        .frame(maxHeight: .infinity)
                } else {
                    transactionList
                }
            }
        }
    }

    private var transactionList: some View {
        List {
            ForEach(viewModel.groupedTransactions, id: \.key) { group in
                Section {
                    ForEach(group.transactions, id: \.id) { tx in
                        TransactionRowView(transaction: tx)
                            .listRowBackground(FTColors.card)
                            .listRowSeparatorTint(FTColors.border)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    pendingDelete = tx
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(FTColors.negative)
                            }
                    }
                } header: {
                    Text(group.key)
                        .font(FTTypo.data())
                        .foregroundStyle(FTColors.textSecondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: FTSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(FTColors.textDisabled)
                .accessibilityHidden(true)
            Text(message)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textDisabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func delete(_ transaction: Transaction) {
        do {
            try viewModel.delete(transaction, context: context)
        } catch let err as FinTrackError {
            deleteError = err
            showDeleteError = true
        } catch {
            deleteError = .deleteFailed(underlying: error)
            showDeleteError = true
        }
        pendingDelete = nil
    }
}

#Preview {
    TransactionListView()
        .modelContainer(PreviewSampleData.container)
}
