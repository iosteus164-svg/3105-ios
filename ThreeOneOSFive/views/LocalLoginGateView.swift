import SwiftUI

struct LocalLoginGateView: View {
    private let fixedPassword = "TeusIOS@2026"

    @AppStorage("local.login.expiration") private var expirationTimestamp: Double = 0
    @State private var password = ""
    @State private var loginError = false
    @State private var approved = false
    @State private var openApp = false

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
                NetflixCoverView()
                    .transition(.opacity)
            } else if approved {
                approvedView
                    .transition(.opacity)
            } else {
                loginView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: approved)
        .animation(.easeInOut(duration: 0.25), value: openApp)
        .onAppear {
            if accessStillValid {
                approved = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    openApp = true
                }
            }
        }
    }

    private var loginView: some View {
        VStack {
            Spacer()

            VStack(spacing: 22) {
                Image("NetflixLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                Text("ACESSO")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("Digite sua senha para continuar")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))

                SecureField("Senha", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .foregroundStyle(.white)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(loginError ? Color.red : Color.white.opacity(0.08), lineWidth: 1)
                    )

                if loginError {
                    Text("Senha incorreta.")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    validateLogin()
                } label: {
                    Text("ENTRAR")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(28)
            .background(Color.white.opacity(0.055))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    private var approvedView: some View {
        VStack {
            Spacer()

            VStack(spacing: 26) {
                ProgressView()
                    .tint(.green)
                    .scaleEffect(1.35)

                Text("ACESSO APROVADO")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 3) {
                    Text("Expira em:")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.75))

                    Text(expirationDate.formatted(
                        .dateTime
                            .day(.twoDigits)
                            .month(.twoDigits)
                            .year()
                            .hour(.twoDigits(amPM: .omitted))
                            .minute(.twoDigits)
                    ))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                }

                Text("Iniciando aplicativo em instantes...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.28))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            .padding(.horizontal, 26)
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .padding(.horizontal, 28)

            Spacer()
        }
    }

    private func validateLogin() {
        guard password == fixedPassword else {
            loginError = true
            return
        }

        loginError = false

        // Acesso local válido por 24 horas.
        let expiration = Date().addingTimeInterval(24 * 60 * 60)
        expirationTimestamp = expiration.timeIntervalSince1970
        approved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            openApp = true
        }
    }
}
