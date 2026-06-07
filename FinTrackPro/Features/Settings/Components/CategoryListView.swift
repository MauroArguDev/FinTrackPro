import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var categoryToEdit: Category?
    @State private var categoryToDelete: Category?
    @State private var showAddCategory = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            FTColors.background.ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: FTSpacing.md) {
                    ForEach(categories) { category in
                        categoryCell(category)
                    }
                    addCell
                }
                .padding(FTSpacing.lg)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddCategory = true } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(FTColors.positive)
                }
                .accessibilityLabel("Add category")
            }
        }
        .sheet(item: $categoryToEdit) { category in
            EditCategoryView(category: category)
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
        .alert("Delete Category?", isPresented: Binding(
            get: { categoryToDelete != nil },
            set: { if !$0 { categoryToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { categoryToDelete = nil }
            Button("Delete", role: .destructive) { confirmDelete() }
        } message: {
            Text("Transactions linked to this category will lose their category assignment.")
        }
    }

    private func categoryCell(_ category: Category) -> some View {
        let color = Color(hexString: category.colorHex) ?? FTColors.accent
        return Button { categoryToEdit = category } label: {
            VStack(spacing: FTSpacing.sm) {
                Text(category.emoji)
                    .font(.system(size: 28))
                    .frame(width: 56, height: 56)
                    .background(color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
                Text(category.name)
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(FTSpacing.md)
            .background(FTColors.card)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                categoryToDelete = category
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityLabel("\(category.name), \(category.emoji)")
        .accessibilityHint("Tap to edit, hold for options")
    }

    private var addCell: some View {
        Button { showAddCategory = true } label: {
            VStack(spacing: FTSpacing.sm) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(FTColors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(FTColors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
                Text("New")
                    .font(FTTypo.caption())
                    .foregroundStyle(FTColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(FTSpacing.md)
            .background(FTColors.card)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add new category")
    }

    private func confirmDelete() {
        guard let cat = categoryToDelete else { return }
        context.delete(cat)
        try? context.save()
        categoryToDelete = nil
    }
}
