//
//  Diff.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// This is a hard limit on how big a buffer can be and still be converted into
/// a string.
let maxDiffBufferSize = 70e6 // 70MB in decimal

/// Where `MaxDiffBufferSize` is a hard limit, this is a suggested limit. Diffs
/// bigger than this _could_ be displayed but it might cause some slowness.
let maxReasonableDiffSize = maxDiffBufferSize / 16 // ~4.375MB in decimal

/// The longest line length we should try to display. If a diff has a line longer
/// than this, we probably shouldn't attempt it
let maxCharactersPerLine = 5000

/// Is the diff too large for us to reasonably represent?
/// 
/// - Parameter diff: The diff to check
/// 
/// - Returns: Whether or not the diff is too large
func isDiffToLarge(diff: IRawDiff) -> Bool {
    for hunk in diff.hunks {
        for line in hunk.lines {
            // swiftlint:disable:next for_where
            if line.text.count > maxCharactersPerLine {
                return true
            }
        }
    }
    return false
}

/// Render the difference between a file in the given commit and its parent
///
/// - Parameter directoryURL: The directory to look up the value in.
/// - Parameter file: The file to diff
/// - Parameter commitish: The commit hash to diff against
/// - Parameter hideWhitespaceInDiff: Whether or not to hide whitespace changes
/// 
/// - Returns: The diff
/// 
/// - Throws: Error
func getCommitDiff(directoryURL: URL,
                   file: FileItem,
                   commitish: String,
                   hideWhitespaceInDiff: Bool = false) throws -> IDiff {
    var args = [
        "log",
        commitish,
        hideWhitespaceInDiff ? ["-w"] : [],
        "-m",
        "-1",
        "--first-parent",
        "--patch-with-raw",
        "-z",
        "--no-colour",
        "--",
        file.url.absoluteString
    ] as [Any]

    if file.gitStatus == .renamed || file.gitStatus == .copied {
        // TODO: Change this to old path instead
        args.append(file.url.absoluteString)
    }

    let output = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    return try buildDiff(directoryURL: directoryURL,
                     file: file,
                     oldestCommitish: commitish,
                     lineEndingsChange: nil)
}

/// Render the difference between a file in the given commit range
/// 
/// - Parameter directoryURL: The directory to look up the value in.
/// - Parameter file: The file to diff
/// - Parameter commits: The commit hashes to diff between
/// - Parameter hideWhitespacesInDiff: Whether or not to hide whitespace changes
/// - Parameter useNillTreeSHA: Whether or not to use the nil tree SHA
func getCommitRangeDiff(directoryURL: URL,
                        file: FileItem,
                        commits: [String],
                        hideWhitespacesInDiff: Bool = false,
                        useNillTreeSHA: Bool = false) throws -> IDiff {
    if commits.isEmpty {
        throw DiffErrors.noCommits("No commits to diff...")
    }

    let oldestCommitRef = useNillTreeSHA ? nilTreeSHA : "\(commits[0])^"
    let latestCommit = commits[-1]

    var args = [
        "diff",
        oldestCommitRef,
        latestCommit,
        hideWhitespacesInDiff ? ["-w"] : [],
        "--patch-with-raw",
        "-z",
        "--no-color",
        "--",
        file.url.absoluteString
    ] as [Any]

    if file.gitStatus == .renamed || file.gitStatus == .copied {
        // TODO: Change this to old path instead
        args.append(file.url.absoluteString)
    }

    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    return try buildDiff(directoryURL: directoryURL,
                         file: file,
                         oldestCommitish: latestCommit,
                         lineEndingsChange: nil)
}

/// Get the changes in the working directory
/// 
/// - Parameter directoryURL: The directory URL
/// - Parameter shas: The commit hashes to diff between
/// - Parameter useNillTreeSHA: Whether or not to use the nil tree SHA
func getCommitRangeChangeFiles(directoryURL: URL,
                               shas: [String],
                               useNillTreeSHA: Bool = false) {

}

