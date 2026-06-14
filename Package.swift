// swift-tools-version: 5.9
import PackageDescription

// TaigiEmojis — Swift package wrapping the shared dist/emoji.json for iOS/macOS apps.
// The JSON resource is a symlink to the repo's single generated dist/emoji.json.
let package = Package(
    name: "TaigiEmojis",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "TaigiEmojis", targets: ["TaigiEmojis"]),
    ],
    targets: [
        .target(
            name: "TaigiEmojis",
            path: "platforms/apple/Sources/TaigiEmojis",
            resources: [.copy("Resources/emoji.json")]
        ),
        .testTarget(
            name: "TaigiEmojisTests",
            dependencies: ["TaigiEmojis"],
            path: "platforms/apple/Tests/TaigiEmojisTests"
        ),
    ]
)
