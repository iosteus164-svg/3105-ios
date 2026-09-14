import SwiftUI

struct ContentView: View {
    let onReturnToNetflix: (() -> Void)?
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var repositoryStore: PackageRepositoryStore
    @State private var showSettings = false
    @State private var showLogs = false

    init(onReturnToNetflix: (() -> Void)? = nil) {
        self.onReturnToNetflix = onReturnToNetflix
    }

    var body: some View {
        PatchProjectsView(
            onOpenSettings: { showSettings = true },
            onOpenLogs: { showLogs = true }
        )
        .tint(AppTheme.accent)
        .preferredColorScheme(.dark)
        .simultaneousGesture(
            TapGesture(count: 3)
                .onEnded { onReturnToNetflix?() }
        )
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLogs) { LogView() }
        .patchStorePresentation(patchStore)
        .repositoryStorePresentation(repositoryStore, patchStore: patchStore)
    }
}
