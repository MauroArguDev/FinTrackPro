import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase

    private let service: any BiometricServiceProtocol
    @State private var isAuthenticating = false
    @State private var authError: FinTrackError?

    init(service: any BiometricServiceProtocol = BiometricService()) {
        self.service = service
    }

    private var biometricSystemImage: String {
        switch appState.biometryType {
        case .none:    return "lock.fill"
        case .touchID: return "touchid"
        case .faceID:  return "faceid"
        case .opticID: return "opticid"
        @unknown default: return "lock.fill"
        }
    }

    var body: some View {
        ZStack {
            FTColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: FTSpacing.lg) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64, weight: .medium))
                        .foregroundStyle(FTColors.positive)
                        .accessibilityHidden(true)

                    Text("FinTrack Pro")
                        .font(FTTypo.h1())
                        .foregroundStyle(FTColors.textPrimary)

                    Text("Your financial data is protected.")
                        .font(FTTypo.body())
                        .foregroundStyle(FTColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, FTSpacing.xl)
                }

                Spacer()

                VStack(spacing: FTSpacing.md) {
                    if let description = authError?.errorDescription {
                        Text(description)
                            .font(FTTypo.caption())
                            .foregroundStyle(FTColors.negative)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, FTSpacing.xl)
                    }

                    Button(action: triggerAuth) {
                        HStack(spacing: FTSpacing.sm) {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(FTColors.background)
                                    .controlSize(.small)
                            } else {
                                Image(systemName: biometricSystemImage)
                                    .accessibilityHidden(true)
                            }
                            Text(
                                isAuthenticating
                                    ? "Authenticating…"
                                    : "Unlock with \(appState.biometricName)"
                            )
                        }
                        .font(FTTypo.bodySemi())
                        .foregroundStyle(FTColors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            isAuthenticating
                                ? FTColors.positive.opacity(0.6)
                                : FTColors.positive
                        )
                        .clipShape(RoundedRectangle(cornerRadius: FTRadius.lg))
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, FTSpacing.xl)
                    .accessibilityLabel(
                        isAuthenticating ? "Authenticating" : "Unlock with \(appState.biometricName)"
                    )
                }
                .padding(.bottom, FTSpacing.xxxl)
            }
        }
        .onAppear {
            if scenePhase == .active {
                triggerAuth()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                triggerAuth()
            }
        }
    }

    private func triggerAuth() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil

        Task {
            do {
                try await service.authenticate()
                appState.unlock()
            } catch FinTrackError.biometricNotAvailable {
                appState.unlock()
            } catch FinTrackError.biometricCancelled {
                authError = nil
            } catch let error as FinTrackError {
                authError = error
            } catch {
                authError = .biometricFailed
            }
            isAuthenticating = false
        }
    }
}

#Preview {
    LockScreenView()
        .environment(AppState())
}
