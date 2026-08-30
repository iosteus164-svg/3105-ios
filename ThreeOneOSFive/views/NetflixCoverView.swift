import SwiftUI

struct NetflixCoverView: View {
    @State private var tapCount = 0
    @State private var showInjector = false
    @State private var resetTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showInjector {
                ContentView()
                    .transition(.opacity)
            } else {
                coverContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showInjector)
    }

    private var coverContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    registerLogoTap()
                } label: {
                    Image("NetflixLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)

                Image(systemName: "person.crop.circle")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.leading, 14)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero

                    sectionTitle("Em alta")
                    posterRow([
                        ("N", "Série Original"),
                        ("TOP 10", "Em alta hoje"),
                        ("NOVO", "Lançamento")
                    ])

                    sectionTitle("Continuar assistindo")
                    posterRow([
                        ("▶", "Continuar"),
                        ("+", "Minha lista"),
                        ("★", "Recomendado")
                    ])
                }
                .padding(.bottom, 24)
            }

            HStack {
                fakeTab("house.fill", "Início", true)
                fakeTab("play.rectangle.on.rectangle", "Em alta", false)
                fakeTab("rectangle.stack.fill", "Novidades", false)
                fakeTab("arrow.down.circle.fill", "Downloads", false)
            }
            .padding(.vertical, 9)
            .background(Color.black.opacity(0.98))
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.black, .red.opacity(0.38), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 390)

            VStack(alignment: .leading, spacing: 12) {
                Text("NETFLIX")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.red)

                Text("Série em destaque")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)

                Text("Drama  •  Ação  •  Suspense")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))

                HStack(spacing: 12) {
                    Button(action: {}) {
                        Label("Assistir", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 11)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    Button(action: {}) {
                        Label("Minha lista", systemImage: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 11)
                            .background(Color.white.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(20)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
    }

    private func posterRow(_ items: [(String, String)]) -> some View {
        HStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.red.opacity(0.28), .black],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(item.0)
                            .font(.system(size: 25, weight: .black))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(8)
                    }
                    .frame(width: 112, height: 155)

                    Text(item.1)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                        .frame(width: 112)
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private func fakeTab(_ icon: String, _ title: String, _ selected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 17))
            Text(title)
                .font(.caption2)
        }
        .foregroundStyle(selected ? Color.red : Color.white.opacity(0.55))
        .frame(maxWidth: .infinity)
    }

    private func registerLogoTap() {
        tapCount += 1

        resetTask?.cancel()
        resetTask = Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                await MainActor.run {
                    tapCount = 0
                }
            }
        }

        if tapCount >= 3 {
            resetTask?.cancel()
            tapCount = 0
            showInjector = true
        }
    }
}
