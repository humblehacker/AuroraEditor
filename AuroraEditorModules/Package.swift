// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AuroraEditorModules",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WorkspaceClient",
            targets: ["WorkspaceClient"]
        ),
        .library(
            name: "CodeFile",
            targets: ["CodeFile"]
        ),
        .library(
            name: "WelcomeModule",
            targets: ["WelcomeModule"]
        ),
        .library(
            name: "StatusBar",
            targets: ["StatusBar"]
        ),
        .library(
            name: "TerminalEmulator",
            targets: ["TerminalEmulator"]
        ),
        .library(
            name: "Search",
            targets: ["Search"]
        ),
        .library(
            name: "ShellClient",
            targets: ["ShellClient"]
        ),
        .library(
            name: "AppPreferences",
            targets: ["AppPreferences"]
        ),
        .library(
            name: "About",
            targets: ["About"]
        ),
        .library(
            name: "Acknowledgements",
            targets: ["Acknowledgements"]
        ),
        .library(
            name: "QuickOpen",
            targets: ["QuickOpen"]
        ),
        .library(
            name: "AuroraEditorUI",
            targets: ["AuroraEditorUI"]
        ),
        .library(
            name: "AuroraEditorSymbols",
            targets: ["AuroraEditorSymbols"]
        ),
        .library(
            name: "ExtensionsStore",
            targets: ["ExtensionsStore"]
        ),
        .library(
            name: "Breadcrumbs",
            targets: ["Breadcrumbs"]
        ),
        .library(
            name: "Feedback",
            targets: ["Feedback"]
        ),
        .library(
            name: "AuroraEditorUtils",
            targets: ["AuroraEditorUtils"]
        ),
        .library(
            name: "TabBar",
            targets: ["TabBar"]
        ),
        .library(
            name: "Git",
            targets: ["Git"]
        ),
        .library(
            name: "AuroraEditorNotifications",
            targets: ["AuroraEditorNotifications"]
        )
    ],
    dependencies: [
        .package(
            name: "Highlightr",
            url: "https://github.com/lukepistrol/Highlightr.git",
            branch: "main"
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
        .package(
            name: "SwiftTerm",
            url: "https://github.com/migueldeicaza/SwiftTerm.git",
            from: "1.0.7"
        ),
        .package(
            name: "Preferences",
            url: "https://github.com/sindresorhus/Preferences.git",
            from: "2.5.0"
        ),
        .package(
            name: "CodeEditKit",
            url: "https://github.com/CodeEditApp/CodeEditKit",
            branch: "main"
        ),
        .package(
            name: "Light-Swift-Untar",
            url: "https://github.com/Light-Untar/Light-Swift-Untar",
            from: "1.0.4"
        )
    ],
    targets: [
        .target(
            name: "WorkspaceClient",
            dependencies: [
                "TabBar"
            ],
            path: "Modules/WorkspaceClient/src"
        ),
        .testTarget(
            name: "WorkspaceClientTests",
            dependencies: [
                "WorkspaceClient"
            ],
            path: "Modules/WorkspaceClient/Tests"
        ),
        .target(
            name: "CodeFile",
            dependencies: [
                "Highlightr",
                "AppPreferences",
                "AuroraEditorUtils"
            ],
            path: "Modules/CodeFile/src"
        ),
        .testTarget(
            name: "CodeFileTests",
            dependencies: [
                "CodeFile"
            ],
            path: "Modules/CodeFile/Tests"
        ),
        .target(
            name: "WelcomeModule",
            dependencies: [
                "WorkspaceClient",
                "AuroraEditorUI",
                "Git",
                "AppPreferences"
            ],
            path: "Modules/WelcomeModule/src",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WelcomeModuleTests",
            dependencies: [
                "WelcomeModule",
                "Git",
                "ShellClient",
                "SnapshotTesting"
            ],
            path: "Modules/WelcomeModule/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "StatusBar",
            dependencies: [
                "TerminalEmulator",
                "CodeFile",
                "AuroraEditorUI",
                "AuroraEditorSymbols"
            ],
            path: "Modules/StatusBar/src"
        ),
        .testTarget(
            name: "StatusBarTests",
            dependencies: [
                "StatusBar",
                "SnapshotTesting"
            ],
            path: "Modules/StatusBar/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "TerminalEmulator",
            dependencies: [
                "SwiftTerm",
                "AppPreferences"
            ],
            path: "Modules/TerminalEmulator/src"
        ),
        .target(
            name: "Search",
            dependencies: [
                "WorkspaceClient"
            ],
            path: "Modules/Search/src"
        ),
        .target(
            name: "ShellClient",
            path: "Modules/ShellClient/src"
        ),
        .target(
            name: "AppPreferences",
            dependencies: [
                "Preferences",
                "AuroraEditorUI",
                "Git",
                "AuroraEditorUtils"
            ],
            path: "Modules/AppPreferences/src",
            resources: [.copy("Resources")]
        ),
        .target(
            name: "About",
            dependencies: [
                "Acknowledgements",
                "AuroraEditorUtils"
            ],
            path: "Modules/About/src"
        ),
        .target(
            name: "QuickOpen",
            dependencies: [
                "WorkspaceClient",
                "CodeFile",
                "AuroraEditorUI"
            ],
            path: "Modules/QuickOpen/src"
        ),
        .target(
            name: "AuroraEditorUI",
            dependencies: [
                "AuroraEditorSymbols",
                "WorkspaceClient",
                "Git"
            ],
            path: "Modules/AuroraEditorUI/src"
        ),
        .target(
            name: "AuroraEditorSymbols",
            dependencies: [],
            path: "Modules/AuroraEditorSymbols/src"
        ),
        .testTarget(
            name: "AuroraEditorUITests",
            dependencies: [
                "AuroraEditorUI",
                "WorkspaceClient",
                "Git",
                "SnapshotTesting"
            ],
            path: "Modules/AuroraEditorUI/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "Acknowledgements",
            path: "Modules/Acknowledgements/src"
        ),
        .target(
            name: "ExtensionsStore",
            dependencies: [
                "CodeEditKit",
                "Light-Swift-Untar",
                "LSP"
            ],
            path: "Modules/ExtensionsStore/src"
        ),
        .target(
            name: "Breadcrumbs",
            dependencies: [
                "WorkspaceClient",
                "AppPreferences"
            ],
            path: "Modules/Breadcrumbs/src"
        ),
        .target(
            name: "Feedback",
            dependencies: [
                "Git",
                "AuroraEditorUI",
                "AppPreferences",
                "AuroraEditorUtils"
            ],
            path: "Modules/Feedback/src"
        ),
        .target(
            name: "LSP",
            path: "Modules/LSP/src"

        ),
        .target(
            name: "AuroraEditorUtils",
            path: "Modules/AuroraEditorUtils/src"
        ),
        .target(
            name: "TabBar",
            path: "Modules/TabBar/src"
        ),
        .testTarget(
            name: "AuroraEditorUtilsTests",
            dependencies: [
                "AuroraEditorUtils"
            ],
            path: "Modules/AuroraEditorUtils/Tests"
        ),
        .target(
            name: "Git",
            dependencies: [
                "ShellClient",
                "WorkspaceClient"
            ],
            path: "Modules/Git/src"
        ),
        .testTarget(
            name: "GitTests",
            dependencies: [
                "Git",
                "ShellClient"
            ],
            path: "Modules/Git/Tests"
        ),
        .target(
            name: "AuroraEditorNotifications",
            path: "Modules/AuroraEditorNotifications/src"
        )
    ]
)
