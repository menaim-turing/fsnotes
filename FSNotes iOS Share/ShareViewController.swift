//
//  ShareViewController.swift
//  FSNotes iOS Share
//
//  Created by Oleksandr Glushchenko on 3/18/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import UIKit
import MobileCoreServices
import Social
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: SLComposeServiceViewController {

    // MARK: - Properties

    private var hasImages = false
    private var urlPreview: String?

    /// The project the user has chosen (nil = default)
    private var selectedProject: Project?

    /// Sorted, non-trash projects available for selection
    private lazy var availableProjects: [Project] = {
        let storage = Storage.shared()
        return storage.getProjects()
            .filter { !$0.isTrash && !$0.isVirtual }
            .sorted { $0.getFullLabel() < $1.getFullLabel() }
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        restoreLastSelections()
        configureNavigationBar()
    }

    // MARK: - Restore last selections

    private func restoreLastSelections() {
        // Restore last project
        if let lastURL = UserDefaultsManagement.shareLastProjectURL {
            selectedProject = availableProjects.first(where: { $0.url == lastURL })
        }

        // Default to the default project if nothing remembered or projects changed
        if selectedProject == nil {
            selectedProject = Storage.shared().getDefault()
        }
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar,
              let rightButton = navigationBar.topItem?.rightBarButtonItem else {
            return
        }

        rightButton.title = NSLocalizedString("New note", comment: "")
        navigationBar.tintColor = .mainTheme

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        titleLabel.text = "FSNotes"
        titleLabel.font = UserDefaultsManagement.noteFont.bold().withSize(18)
        navigationBar.topItem?.titleView = titleLabel
    }

    // MARK: - Preview

    override func loadPreviewView() -> UIView! {
        urlPreview = textView.text

        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return UIView()
        }

        processInputItems(inputItems)
        return hasImages ? super.loadPreviewView() : UIView()
    }

    private func processInputItems(_ items: [NSExtensionItem]) {
        for item in items {
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                if checkForImages(in: attachment) {
                    hasImages = true
                    textView.text = ""
                    return
                }

                loadURLIfNeeded(from: attachment)
            }
        }
    }

    private func checkForImages(in attachment: NSItemProvider) -> Bool {
        return attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) ||
               attachment.hasItemConformingToTypeIdentifier(kUTTypeJPEG as String)
    }

    private func loadURLIfNeeded(from attachment: NSItemProvider) {
        guard attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else {
            return
        }

        attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] url, error in
            guard let self = self,
                  let url = url as? URL,
                  error == nil else {
                return
            }

            self.handleLoadedURL(url)
        }
    }

    private func handleLoadedURL(_ url: URL) {
        if url.absoluteString.starts(with: "file:///") {
            loadFileContent(from: url)
        } else {
            updateTextViewWithURL(url)
        }
    }

    private func loadFileContent(from url: URL) {
        guard let fileData = try? Data(contentsOf: url),
              let text = String(data: fileData, encoding: .utf8) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.textView.text = text
        }
    }

    private func updateTextViewWithURL(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let preview = self.urlPreview ?? ""
            self.textView.text = "\(preview)\n\n\(url.absoluteString)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    // MARK: - Configuration Items (Project + Tags)

    override func configurationItems() -> [Any]! {
        var items = [SLComposeSheetConfigurationItem]()

        // Project picker
        let projectItem = SLComposeSheetConfigurationItem()!
        projectItem.title = NSLocalizedString("Project", comment: "Share extension project picker")
        projectItem.value = selectedProject?.getFullLabel() ?? NSLocalizedString("Default", comment: "")
        projectItem.tapHandler = { [weak self] in
            self?.presentProjectPicker()
        }
        items.append(projectItem)

        // Tags input
        let tagsItem = SLComposeSheetConfigurationItem()!
        tagsItem.title = NSLocalizedString("Tags", comment: "Share extension tags input")
        tagsItem.value = UserDefaultsManagement.shareLastTags
        tagsItem.tapHandler = { [weak self] in
            self?.presentTagsInput()
        }
        items.append(tagsItem)

        return items
    }

    // MARK: - Project Picker

    private func presentProjectPicker() {
        let alert = UIAlertController(
            title: NSLocalizedString("Choose Project", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        if availableProjects.isEmpty {
            alert.message = NSLocalizedString("No projects found. Notes will be saved in the default location.", comment: "")
        } else {
            for project in availableProjects {
                let action = UIAlertAction(title: project.getFullLabel(), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.selectedProject = project
                    UserDefaultsManagement.shareLastProjectURL = project.url
                    self.reloadConfigurationItems()
                }
                if project == selectedProject {
                    action.setValue(true, forKey: "checked")
                }
                alert.addAction(action)
            }
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        // iPad popover support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    // MARK: - Tags Input

    private func presentTagsInput() {
        let alert = UIAlertController(
            title: NSLocalizedString("Add Tags", comment: ""),
            message: NSLocalizedString("Enter comma-separated tags (e.g. work, ideas)", comment: ""),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = UserDefaultsManagement.shareLastTags
            textField.placeholder = NSLocalizedString("work, ideas, inbox", comment: "")
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .whileEditing
        }

        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let raw = alert.textFields?.first?.text ?? ""
            let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaultsManagement.shareLastTags = cleaned
            self.reloadConfigurationItems()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: - Validation & Post

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        saveNote()
    }

    // MARK: - Save Note

    private func saveNote() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            closeExtension()
            return
        }

        let note = createNote()
        processAttachments(from: inputItems, note: note)
    }

    private func createNote() -> Note {
        let project = selectedProject ?? Storage.shared().getDefault()!
        let note = Note(project: project)
        Storage.shared().add(note)

        var urls = UserDefaultsManagement.importURLs
        urls.insert(note.url, at: 0)
        UserDefaultsManagement.importURLs = urls

        return note
    }

    private func applyTags(to note: Note) {
        let tagsString = UserDefaultsManagement.shareLastTags
        guard !tagsString.isEmpty else { return }

        let tags = tagsString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for tag in tags {
            note.addTag(tag)
        }
    }

    private func appendTextContent(to note: Note) {
        guard !textView.text.isEmpty else { return }
        note.append(string: NSMutableAttributedString(string: textView.text))
    }

    private func processAttachments(from items: [NSExtensionItem], note: Note) {
        var imageProviders: [NSItemProvider] = []

        for item in items {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    imageProviders.append(provider)
                } else if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    processURLAttachment(note: note)
                    return
                } else if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    processTextAttachment(note: note)
                    return
                }
            }
        }

        if imageProviders.isEmpty {
            closeExtension()
        } else {
            processImageAttachments(imageProviders, note: note)
        }
    }

    private func processImageAttachments(_ providers: [NSItemProvider], note: Note) {
        let totalCount = providers.count
        var processedCount = 0

        for provider in providers {
            provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: [:]) { [weak self] data, error in
                guard let self = self, error == nil else {
                    processedCount += 1
                    if processedCount == totalCount {
                        self?.finalizeNoteSave(note)
                    }
                    return
                }

                let imageData = self.extractImageData(from: data)
                let url = data as? URL

                if let imageData = imageData {
                    note.append(image: imageData, url: url)
                }

                processedCount += 1
                if processedCount == totalCount {
                    self.finalizeNoteSave(note)
                }
            }
        }
    }

    private func extractImageData(from data: Any?) -> Data? {
        if let data = data as? Data {
            return data
        } else if let image = data as? UIImage {
            return image.jpegData(compressionQuality: 1)
        } else if let url = data as? URL {
            return try? Data(contentsOf: url)
        }
        return nil
    }

    private func processURLAttachment(note: Note) {
        guard !hasImages, let contentText = contentText else {
            closeExtension()
            return
        }

        if let url = URL(string: contentText),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data),
           image.size.width > 0 {
            note.append(image: data)
        } else {
            appendContentWithPrefix(contentText, to: note)
        }

        finalizeNoteSave(note)
    }

    private func processTextAttachment(note: Note) {
        guard !hasImages, let contentText = contentText else {
            closeExtension()
            return
        }

        appendContentWithPrefix(contentText, to: note)
        finalizeNoteSave(note)
    }

    private func appendContentWithPrefix(_ content: String, to note: Note) {
        let prefix = note.content.length == 0 ? "" : "\n\n"
        let string = NSMutableAttributedString(string: "\(prefix)\(content)")
        note.append(string: string)
    }

    private func finalizeNoteSave(_ note: Note) {
        applyTags(to: note)
        if note.saveSimple() {
            Storage.shared().add(note)
        }
        closeExtension()
    }

    private func closeExtension() {
        extensionContext?.completeRequest(returningItems: extensionContext?.inputItems, completionHandler: nil)
    }
}
