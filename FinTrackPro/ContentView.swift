import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            FTColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: FTSpacing.xl) {
                    Group {
                        Text("Syne — Display")
                            .font(FTTypo.h2())
                            .foregroundStyle(FTColors.textSecondary)
                        Text("Hero 40px Heavy")
                            .font(FTTypo.hero())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("H1 32px Bold")
                            .font(FTTypo.h1())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("H2 22px SemiBold")
                            .font(FTTypo.h2())
                            .foregroundStyle(FTColors.textPrimary)
                    }

                    Divider().overlay(FTColors.border)

                    Group {
                        Text("Plus Jakarta Sans — Body")
                            .font(FTTypo.h2())
                            .foregroundStyle(FTColors.textSecondary)
                        Text("Body 15px Regular")
                            .font(FTTypo.body())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("Body Semi 15px SemiBold")
                            .font(FTTypo.bodySemi())
                            .foregroundStyle(FTColors.textPrimary)
                        Text("Caption 12px Medium")
                            .font(FTTypo.caption())
                            .foregroundStyle(FTColors.textPrimary)
                    }

                    Divider().overlay(FTColors.border)

                    Group {
                        Text("Fira Code — Data")
                            .font(FTTypo.h2())
                            .foregroundStyle(FTColors.textSecondary)
                        Text("+$12,840.50")
                            .font(FTTypo.amountLg())
                            .foregroundStyle(FTColors.positive)
                        Text("-$1,240.00")
                            .font(FTTypo.amount())
                            .foregroundStyle(FTColors.negative)
                        Text("76.4% used · 2026-05-26")
                            .font(FTTypo.data())
                            .foregroundStyle(FTColors.warning)
                        Text("LABEL 10px")
                            .font(FTTypo.label())
                            .foregroundStyle(FTColors.textDisabled)
                    }
                }
                .padding(FTSpacing.xl)
            }
        }
    }
}

#Preview {
    ContentView()
}
