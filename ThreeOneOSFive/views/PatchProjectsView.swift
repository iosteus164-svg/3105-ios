import SwiftUI
import AVFoundation
import UIKit
import UniformTypeIdentifiers

private enum PatchPackagePickerPolicy {
    static let packageType = UTType(filenameExtension: "3105") ?? .data
    static let allowedContentTypes: [UTType] = [packageType, .data]
    static let copiesSelectedDocument = true
}

struct PatchProjectsView: View {
    @State private var patchCategory = 0
    @EnvironmentObject private var appState: AppState
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var draftCoordinator: PatchDraftCoordinator
    @StateObject private var store = PatchProjectStore()
    @State private var showCreate = false
    @State private var showImporter = false
    @State private var searchText = ""
    @AppStorage("selectedFreeFireVariant") private var selectedGameRaw = "normal"

    private var filteredItems: [PatchLibraryItem] {
        let categoryItems = store.items.filter { item in
            guard let project = item.project else { return false }

            let isApostadoFile =
                project.name.localizedCaseInsensitiveContains("cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs")
                || project.directories.contains {
                    $0.relativePath.localizedCaseInsensitiveContains("cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs")
                }
                || project.rules.contains {
                    $0.relativePath.localizedCaseInsensitiveContains("cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs")
                        || $0.replacementFilename.localizedCaseInsensitiveContains("cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs")
                }

            return patchCategory == 1 ? isApostadoFile : !isApostadoFile
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categoryItems }

        return categoryItems.filter { item in
            if item.packageURL.lastPathComponent.localizedCaseInsensitiveContains(query) {
                return true
            }
            guard let project = item.project else { return false }
            return project.name.localizedCaseInsensitiveContains(query)
                || project.allBundleIdentifiers.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }
                || project.directories.contains {
                    $0.relativePath.localizedCaseInsensitiveContains(query)
                }
                || project.rules.contains {
                    $0.relativePath.localizedCaseInsensitiveContains(query)
                        || $0.replacementFilename.localizedCaseInsensitiveContains(query)
                }
        }
    }

    init() {
#if targetEnvironment(simulator)
        _showCreate = State(
            initialValue: ProcessInfo.processInfo.arguments.contains("--simulate-patch-editor")
        )
#endif
    }


    private enum FreeFireVariant: String {
        case normal
        case max
    }

    private var selectedGame: FreeFireVariant {
        get { FreeFireVariant(rawValue: selectedGameRaw) ?? .normal }
        nonmutating set { selectedGameRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("ExternalBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.88)

                Color.black.opacity(0.20)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "skull")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("EXTERNAL")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.82)

                                Text("A I M B O T")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.62))
                            }
                        }
                        .foregroundStyle(AppTheme.accent)

                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "skull")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                            Text("© Teus ios")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 15)
                        .frame(height: 54)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 1)

                    Text("SELECIONE O JOGO")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.accent)

                    HStack(spacing: 12) {
                        gameChoiceCard(
                            title: "FREE FIRE",
                            bundle: "com.dts.freefireth",
                            imageName: "FreeFireNormalIcon",
                            selected: selectedGame == .normal
                        ) { selectedGame = .normal }

                        gameChoiceCard(
                            title: "FREE FIRE MAX",
                            bundle: "com.dts.freefiremax",
                            imageName: "FreeFireMaxIcon",
                            selected: selectedGame == .max
                        ) { selectedGame = .max }
                    }

                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 0)

                VStack(spacing: 10) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.accent)

                            Text("iOS \(AppInfo.osVersion)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 7) {
                            Circle()
                                .fill(appState.isSupported ? Color.green : AppTheme.accent)
                                .frame(width: 9, height: 9)

                            Text(appState.isSupported ? "SUPORTADO" : "NÃO SUPORTADO")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(appState.isSupported ? Color.green : AppTheme.accent)
                        }
                    }

                    Text(
                        appState.isSupported
                        ? "Esta versão do iOS é suportada."
                        : "Esta versão do iOS não é suportada."
                    )
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 8)

                HStack(spacing: 8) {
                    Button {
                        patchCategory = 0
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "skull")
                                .symbolRenderingMode(.monochrome)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(patchCategory == 0 ? AppTheme.accent : Color.white)
                                .frame(width: 30, height: 30)
                            Text("Aimbot")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                            .foregroundStyle(patchCategory == 0 ? AppTheme.accent : Color.white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(patchCategory == 0 ? AppTheme.accent.opacity(0.20) : Color.black.opacity(0.58))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(patchCategory == 0 ? AppTheme.accent : Color.white.opacity(0.14), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        patchCategory = 1
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Apostado")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                            .foregroundStyle(patchCategory == 1 ? AppTheme.accent : Color.white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(patchCategory == 1 ? AppTheme.accent.opacity(0.20) : Color.black.opacity(0.58))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(patchCategory == 1 ? AppTheme.accent : Color.white.opacity(0.14), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 8)

                List {
                    if store.items.isEmpty && !store.isBusy {
                        emptyState
                            .listRowSeparator(.hidden)
                    } else if filteredItems.isEmpty && !store.isBusy {
                        searchEmptyState
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(filteredItems) { item in
                            itemRow(item)
                        }
                        .onDelete { offsets in
                            offsets.map { filteredItems[$0] }.forEach(store.delete)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .safeAreaInset(edge: .bottom) {
                    attentionCard
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                        .padding(.bottom, 5)
                        .background(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .background(Color.clear)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)

            .sheet(isPresented: $showImporter) {
                FileDocumentPicker(
                    allowedContentTypes: PatchPackagePickerPolicy.allowedContentTypes,
                    copiesSelectedDocument: PatchPackagePickerPolicy.copiesSelectedDocument,
                    allowsMultipleSelection: false,
                    onSelection: { result in
                        showImporter = false
                        if case .success(let urls) = result, let url = urls.first {
                            store.importPackage(at: url)
                        }
                    },
                    onCancel: {
                        showImporter = false
                    }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showCreate) {
                PatchProjectEditorView(
                    existingProject: nil,
                    passwordIsProtected: false
                ) { project, password in
                    store.create(project: project, password: password)
                }
            }
            .sheet(item: $draftCoordinator.request) { request in
                PatchProjectEditorView(
                    existingProject: nil,
                    passwordIsProtected: false,
                    initialDraft: request.draft
                ) { project, password in
                    store.create(project: project, password: password)
                    draftCoordinator.clear()
                }
            }
            .sheet(item: $store.passwordRequest, onDismiss: store.cancelUnlock) { _ in
                PatchUnlockView(store: store)
            }
            .alert(item: $store.alert) { alert in
                Alert(
                    title: Text(language.text(alert.titleKey)),
                    message: Text(alert.message(language: language)),
                    dismissButton: .default(Text(language.text("common.ok")))
                )
            }
            .onAppear(perform: consumeExternalImport)
            .onChange(of: draftCoordinator.importRequest?.id) { _ in
                consumeExternalImport()
            }
        }
    }
        }

    private func gameChoiceCard(
        title: String,
        bundle: String,
        imageName: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(red: 0.10, green: 0.10, blue: 0.11))
                        .frame(width: 28, height: 28)

                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                Text(title)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .layoutPriority(1)

                Spacer(minLength: 4)

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(selected ? AppTheme.accent : Color.white.opacity(0.55))
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? AppTheme.accent.opacity(0.95) : Color.white.opacity(0.18),
                            lineWidth: selected ? 1.2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func consumeExternalImport() {
        guard let request = draftCoordinator.importRequest else { return }
        draftCoordinator.clearImport()
        store.importPackage(from: request.source)
    }

    @ViewBuilder
    private func itemRow(_ item: PatchLibraryItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black)
                    .frame(width: 58, height: 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )

                Image(systemName: "scope")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }

            Group {
                if item.isLocked {
                    Button { store.requestUnlock(for: item) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.project?.name ?? language.text("patch.locked_project"))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(2)

                            Text(item.summary.schemaVersion >= 2
                                 ? language.text("patch.workspace")
                                 : language.text("patch.project"))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.62))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        PatchProjectDetailView(store: store, projectID: item.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.project?.name ?? language.text("patch.locked_project"))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(2)

                            Text(item.summary.schemaVersion >= 2
                                 ? language.text("patch.workspace")
                                 : language.text("patch.project"))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.62))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }

            Toggle(
                "",
                isOn: Binding(
                    get: { store.isApplied(projectID: item.id) },
                    set: { enabled in
                        store.setApplied(enabled, for: item, freeFireVariant: selectedGameRaw)
                        if enabled {
}
                    }
                )
            )
            .labelsHidden()
            .tint(.red)
            .disabled(item.isLocked || store.isBusy)
        }
        .padding(.vertical, 10)
        .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
        .listRowBackground(Color.black.opacity(0.50))
        .listRowSeparator(.visible)
        .listRowSeparatorTint(Color.white.opacity(0.11))
    }

    private var attentionCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .stroke(AppTheme.accent, lineWidth: 2)
                    .frame(width: 34, height: 34)

                Image(systemName: "exclamationmark")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("ATENÇÃO")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.accent)

                Text("Use com responsabilidade. O uso indevido pode resultar em banimento.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light, design: .rounded))
                .foregroundStyle(AppTheme.accent)
            Text(language.text("patch.empty_title"))
                .font(.headline)
            Text(language.text("patch.empty_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(language.text("patch.new")) { showCreate = true }
                .buttonStyle(.bordered)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }

    private var searchEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light, design: .rounded))
                .foregroundStyle(.secondary)
            Text(language.text("patch.search_empty"))
                .font(.headline)
            Text(language.text("patch.search_empty_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }
}

private struct PatchProjectRow: View {
    let item: PatchLibraryItem
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 12) {
            AppRowIcon(systemName: item.isLocked ? "lock.doc.fill" : "shippingbox.fill")
            VStack(alignment: .leading, spacing: 3) {
                AnimatedPatchRowTitle(
                    text: item.project?.name ?? language.text("patch.locked_project")
                )
                Text(item.isLocked
                     ? language.text("patch.tap_to_unlock")
                     : language.text(
                        item.summary.schemaVersion >= 2 ? "patch.workspace_items_count" : "patch.rules_count",
                        Int64((item.project?.rules.count ?? 0) + (item.project?.directories.count ?? 0))
                     ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if item.summary.isPasswordProtected {
                Image(systemName: "key.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(language.text("patch.password_protected"))
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PatchUnlockView: View {
    @Environment(\.appLanguage) private var language
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PatchProjectStore
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField(language.text("patch.password"), text: $password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .onSubmit(unlock)
                        .onChange(of: password) { _ in
                            store.clearUnlockError()
                        }
                    if let errorKey = store.unlockErrorKey {
                        Text(language.text(errorKey))
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text(language.text("patch.password_once_message"))
                }
            }
            .navigationTitle(language.text("patch.unlock"))
            .navigationBarTitleDisplayMode(.inline)

        }
    }

    private func unlock() {
        guard !password.isEmpty else { return }
        store.unlock(password: password)
    }
}

private struct PatchProjectDetailView: View {
    @Environment(\.appLanguage) private var language
    @ObservedObject var store: PatchProjectStore
    let projectID: UUID
    @State private var showEditor = false
    @State private var editingRule: PatchRule?
    @State private var isWorking = false
    @State private var actionAlert: PatchStoreAlert?
    @State private var shareRequest: PatchShareRequest?

    private var item: PatchLibraryItem? {
        store.items.first(where: { $0.id == projectID })
    }

    private var isWorkspaceProject: Bool {
        (item?.summary.schemaVersion ?? 1) >= 2
    }

    var body: some View {
        List {
            if let item, let project = item.project {
                if isWorkspaceProject {
                    Section {
                        ForEach(project.allBundleIdentifiers, id: \.self) { bundleID in
                            Label {
                                Text(bundleID)
                                    .font(.subheadline.monospaced())
                            } icon: {
                                Image(systemName: "app.dashed")
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                        LabeledContent(language.text("patch.files")) {
                            Text("\(project.rules.count)")
                        }
                        LabeledContent(language.text("patch.folders")) {
                            Text("\(project.directories.count)")
                        }
                        if let workspaceURL = item.workspaceURL {
                            NavigationLink {
                                FileBrowserView(
                                    containerPath: workspaceURL.path,
                                    title: project.name,
                                    bundleID: nil
                                )
                            } label: {
                                Label(
                                    language.text("patch.open_workspace"),
                                    systemImage: "folder"
                                )
                            }
                        }
                    } header: {
                        Text(language.text("patch.workspace"))
                    } footer: {
                        Text(language.text("patch.workspace_detail_footer"))
                    }
                } else {
                    Section {
                        ForEach(project.rules) { rule in
                            Button {
                                editingRule = rule
                            } label: {
                                HStack(spacing: 10) {
                                    ruleSummary(rule)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(language.text("patch.edit_rule_hint"))
                        }
                    } header: {
                        Text(language.text("patch.rules"))
                    } footer: {
                        Text(language.text("patch.legacy_footer"))
                    }
                }

                Section(language.text("patch.password")) {
                    HStack(spacing: 12) {
                        Image(systemName: item.summary.isPasswordProtected ? "lock.fill" : "lock.open")
                            .foregroundStyle(AppTheme.accent)
                            .frame(width: 24)
                        Text(language.text(item.summary.isPasswordProtected
                            ? "patch.password_locked"
                            : "patch.no_password"))
                            .font(.subheadline)
                    }
                }

            }
        }
        .listStyle(.plain)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                AnimatedTitleText(text: item?.project?.name ?? language.text("patch.title"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isWorking {
                    ProgressView()
                } else if !isWorkspaceProject {
                    Button(language.text("patch.edit")) { showEditor = true }
                        .disabled(item?.project == nil)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            if let item, let project = item.project {
                PatchProjectEditorView(
                    existingProject: project,
                    passwordIsProtected: item.summary.isPasswordProtected
                ) { updatedProject, _ in
                    store.update(project: updatedProject)
                }
            }
        }
        .sheet(item: $editingRule) { rule in
            PatchRuleEditorView(rule: rule) { updatedRule in
                updateRule(updatedRule)
            }
        }
        .alert(item: $actionAlert) { alert in
            Alert(
                title: Text(language.text(alert.titleKey)),
                message: Text(alert.message(language: language)),
                dismissButton: .default(Text(language.text("common.ok")))
            )
        }
        .sheet(item: $shareRequest) { request in
            PatchActivityView(items: [request.url])
                .ignoresSafeArea()
        }
    }

    private func actionLabel(_ key: String, systemImage: String) -> some View {
        Label(language.text(key), systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func ruleSummary(_ rule: PatchRule) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(rule.bundleID)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(rule.relativePath)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Label(rule.replacementFilename, systemImage: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.vertical, 3)
    }

    private func updateRule(_ updatedRule: PatchRule) {
        guard var project = item?.project,
              let index = project.rules.firstIndex(where: { $0.id == updatedRule.id }) else {
            return
        }
        project.rules[index] = updatedRule
        project.updatedAt = Date()
        do {
            try PatchPackageCodec.validate(project)
            store.update(project: project)
        } catch let error as PatchPackageError {
            actionAlert = PatchStoreAlert(
                titleKey: "common.failed",
                messageKey: error.localizationKey,
                messageArgument: error.localizationArgument
            )
        } catch {
            actionAlert = PatchStoreAlert(
                titleKey: "common.failed",
                messageKey: "patch.error.invalid_project"
            )
        }
    }

    private func prepareExport() {
        guard let item else { return }
        isWorking = true
        Task.detached(priority: .userInitiated) {
            do {
                if item.summary.schemaVersion >= 2 {
                    _ = try PatchProjectLibrary.synchronizeWorkspace(item: item)
                }
                await MainActor.run {
                    store.reload()
                    isWorking = false
                    shareRequest = PatchShareRequest(url: item.packageURL)
                }
            } catch let error as PatchPackageError {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(
                        titleKey: "common.failed",
                        messageKey: error.localizationKey,
                        messageArgument: error.localizationArgument
                    )
                }
            } catch {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(
                        titleKey: "common.failed",
                        messageKey: "patch.error.invalid_project"
                    )
                }
            }
        }
    }

}

private struct PatchShareRequest: Identifiable {
    let id = UUID()
    let url: URL
}

private struct PatchActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}


private final class PatchVoiceSpeaker {
    static let shared = PatchVoiceSpeaker()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speakActivated(_ fileName: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        var name = fileName
            .replacingOccurrences(of: "@TEUSIOS", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove a file extension from the spoken name when present.
        if let dot = name.lastIndex(of: ".") {
            let suffix = name[name.index(after: dot)...]
            if !suffix.contains(" ") && suffix.count <= 8 {
                name = String(name[..<dot])
            }
        }

        let phrase = name.isEmpty ? "Arquivo ativado" : "\(name) ativado"

        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 0.95
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}