/// Render the diff for a file within the repository working directory. The file will be
/// compared against HEAD if it's tracked, if not it'll be compared to an empty file meaning
/// that all content in the file will be treated as additions.
/// 
/// - Parameter workspaceURL: The workspace URL
/// - Parameter file: The file to diff
/// - Parameter hideWhitespaceInDiff: Whether or not to hide whitespace changes
/// 
/// - Throws: Error
func getWorkingDirectoryDiff(workspaceURL: URL,
                             file: FileItem,
                             hideWhitespaceInDiff: Bool = false) throws {
    var args: [Any] = [
        "diff",
        (hideWhitespaceInDiff ? ["-w"] : []),
        "--no-ext-diff",
        "--patch-with-raw",
        "-z",
        "--no-color"
    ]

    if file.gitStatus == .added || file.gitStatus == .unknown {
        args.append("--no-index")
        args.append("--")
        args.append("/dev/null")
        args.append(file.url)
    } else if file.gitStatus == .renamed {
        args.append("--")
        args.append(file.url)
    } else {
        args.append("HEAD")
        args.append(file.url)
    }
}

/// `git diff` will write out messages about the line ending changes it knows
/// about to `stderr` - this rule here will catch this and also the to/from
/// changes based on what the user has configured.
let lineEndingsChangeRegex = "warning: (CRLF|CR|LF) will be replaced by (CRLF|CR|LF) in .*"

/// Get binary paths in the repository
/// 
/// - Parameter directoryURL: The directory URL
/// 
/// - Returns: The binary paths
/// 
/// - Throws: Error
func getBinaryPaths(directoryURL: URL, ref: String) throws -> [String] {
    let output = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git diff --numstat -z \(ref)")

    return [""]
}

/// Get the diff
/// 
/// - Parameter directoryURL: The directory URL
/// - Parameter file: The file to diff
/// - Parameter diff: The diff
/// - Parameter oldestCommitish: The oldest commit hash
/// - Parameter lineEndignsChange: The line endings change
func convertDiff(directoryURL: URL,
                 file: FileItem,
                 diff: IRawDiff,
                 oldestCommitish: String,
                 lineEndignsChange: LineEndingsChange?) -> IDiff {
    let fileExtension = file.url.lastPathComponent.lowercased()

    return IDiff.text(ITextDiff(text: diff.contents,
                                hunks: diff.hunks,
                                lineEndingsChange: lineEndignsChange,
                                maxLineNumber: diff.maxLineNumber,
                                hasHiddenBidiChars: diff.hasHiddenBidiChars))
}

/// Parse the diff from the raw output
/// 
/// - Parameter output: The output
/// 
/// - Returns: The diff
func diffFromRawDiffOutput(output: String) -> IRawDiff {
    let result = output
    let pieces = result.split(separator: "\0").map { String($0) }
    let parser = DiffParser()
    return parser.parse(text: pieces[-1])
}

/// Build the diff
/// 
/// - Parameter directoryURL: The directory URL
/// - Parameter file: The file to diff
/// - Parameter oldestCommitish: The oldest commit hash
/// - Parameter lineEndingsChange: The line endings change
/// 
/// - Returns: The diff
/// 
/// - Throws: Error
func buildDiff(directoryURL: URL,
               file: FileItem,
               oldestCommitish: String,
               lineEndingsChange: LineEndingsChange?) throws -> IDiff {

    let diff: IRawDiff = IRawDiff(header: "",
                                  contents: "",
                                  hunks: [],
                                  isBinary: false,
                                  maxLineNumber: 0,
                                  hasHiddenBidiChars: false)

    if isDiffToLarge(diff: diff) {
        let largeTextDiff: ILargeTextDiff = ILargeTextDiff(text: diff.contents,
                                                           hunks: diff.hunks,
                                                           lineEndingsChange: lineEndingsChange,
                                                           maxLineNumber: diff.maxLineNumber,
                                                           hasHiddenBidiChars: diff.hasHiddenBidiChars)
    }

    return convertDiff(directoryURL: directoryURL,
                       file: file,
                       diff: diff,
                       oldestCommitish: oldestCommitish,
                       lineEndignsChange: lineEndingsChange)
}

/// The regex to match binary files in the diff
let binaryListRegex = "/-\t-\t(?:\0.+\0)?([^\0]*)/gi"

/// Diff errors
enum DiffErrors: Error {

    /// No commits
    /// 
    /// - Parameter message: The message
    case noCommits(String)
}
