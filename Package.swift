// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yatoro",
    platforms: [.macOS("14.0")],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.5.0"
        ),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.1"),
        .package(
            url: "https://github.com/rryam/MusadoraKit.git",
            from: "5.0.3"
        ),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3"),
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
        .executableTarget(
            name: "Yatoro",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "MusadoraKit", package: "MusadoraKit"),
                .product(name: "Yams", package: "Yams"),
                "notcurses",
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Yatoro/Resources/Info.plist",
                ])
            ]
        ),
        .testTarget(
            name: "YatoroTests",
            dependencies: ["Yatoro"]
        ),
    ]
)
