import SwiftUI

struct LocalLoginGateView: View {
    @AppStorage("api.login.expiration") private var expirationTimestamp: Double = 0
    @State private var key = ""
    @State private var isLoading = false
    @State private var openApp = false
    @State private var accessStatus: AccessStatus?
    @State private var statusMessage = ""
    @State private var statusReason: String?

    private var expirationDate: Date {
        Date(timeIntervalSince1970: expirationTimestamp)
    }

    private var accessStillValid: Bool {
        expirationTimestamp > Date().timeIntervalSince1970
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if openApp {
                NetflixCoverView().transition(.opacity)
            } else if let accessStatus {
                AccessStatusView(
                    status: accessStatus,
                    expirationDate: expirationTimestamp > 0 ? expirationDate : nil,
                    message: statusMessage,
                    reason: statusReason,
                    onContinue: { if accessStatus == .approved { openApp = true } },
                    onRetry: {
                        self.accessStatus = nil
                        self.statusMessage = ""
                        self.statusReason = nil
                    }
                )
                .transition(.opacity)
            } else {
                loginView.transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: openApp)
        .animation(.easeInOut(duration: 0.25), value: accessStatus)
        .onAppear {
            if accessStillValid {
                accessStatus = .approved
                statusMessage = "Acesso ainda válido neste dispositivo."
            } else if expirationTimestamp > 0 {
                accessStatus = .denied
                statusMessage = "Seu acesso expirou."
                statusReason = "expired"
            }
        }
    }

    private var loginView: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 72)

                Image("NetflixWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 330)
                    .padding(.horizontal, 32)

                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.035))
                            .frame(width: 74, height: 74)
                            .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))

                        Image(systemName: "key.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 8) {
                        Text("ACESSO POR KEY")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Digite sua key para validar o acesso")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "key")
                            .foregroundStyle(.white.opacity(0.45))
                        TextField("TEUS-XXXX-XXXX-XXXX", text: $key)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.035))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10), lineWidth: 1))

                    Button {
                        Task { await validateKey() }
                    } label: {
                        HStack(spacing: 10) {
                            if isLoading { ProgressView().tint(.white) }
                            Text(isLoading ? "VALIDANDO..." : "VALIDAR KEY")
                                .font(.system(size: 19, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isLoading || key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    HStack(spacing: 14) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 28))
                            .foregroundStyle(.red)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Validação online")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("A key é validada pela API e vinculada a este dispositivo.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.025))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.035, green: 0.035, blue: 0.045)))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.07), lineWidth: 1))
                .padding(.horizontal, 24)

                Spacer(minLength: 60)
            }
        }
        .background(Color.black)
    }

    @MainActor
    private func validateKey() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await KeyAPIClient.shared.validate(
                key: key,
                deviceID: LocalDeviceIdentity.current()
            )

            statusMessage = response.message
            statusReason = response.reason

            if response.success, response.status == "approved" {
                if let expiresAt = response.expiresAt {
                    expirationTimestamp = expiresAt.timeIntervalSince1970
                }
                accessStatus = .approved
            } else {
                if let expiresAt = response.expiresAt {
                    expirationTimestamp = expiresAt.timeIntervalSince1970
                }
                accessStatus = .denied
            }
        } catch {
            statusMessage = error.localizedDescription
            statusReason = "network_error"
            accessStatus = .denied
        }
    }
}

private enum AccessStatus: Equatable {
    case approved
    case denied
}

private struct AccessStatusView: View {
    let status: AccessStatus
    let expirationDate: Date?
    let message: String
    let reason: String?
    let onContinue: () -> Void
    let onRetry: () -> Void

    private var isApproved: Bool { status == .approved }

    private var reasonText: String {
        switch reason {
        case "expired": return "KEY EXPIRADA"
        case "invalid_key": return "KEY INVÁLIDA"
        case "device_limit": return "LIMITE DE DISPOSITIVOS"
        case "revoked": return "KEY REVOGADA"
        case "network_error": return "ERRO DE CONEXÃO"
        default: return isApproved ? "APROVADO" : "NEGADO"
        }
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: isApproved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(isApproved ? .green : .red)

                Text(isApproved ? "ACESSO APROVADO" : "ACESSO NEGADO")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text(reasonText)
                    .font(.headline.bold())
                    .foregroundStyle(isApproved ? .green : .red)

                if let expirationDate {
                    Text("Expira em:")
                        .foregroundStyle(.white.opacity(0.45))
                    Text(expirationDate.formatted(
                        .dateTime.day(.twoDigits).month(.twoDigits).year()
                            .hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
                    ))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.46))
                    .multilineTextAlignment(.center)

                Button(action: isApproved ? onContinue : onRetry) {
                    Text(isApproved ? "CONTINUAR" : "TENTAR NOVAMENTE")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isApproved ? Color.green.opacity(0.85) : Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
            }
            .padding(28)
            .background(Color(red: 0.06, green: 0.06, blue: 0.075))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal, 28)
            Spacer()
        }
        .background(Color.black)
    }
}
