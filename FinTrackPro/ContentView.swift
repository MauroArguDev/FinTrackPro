import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FTSpacing.xxl) {
                    typographySection
                    amountSection
                    pillSection
                    iconSection
                    cardSection
                    buttonSection
                }
                .padding(FTSpacing.lg)
                .padding(.bottom, FTSpacing.xxxl)
            }
            .background(FTColors.background)
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FTColors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("TYPOGRAPHY")
            Text("Hero 40px Heavy")
                .font(FTTypo.hero())
                .foregroundStyle(FTColors.textPrimary)
            Text("H1 32px Bold — Syne")
                .font(FTTypo.h1())
                .foregroundStyle(FTColors.textPrimary)
            Text("H2 22px SemiBold — Syne")
                .font(FTTypo.h2())
                .foregroundStyle(FTColors.textPrimary)
            Text("Body 15px Regular — Plus Jakarta Sans")
                .font(FTTypo.body())
                .foregroundStyle(FTColors.textPrimary)
            Text("Caption 12px Medium — Plus Jakarta Sans")
                .font(FTTypo.caption())
                .foregroundStyle(FTColors.textSecondary)
            Text("+$12,840.50  data  label")
                .font(FTTypo.data())
                .foregroundStyle(FTColors.textDisabled)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("AMOUNT TEXT")
            AmountText(amount: 12840.50, font: FTTypo.amountLg())
            AmountText(amount: -1240.00, font: FTTypo.amount())
            AmountText(amount: 320.75)
            AmountText(amount: -49.99)
            AmountText(amount: 0)
        }
    }

    private var pillSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("PILL BADGE")
            HStack(spacing: FTSpacing.sm) {
                PillBadge(label: "Income", color: FTColors.positive)
                PillBadge(label: "Expense", color: FTColors.negative)
                PillBadge(label: "Warning", color: FTColors.warning)
                PillBadge(label: "Neutral", color: FTColors.accent)
            }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("CATEGORY ICON")
            HStack(spacing: FTSpacing.md) {
                CategoryIcon(emoji: "🍔", color: FTColors.positive)
                CategoryIcon(emoji: "🚗", color: FTColors.accent)
                CategoryIcon(emoji: "💊", color: FTColors.negative)
                CategoryIcon(emoji: "🛍️", color: FTColors.warning)
                CategoryIcon(emoji: "💼", color: FTColors.positive)
                CategoryIcon(emoji: "🏠", color: FTColors.accent)
                CategoryIcon(emoji: "📚", color: FTColors.accent)
            }
        }
    }

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("CARD MODIFIER")
            VStack(alignment: .leading, spacing: FTSpacing.md) {
                HStack {
                    CategoryIcon(emoji: "💼", color: FTColors.positive)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Salary")
                            .font(FTTypo.bodySemi())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("May 26 · 09:00")
                            .font(FTTypo.data())
                            .foregroundStyle(FTColors.textDisabled)
                    }
                    Spacer()
                    AmountText(amount: 5000)
                }
                Rectangle()
                    .fill(FTColors.border)
                    .frame(height: 0.5)
                    .accessibilityHidden(true)
                HStack {
                    CategoryIcon(emoji: "🍔", color: FTColors.negative)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Food")
                            .font(FTTypo.bodySemi())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("May 26 · 13:45")
                            .font(FTTypo.data())
                            .foregroundStyle(FTColors.textDisabled)
                    }
                    Spacer()
                    AmountText(amount: -24.50)
                }
            }
            .padding(FTSpacing.lg)
            .ftCard()
        }
    }

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: FTSpacing.sm) {
            sectionHeader("PRIMARY BUTTON")
            Button("Save Transaction") {}
                .buttonStyle(PrimaryButtonStyle())
            Button("Disabled State") {}
                .buttonStyle(PrimaryButtonStyle())
                .disabled(true)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FTTypo.label())
            .foregroundStyle(FTColors.textDisabled)
            .padding(.bottom, FTSpacing.xs)
    }
}

#Preview {
    ContentView()
}
