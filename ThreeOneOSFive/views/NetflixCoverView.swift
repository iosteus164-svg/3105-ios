import SwiftUI

struct NetflixCoverView: View {
    @State private var tapCount = 0
    @State private var showInjector = false
    @State private var resetTask: Task<Void, Never>?
    @State private var selectedTab: FakeNetflixTab = .home

    @State private var isLoading = true
    @State private var selectedMovie: MovieCard?
    @State private var myList: Set<String> = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showInjector {
                ContentView()
                    .transition(.opacity)
            } else if isLoading {
                NetflixLoadingView()
                    .transition(.opacity)
            } else {
                netflixShell
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showInjector)
        .animation(.easeInOut(duration: 0.25), value: isLoading)
        .task {
            guard isLoading else { return }
            try? await Task.sleep(for: .milliseconds(3100))
            isLoading = false
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(
                movie: movie,
                isInList: myList.contains(movie.title),
                onToggleList: {
                    if myList.contains(movie.title) {
                        myList.remove(movie.title)
                    } else {
                        myList.insert(movie.title)
                    }
                }
            )
            .preferredColorScheme(.dark)
        }
    }

    private var netflixShell: some View {
        VStack(spacing: 0) {
            topBar

            Group {
                switch selectedTab {
                case .home:
                    homeContent
                case .trending:
                    trendingContent
                case .newAndHot:
                    newContent
                case .downloads:
                    downloadsContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomBar
        }
        .background(Color.black)
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

            Button(action: {}) {
                Image(systemName: "airplayvideo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Button(action: {}) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.black)
    }

    private var homeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                hero

                posterSection(
                    "Populares na Netflix",
                    [
                        MovieCard(title: "STRANGER\nTHINGS", subtitle: "Série", accent: .red, posterURL: "https://image.tmdb.org/t/p/w500/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg", description: "Mistério, aventura e acontecimentos sobrenaturais em uma pequena cidade."),
                        MovieCard(title: "WANDINHA", subtitle: "Série", accent: .purple, posterURL: "https://image.tmdb.org/t/p/w500/9PFonBhy4cQy7Jz20NpMygczOkv.jpg", description: "Uma estudante incomum investiga segredos e acontecimentos estranhos em sua escola."),
                        MovieCard(title: "LA CASA\nDE PAPEL", subtitle: "Série", accent: .red, posterURL: "https://image.tmdb.org/t/p/w500/reEMJA1uzscCbkpeRJeTT2bjqUp.jpg", description: "Um grupo executa um plano ambicioso enquanto enfrenta pressão dentro e fora do assalto."),
                        MovieCard(title: "OUTER\nBANKS", subtitle: "Série", accent: .orange, posterURL: "https://image.tmdb.org/t/p/w500/ovDgO2LPfwdVRfvScAqo9aMiIW.jpg", description: "Amigos partem em busca de respostas, pistas e um tesouro perdido.")
                    ]
                )

                posterSection(
                    "Continuar assistindo",
                    [
                        MovieCard(title: "BLACK\nMIRROR", subtitle: "Série", accent: .white, posterURL: "https://image.tmdb.org/t/p/w500/7PRddO7z7mcPi21nZTCMGShAyy1.jpg", description: "Histórias independentes exploram tecnologia e seus impactos sobre a sociedade."),
                        MovieCard(title: "LUPIN", subtitle: "Série", accent: .orange, posterURL: "https://image.tmdb.org/t/p/w500/sgxawbFB5Vi5OkPWQLNfl3dvkNJ.jpg", description: "Um ladrão elegante usa inteligência e disfarces para executar seus planos."),
                        MovieCard(title: "OZARK", subtitle: "Série", accent: .cyan, posterURL: "https://image.tmdb.org/t/p/w500/pCGyPVrI9Fzw6rE1Pvi4BIXF6ET.jpg", description: "Uma família tenta sobreviver em meio a negócios perigosos e alianças frágeis.")
                    ]
                )
            }
            .padding(.bottom, 24)
        }
    }

    private var trendingContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                pageHeader(
                    title: "Em alta",
                    subtitle: "Os títulos mais assistidos agora."
                )

                posterSection(
                    "Top 10 hoje",
                    [
                        MovieCard(title: "ARCANE", subtitle: "Top 1", accent: .pink, posterURL: "https://image.tmdb.org/t/p/w500/fqldf2t8ztc9aiwn3k6mlX3tvRT.jpg", description: "Duas irmãs são separadas por conflitos em uma cidade marcada por tecnologia e poder."),
                        MovieCard(title: "ELITE", subtitle: "Top 2", accent: .red, posterURL: "https://image.tmdb.org/t/p/w500/3NTAbAiao4JLzFQw6YxP1YZppM8.jpg", description: "Segredos, rivalidades e crimes cercam estudantes de uma escola exclusiva."),
                        MovieCard(title: "1899", subtitle: "Top 3", accent: .gray, posterURL: "https://image.tmdb.org/t/p/w500/gZleGu1MQVBArH2dlpZ9CGi0hhy.jpg", description: "Passageiros de um navio encontram mistérios que desafiam suas certezas."),
                        MovieCard(title: "DAHMER", subtitle: "Top 4", accent: .yellow, posterURL: "https://image.tmdb.org/t/p/w500/f2PVrphK0u81ES256lw3oAZuF3x.jpg", description: "Uma dramatização sombria inspirada em crimes reais.")
                    ]
                )

                posterSection(
                    "Filmes em alta",
                    [
                        MovieCard(title: "EXTRACTION", subtitle: "Filme", accent: .orange, posterURL: "https://image.tmdb.org/t/p/w500/nygOUcBKPHFTbxsYRFZVePqgPK6.jpg", description: "Um mercenário entra em uma missão perigosa para resgatar um alvo."),
                        MovieCard(title: "JOHN\nWICK 4", subtitle: "Filme", accent: .yellow, posterURL: "https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg", description: "Um assassino enfrenta novos adversários em sua busca por liberdade."),
                        MovieCard(title: "TOP GUN", subtitle: "Filme", accent: .white, posterURL: "https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg", description: "Pilotos de elite enfrentam desafios de treinamento e combate."),
                        MovieCard(title: "BATMAN", subtitle: "Filme", accent: .red, posterURL: "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg", description: "Um vigilante investiga uma série de crimes em uma cidade corrompida.")
                    ]
                )
            }
            .padding(.bottom, 24)
        }
    }

    private var newContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                pageHeader(
                    title: "Novidades",
                    subtitle: "Novos episódios, séries e filmes."
                )

                updateCard(
                    icon: "sparkles",
                    title: "Novos lançamentos",
                    message: "Conteúdo adicionado recentemente à plataforma."
                )

                updateCard(
                    icon: "bell.fill",
                    title: "Em breve",
                    message: "Ative o lembrete para não perder os próximos lançamentos."
                )

                posterSection(
                    "Lançados recentemente",
                    [
                        MovieCard(title: "MANIFEST", subtitle: "Novo", accent: .blue, posterURL: "https://image.tmdb.org/t/p/w500/eTemCphrglLKrXOsNRhYezHA7H9.jpg", description: "Passageiros de um voo retornam e descobrem que o mundo mudou."),
                        MovieCard(title: "WANDINHA", subtitle: "Novo", accent: .purple, posterURL: "https://image.tmdb.org/t/p/w500/9PFonBhy4cQy7Jz20NpMygczOkv.jpg", description: "Mistério e humor sombrio em uma escola cheia de segredos."),
                        MovieCard(title: "ARCANE", subtitle: "Novo", accent: .pink, posterURL: "https://image.tmdb.org/t/p/w500/fqldf2t8ztc9aiwn3k6mlX3tvRT.jpg", description: "Uma história de irmandade e rivalidade em uma cidade dividida.")
                    ]
                )
            }
            .padding(.bottom, 24)
        }
    }

    private var downloadsContent: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 110, height: 110)

                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.88))
            }

            Text("Seus downloads")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Filmes e séries baixados aparecem aqui para assistir offline.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)

            Button {
                selectedTab = .home
            } label: {
                Text("Encontrar títulos")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            Spacer()
        }
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

    private func pageHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    private func updateCard(icon: String, title: String, message: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.red)
                .frame(width: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 18)
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
                        Button {
                            selectedMovie = item
                        } label: {
                            fakePoster(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private func fakePoster(_ item: MovieCard) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: item.posterURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    LinearGradient(
                        colors: [item.accent.opacity(0.45), .black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .empty:
                    ZStack {
                        Color.black
                        ProgressView()
                            .tint(.red)
                    }
                @unknown default:
                    Color.black
                }
            }
            .frame(width: 116, height: 165)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.78)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title.replacingOccurrences(of: "\n", with: " "))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(8)
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
            fakeTab(.home, "house.fill", "Início")
            fakeTab(.trending, "play.rectangle.on.rectangle", "Em alta")
            fakeTab(.newAndHot, "rectangle.stack.fill", "Novidades")
            fakeTab(.downloads, "arrow.down.circle.fill", "Downloads")
        }
        .padding(.vertical, 9)
        .background(Color.black.opacity(0.98))
    }

    private func fakeTab(_ tab: FakeNetflixTab, _ icon: String, _ title: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17))

                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(selectedTab == tab ? Color.red : Color.white.opacity(0.55))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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

