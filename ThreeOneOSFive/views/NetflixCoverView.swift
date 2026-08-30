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
                netflixHome
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showInjector)
    }

    private var netflixHome: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    hero

                    posterSection(
                        "Populares na Netflix",
                        [
                            MovieCard(title: "STRANGER\nTHINGS", subtitle: "Série", accent: .red),
                            MovieCard(title: "WANDINHA", subtitle: "Série", accent: .purple),
                            MovieCard(title: "LA CASA\nDE PAPEL", subtitle: "Série", accent: .red),
                            MovieCard(title: "OUTER\nBANKS", subtitle: "Série", accent: .orange)
                        ]
                    )

                    posterSection(
                        "Em alta",
                        [
                            MovieCard(title: "BLACK\nMIRROR", subtitle: "Série", accent: .white),
                            MovieCard(title: "LUPIN", subtitle: "Série", accent: .orange),
                            MovieCard(title: "OZARK", subtitle: "Série", accent: .cyan),
                            MovieCard(title: "ELITE", subtitle: "Série", accent: .red)
                        ]
                    )

                    posterSection(
                        "Somente na Netflix",
                        [
                            MovieCard(title: "ARCANE", subtitle: "Série", accent: .pink),
                            MovieCard(title: "1899", subtitle: "Série", accent: .gray),
                            MovieCard(title: "DAHMER", subtitle: "Série", accent: .yellow),
                            MovieCard(title: "MANIFEST", subtitle: "Série", accent: .blue)
                        ]
                    )

                    posterSection(
                        "Filmes",
                        [
                            MovieCard(title: "EXTRACTION", subtitle: "Filme", accent: .orange),
                            MovieCard(title: "JOHN\nWICK 4", subtitle: "Filme", accent: .yellow),
                            MovieCard(title: "TOP GUN", subtitle: "Filme", accent: .white),
                            MovieCard(title: "BATMAN", subtitle: "Filme", accent: .red)
                        ]
                    )
                }
                .padding(.bottom, 24)
            }

            bottomBar
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                registerLogoTap()
            } label: {
                Image("NetflixLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)

            Spacer()

            Image(systemName: "airplayvideo")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(.red)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.black)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    .black,
                    Color(red: 0.10, green: 0.10, blue: 0.13),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 380)

            VStack(alignment: .leading, spacing: 10) {
                Text("N  SÉRIE")
                    .font(.caption.bold())
                    .foregroundStyle(.red)

                Text("THE WITCHER")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.white)

                Text("Destino é uma fera. Você é o que faz dele.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 10) {
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
                            .background(Color.white.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(18)
        }
    }

    private func posterSection(_ title: String, _ items: [MovieCard]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        fakePoster(item)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private func fakePoster(_ item: MovieCard) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    item.accent.opacity(0.45),
                    Color.black.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("N")
                    .font(.caption.bold())
                    .foregroundStyle(.red)

                Spacer()

                Text(item.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.75)

                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(10)
        }
        .frame(width: 116, height: 165)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var bottomBar: some View {
        HStack {
            fakeTab("house.fill", "Início", true)
            fakeTab("play.rectangle.on.rectangle", "Em alta", false)
            fakeTab("rectangle.stack.fill", "Novidades", false)
            fakeTab("arrow.down.circle.fill", "Downloads", false)
        }
        .padding(.vertical, 9)
        .background(Color.black.opacity(0.98))
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

private struct MovieCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let accent: Color
}
