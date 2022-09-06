//
//  GitCloneView+Helpers.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 6/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension GitCloneView {
    func getPath(modifiable: inout String, saveName: String) -> String? {
        let dialog = NSSavePanel()
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.showsTagField = false
        dialog.prompt = "Clone"
        dialog.nameFieldStringValue = saveName
        dialog.nameFieldLabel = "Clone as"
        dialog.title = "Clone"

        if dialog.runModal() ==  NSApplication.ModalResponse.OK {
            let result = dialog.url

            if result != nil {
                let path: String = result!.path
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
                modifiable = path
                return path
            }
        } else {
            // User clicked on "Cancel"
            return nil
        }
        return nil
    }

    func showAlert(alertMsg: String, infoText: String) {
        let alert = NSAlert()
        alert.messageText = alertMsg
        alert.informativeText = infoText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }

    func isValid(url: String) -> Bool {
        // Doing the same kind of check that Xcode does when cloning
        let url = url.lowercased()
        if url.starts(with: "http://") && url.count > 7 {
            return true
        } else if url.starts(with: "https://") && url.count > 8 {
            return true
        } else if url.starts(with: "git@") && url.count > 4 {
            return true
        }
        return false
    }

    func checkClipboard(textFieldText: inout String) {
        if let url = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            if isValid(url: url) {
                textFieldText = url
            }
        }
    }

    func cancelClone(deleteRemains: Bool = false) {
        isPresented = false
        cloneCancellable?.cancel()

        guard deleteRemains && FileManager.default.fileExists(atPath: repoPathStr) else { return }
        do {
            try FileManager.default.removeItem(atPath: repoPathStr)
        } catch {
            showAlert(alertMsg: "Error", infoText: error.localizedDescription)
        }
    }

    // MARK: Clone repo
    func cloneRepository() { // swiftlint:disable:this function_body_length
        do {
            if repoUrlStr.isEmpty {
                showAlert(alertMsg: "Url cannot be empty",
                          infoText: "You must specify a repository to clone")
                return
            }
            // Parsing repo name
            let repoURL = URL(string: repoUrlStr)
            if var repoName = repoURL?.lastPathComponent {
                // Strip .git from name if it has it.
                // Cloning repository without .git also works
                if repoName.contains(".git") {
                    repoName.removeLast(4)
                }
                guard getPath(modifiable: &repoPath, saveName: repoName) != nil else {
                    return
                }
            } else {
                return
            }
            guard let dirUrl = URL(string: repoPath) else {
                return
            }
            var isDir: ObjCBool = true
            if FileManager.default.fileExists(atPath: repoPath, isDirectory: &isDir) {
                showAlert(alertMsg: "Error", infoText: "Directory already exists")
                return
            }
            repoPathStr = repoPath
            try FileManager.default.createDirectory(atPath: repoPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            gitClient = GitClient.init(
                directoryURL: dirUrl,
                shellClient: shellClient
            )

            cloneCancellable = gitClient?
                .cloneRepository(path: repoUrlStr)
                .sink(receiveCompletion: { result in
                    switch result {
                    case let .failure(error):
                        switch error {
                        case .notGitRepository:
                            showAlert(alertMsg: "Error", infoText: "Not a git repository")
                        case let .outputError(error):
                            showAlert(alertMsg: "Error", infoText: error)
                        default:
                            showAlert(alertMsg: "Error", infoText: "Failed to decode URL")
                        }
                    case .finished: break
                    }
                }, receiveValue: { result in
                    switch result {
                    case .cloningInto:
                        isCloning = true
                    case let .countingProgress(progress):
                        cloningStage = 0
                        valueCloning = progress
                    case let .compressingProgress(progress):
                        cloningStage = 1
                        valueCloning = progress
                    case let .receivingProgress(progress):
                        cloningStage = 2
                        valueCloning = progress
                    case let .resolvingProgress(progress):
                        cloningStage = 3
                        valueCloning = progress
                        if progress >= 100 {
                            cloningStage = 4
                            cloneCancellable?.cancel()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                isPresented = false
                            })
                        }
                    case .other: break
                    }
                })
            checkBranches(dirUrl: dirUrl)
        } catch {
            showAlert(alertMsg: "Error", infoText: error.localizedDescription)
        }
    }
    private func checkBranches(dirUrl: URL) {
        // Check if repo has only one branch, and if so, don't show the checkout page
        do {
            let branches = try GitClient.init(directoryURL: dirUrl,
                                              shellClient: shellClient).getBranches(allBranches: true)
            let filtered = branches.filter { !$0.contains("HEAD") }
            if filtered.count > 1 {
                showCheckout = true
            }
        } catch {
            return
        }
    }
}

