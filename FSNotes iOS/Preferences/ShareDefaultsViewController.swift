//
//  ShareDefaultsViewController.swift
//  FSNotes iOS
//
//  Created by Codex on 3/3/26.
//

import SwiftUI

final class ShareDefaultsViewController: UIHostingController<ShareDefaultsRootView> {
    init() {
        super.init(rootView: ShareDefaultsRootView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ShareDefaultsRootView())
    }
}

struct ShareDefaultsRootView: View {
    @State private var projects: [Project] = []
    @State private var selectedProject: Project?
    @State private var tagsInput: String = UserDefaultsManagement.shareLastTags
    @State private var showNoProjectsAlert = false

    var body: some View {
        List {
            Section {
                if projects.isEmpty {
                    Button {
                        showNoProjectsAlert = true
                    } label: {
                        HStack {
                            Text("Project")
                            Spacer()
                            Text("No projects found")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    NavigationLink {
                        ShareDefaultsProjectPickerView(
                            projects: projects,
                            selectedProject: $selectedProject
                        )
                    } label: {
                        HStack {
                            Text("Project")
                            Spacer()
                            Text(currentProjectLabel)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                NavigationLink {
                    ShareDefaultsTagsView(tagsInput: $tagsInput)
                } label: {
                    HStack {
                        Text("Tags")
                        Spacer()
                        Text(tagsInput.isEmpty ? "Optional" : tagsInput)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(Text("Share Defaults"))
        .onAppear {
            reloadProjects()
            if selectedProject == nil {
                selectedProject = initialProject()
            }
        }
        .onChange(of: selectedProject) { _, newValue in
            UserDefaultsManagement.shareLastProjectURL = newValue?.url
        }
        .onChange(of: tagsInput) { _, newValue in
            UserDefaultsManagement.shareLastTags = newValue
        }
        .alert("No Projects", isPresented: $showNoProjectsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Create a project in FSNotes to enable sharing.")
        }
    }

    private var currentProjectLabel: String {
        return selectedProject?.label ?? (Storage.shared().getDefault()?.label ?? "Inbox")
    }

    private func reloadProjects() {
        let storage = Storage.shared()
        projects = storage.getProjects().filter { !$0.isTrash }
        projects.sort { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
    }

    private func initialProject() -> Project? {
        if let url = UserDefaultsManagement.shareLastProjectURL,
           let found = projects.first(where: { $0.url == url }) {
            return found
        }
        return Storage.shared().getDefault()
    }
}

private struct ShareDefaultsProjectPickerView: View {
    private struct ProjectRow: Identifiable {
        let id: Int
        let project: Project
    }

    let projects: [Project]
    @Binding var selectedProject: Project?

    private var rows: [ProjectRow] {
        return projects.enumerated().map { ProjectRow(id: $0.offset, project: $0.element) }
    }

    var body: some View {
        List {
            SwiftUI.ForEach(rows, id: \.id) { (row: ProjectRow) in
                let project = row.project
                Button {
                    selectedProject = project
                } label: {
                    HStack {
                        Text(project.label)
                        Spacer()
                        if selectedProject?.label == project.label {
                            SwiftUI.Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("Choose Project"))
    }
}

private struct ShareDefaultsTagsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var tagsInput: String

    var body: some View {
        Form {
            Section {
                TextField("e.g. work, urgent", text: $tagsInput)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } footer: {
                Text("Separate tags with spaces or commas.")
            }
        }
        .navigationTitle(Text("Tags"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

