import SwiftUI
import SwiftData
import LocalAuthentication

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirm = false
    @State private var showDeleteFinal = false
    @State private var showDeleteError = false

    var body: some View {
        NavigationStack {
            ZStack {
                FTColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: FTSpacing.xl) {
                        privacySection
                        displaySection
                        dataSection
                        categoriesSection
                        aboutSection
                    }
                    .padding(.horizontal, FTSpacing.lg)
                    .padding(.top, FTSpacing.lg)
                    .padding(.bottom, FTSpacing.xxxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.positive)
                }
            }
        }
        .alert("Delete All Data?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive) { showDeleteFinal = true }
        } message: {
            Text("This will permanently delete all transactions and budgets. Categories will be kept.")
        }
        .alert("Are you absolutely sure?", isPresented: $showDeleteFinal) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) { performDelete() }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Delete Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not delete data. Please try again.")
        }
    }

    // MARK: - Privacy

    private var privacySection: some View {
        section("PRIVACY") {
            if appState.canUseBiometrics {
                row {
                    Label(appState.biometricName, systemImage: biometricIcon)
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textPrimary)
                    Spacer()
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { appState.biometricEnabled },
                            set: { appState.biometricEnabled = $0 }
                        )
                    )
                    .tint(FTColors.positive)
                    .accessibilityLabel("Enable \(appState.biometricName)")
                }
            } else {
                row {
                    Label("Biometrics", systemImage: "lock.fill")
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textDisabled)
                    Spacer()
                    Text("Not available")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                }
            }
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        section("DISPLAY") {
            VStack(spacing: 0) {
                Text("Currency")
                    .font(FTTypo.body())
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(FTSpacing.md)
                Rectangle()
                    .fill(FTColors.border)
                    .frame(height: 0.5)
                HStack(spacing: FTSpacing.sm) {
                    ForEach(viewModel.currencies, id: \.code) { currency in
                        currencyChip(currency)
                    }
                }
                .padding(FTSpacing.md)
            }
            .background(FTColors.card)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        section("DATA") {
            VStack(spacing: FTSpacing.sm) {
                row {
                    Label("iCloud Sync", systemImage: "icloud")
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textPrimary)
                    Spacer()
                    Toggle("", isOn: $viewModel.iCloudSyncEnabled)
                        .tint(FTColors.positive)
                        .accessibilityLabel("Enable iCloud Sync")
                }

                if viewModel.iCloudSyncEnabled {
                    Text("Changes take effect after restarting the app.")
                        .font(FTTypo.caption())
                        .foregroundStyle(FTColors.textDisabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, FTSpacing.xs)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.iCloudSyncEnabled)

            ShareLink(item: csvFileURL, preview: SharePreview("FinTrackPro_Transactions.csv")) {
                actionRow(label: "Export Transactions", icon: "arrow.up.doc", color: FTColors.accent)
            }
            .buttonStyle(.plain)

            Button { showDeleteConfirm = true } label: {
                actionRow(label: "Delete All Data", icon: "trash", color: FTColors.negative)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        section("CATEGORIES") {
            NavigationLink {
                CategoryListView()
            } label: {
                actionRow(
                    label: "Manage Categories",
                    icon: "square.grid.2x2",
                    color: FTColors.positive,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        section("ABOUT") {
            row {
                Text("Version")
                    .font(FTTypo.body())
                    .foregroundStyle(FTColors.textPrimary)
                Spacer()
                Text(viewModel.appVersion)
                    .font(FTTypo.data())
                    .foregroundStyle(FTColors.textSecondary)
            }
            Link(destination: URL(string: "https://argudev.com")!) {
                actionRow(label: "ArguDev", icon: "globe", color: FTColors.accent, showChevron: true)
            }
            .buttonStyle(.plain)
            Link(destination: URL(string: "https://argudev.com/privacy")!) {
                actionRow(label: "Privacy Policy", icon: "hand.raised", color: FTColors.textSecondary, showChevron: true)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private var biometricIcon: String {
        switch appState.biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default:       return "lock.fill"
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        _ header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: FTSpacing.sm) {
            Text(header)
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, FTSpacing.xs)
            VStack(spacing: FTSpacing.sm) {
                content()
            }
        }
    }

    private func row<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack { content() }
            .padding(FTSpacing.md)
            .background(FTColors.card)
            .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
    }

    private func actionRow(
        label: String,
        icon: String,
        color: Color,
        showChevron: Bool = false
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(label)
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FTColors.textDisabled)
                    .accessibilityHidden(true)
            }
        }
        .padding(FTSpacing.md)
        .background(FTColors.card)
        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
    }

    private func currencyChip(_ currency: (code: String, label: String)) -> some View {
        let isSelected = appState.selectedCurrency == currency.code
        return Button {
            appState.selectedCurrency = currency.code
        } label: {
            Text(currency.code)
                .font(FTTypo.bodySemi())
                .foregroundStyle(isSelected ? FTColors.background : FTColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FTSpacing.sm)
                .background(isSelected ? FTColors.positive : FTColors.elevated)
                .clipShape(RoundedRectangle(cornerRadius: FTRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(currency.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var csvFileURL: URL {
        let csv = viewModel.exportCSV(transactions: transactions)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinTrackPro_Transactions.csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func performDelete() {
        do {
            try viewModel.deleteAllData(context: context)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            showDeleteError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .modelContainer(PreviewSampleData.container)
}
