// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeSpellChecker",
    products: [
        .executable(name: "XcodeSpellChecker", targets: ["XcodeSpellChecker"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1")
    ],
    targets: [
        .target(
            name: "XcodeSpellChecker",
            dependencies: ["XcodeSpellCheckerCore", "Yams", "Commander"]),
        .target(
            name: "XcodeSpellCheckerCore",
            dependencies: ["Commander"]),
        .testTarget(
            name: "XcodeSpellCheckerCoreTests",
            dependencies: ["XcodeSpellCheckerCore"]),
    ]
)
