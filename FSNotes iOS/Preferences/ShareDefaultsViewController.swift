//
//  ShareDefaultsViewController.swift
//  FSNotes iOS
//
//  Created by Codex on 3/3/26.
//

import UIKit

final class ShareDefaultsViewController: UITableViewController {

    private enum Row: Int, CaseIterable {
        case project
        case tags

        var title: String {
            switch self {
            case .project:
                return NSLocalizedString("Project", comment: "Share defaults")
            case .tags:
                return NSLocalizedString("Tags", comment: "Share defaults")
            }
        }
    }

    private var projects: [Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Share Defaults", comment: "Settings")
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProjects()
        tableView.reloadData()
    }

    private func reloadProjects() {
        let storage = Storage.shared()
        projects = storage.getProjects().filter { !$0.isTrash }
        projects.sort { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
    }

    private func currentProject() -> Project? {
        if let url = UserDefaultsManagement.shareLastProjectURL,
           let found = projects.first(where: { $0.url == url }) {
            return found
        }
        return Storage.shared().getDefault()
    }

    private func currentTags() -> String {
        return UserDefaultsManagement.shareLastTags
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        guard let row = Row(rawValue: indexPath.row) else { return cell }

        cell.textLabel?.text = row.title
        cell.accessoryType = .disclosureIndicator

        switch row {
        case .project:
            cell.detailTextLabel?.text = currentProject()?.label ?? NSLocalizedString("Inbox", comment: "")
        case .tags:
            let tags = currentTags()
            cell.detailTextLabel?.text = tags.isEmpty ? NSLocalizedString("Optional", comment: "") : tags
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let row = Row(rawValue: indexPath.row) else { return }

        switch row {
        case .project:
            if projects.isEmpty {
                showNoProjectsAlert()
                return
            }
            let controller = ShareDefaultsProjectPickerViewController(
                projects: projects,
                selectedProject: currentProject()
            )
            controller.onSelect = { [weak self] project in
                UserDefaultsManagement.shareLastProjectURL = project?.url
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(controller, animated: true)
        case .tags:
            showTagsInput()
        }
    }

    private func showTagsInput() {
        let alert = UIAlertController(
            title: NSLocalizedString("Tags", comment: "Share defaults"),
            message: NSLocalizedString("Separate tags with spaces or commas.", comment: "Share defaults"),
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.text = self.currentTags()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.placeholder = NSLocalizedString("e.g. work, urgent", comment: "Share defaults")
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { _ in
            let text = alert.textFields?.first?.text ?? ""
            UserDefaultsManagement.shareLastTags = text
            self.tableView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func showNoProjectsAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("No Projects", comment: ""),
            message: NSLocalizedString("Create a project in FSNotes to enable sharing.", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private final class ShareDefaultsProjectPickerViewController: UITableViewController {
    private let projects: [Project]
    private var selectedProject: Project?
    var onSelect: ((Project?) -> Void)?

    init(projects: [Project], selectedProject: Project?) {
        self.projects = projects
        self.selectedProject = selectedProject
        super.init(style: .insetGrouped)
        title = NSLocalizedString("Choose Project", comment: "Share defaults")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.label
        cell.accessoryType = project == selectedProject ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProject = projects[indexPath.row]
        onSelect?(selectedProject)
        navigationController?.popViewController(animated: true)
    }
}