private struct NetflixLoadingView: View {
    @State private var stage = 0
    @State private var showSpinner = false

    private let stages = [
        "N",
        "N",
        "NE",
        "NET",
        "NETF",
        "NETFL",
        "NETFLI",
        "NETFLIX"
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 34) {
                Spacer()

                Text(stages[min(stage, stages.count - 1)])
                    .font(.system(size: 42, weight: .black, design: .default))
                    .foregroundStyle(Color(red: 0.90, green: 0.00, blue: 0.05))
                    .kerning(stage >= 2 ? 1.8 : 0)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.12), value: stage)

                if showSpinner {
                    ProgressView()
                        .tint(.white.opacity(0.75))
                        .scaleEffect(1.0)
                        .transition(.opacity)
                } else {
                    Color.clear
                        .frame(width: 24, height: 24)
                }

                Spacer()
            }
        }
        .task {
            for next in 1..<stages.count {
                try? await Task.sleep(for: .milliseconds(next < 2 ? 320 : 180))
                stage = next
            }

            try? await Task.sleep(for: .milliseconds(260))
            withAnimation(.easeIn(duration: 0.20)) {
                showSpinner = true
            }
        }
    }
}

private struct MovieDetailView: View {
    let movie: MovieCard
    let isInList: Bool
    let onToggleList: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AsyncImage(url: URL(string: movie.posterURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Rectangle()
                                .fill(movie.accent.opacity(0.25))
                        case .empty:
                            ZStack {
                                Rectangle().fill(Color.black)
                                ProgressView().tint(.red)
                            }
                        @unknown default:
                            Color.black
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 330)
                    .clipped()
                    .background(Color.black)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(movie.title.replacingOccurrences(of: "\n", with: " "))
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text(movie.subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)

                        Text(movie.description)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.78))

                        Button(action: {}) {
                            Label("Assistir", systemImage: "play.fill")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }

                        Button(action: onToggleList) {
                            Label(
                                isInList ? "Remover da minha lista" : "Adicionar à minha lista",
                                systemImage: isInList ? "checkmark" : "plus"
                            )
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

private enum FakeNetflixTab {
    case home
    case trending
    case newAndHot
    case downloads
}

private struct MovieCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let accent: Color
    let posterURL: String
    let description: String
}
