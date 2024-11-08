// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yatoro",
    platforms: [.macOS("14.0")],
    dependencies: [
        .package(
            url: "https://github.com/jayadamsmorgan/swift-argument-parser.git",
            branch: "1.5.0-publicError"
        ),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3"),
        .package(url: "https://github.com/elegantchaos/Versionator.git", from: "2.0.6"),
    ],
    targets: [
        .systemLibrary(
            name: "notcurses",
            pkgConfig: "notcurses",
            providers: [
                .apt(["notcurses"]),
                .brew(["notcurses"]),
            ]
        ),
        .target(
            name: "SwiftNotCurses",
            dependencies: ["notcurses"]
        ),
        .executableTarget(
            name: "yatoro",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Yams", package: "Yams"),
                "SwiftNotCurses",
            ],
            path: "Sources/Yatoro",
            exclude: [
                "Resources/Info.plist"
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Yatoro/Resources/Info.plist",
                ])
            ],
            plugins: [
                .plugin(name: "VersionatorPlugin", package: "Versionator")
            ]
        ),
        .testTarget(
            name: "YatoroTests",
            dependencies: ["yatoro"]
        ),
    ]
)
