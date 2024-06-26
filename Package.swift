// swift-tools-version:5.10

import Foundation
import PackageDescription

let package = Package(
    name: "WordPressShared",
    platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(name: "WordPressShared", targets: ["WordPressShared"])
    ],
    dependencies: [
        .package(url: "https://github.com/buildkite/test-collector-swift", from: "0.3.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(url: "https://github.com/realm/SwiftLint", exact: loadSwiftLintVersion())
    ],
    targets: [
        .target(
            name: "WordPressSharedObjC",
            resources: [.process("Resources")]
        ),
        .target(
            name: "WordPressShared",
            dependencies: [
                .target(name: "WordPressSharedObjC"),
            ],
            resources: [.process("Resources")],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "WordPressSharedTests",
            dependencies: [
                .target(name: "WordPressShared"),
                .product(name: "BuildkiteTestCollector", package: "test-collector-swift"),
                "OHHTTPStubs",
            ],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "WordPressSharedObjCTests",
            dependencies: [
                .target(name: "WordPressShared"),
                .product(name: "BuildkiteTestCollector", package: "test-collector-swift"),
                "OHHTTPStubs",
            ],
            resources: [.process("Resources")],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
    ]
)

func loadSwiftLintVersion() -> Version {
    let swiftLintConfigURL = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent(".swiftlint.yml")

    guard let yamlString = try? String(contentsOf: swiftLintConfigURL) else {
        fatalError("Failed to read SwiftLint config file at \(swiftLintConfigURL).")
    }

    guard let versionLine = yamlString.components(separatedBy: .newlines)
        .first(where: { $0.contains("swiftlint_version") }) else {
        fatalError("SwiftLint version not found in YAML file.")
    }

    // Assumes the format `swiftlint_version: <version>`
    guard let version = Version(versionLine.components(separatedBy: ":")
        .last?
        .trimmingCharacters(in: .whitespaces) ?? "") else {
        fatalError("Failed to extract SwiftLint version.")
    }

    return version
}
