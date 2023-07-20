// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var swiftSettings: [SwiftSetting] = [
    .define("SQLITE_ENABLE_FTS5"),
    .define("SQLITE_ENABLE_SNAPSHOT")
]
var cSettings: [CSetting] = []
var dependencies: [PackageDescription.Package.Dependency] = []

// For Swift 5.8+
//swiftSettings.append(.enableUpcomingFeature("ExistentialAny"))

// Don't rely on those environment variables. They are ONLY testing conveniences:
// $ SQLITE_ENABLE_PREUPDATE_HOOK=1 make test_SPM
if ProcessInfo.processInfo.environment["SQLITE_ENABLE_PREUPDATE_HOOK"] == "1" {
    swiftSettings.append(.define("SQLITE_ENABLE_PREUPDATE_HOOK"))
    cSettings.append(.define("GRDB_SQLITE_ENABLE_PREUPDATE_HOOK"))
}

// The SPI_BUILDER environment variable enables documentation building
// on <https://swiftpackageindex.com/groue/GRDB.swift>. See
// <https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/2122>
// for more information.
//
// SPI_BUILDER also enables the `make docs-localhost` command.
if ProcessInfo.processInfo.environment["SPI_BUILDER"] == "1" {
    dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
}

let package = Package(
    name: "GRDB",
    defaultLocalization: "en", // for tests
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(name: "CSQLite", targets: ["CSQLite"]),
        .library(name: "GRDB", targets: ["GRDB"]),
        .library(name: "GRDB-dynamic", type: .dynamic, targets: ["GRDB"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "CSQLite",
            publicHeadersPath: ".",
            cSettings: [
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("ENABLE_API_ARMOR"),
                .define("ENABLE_FTS3"),
                .define("ENABLE_FTS3_PARENTHESIS"),
                .define("ENABLE_FTS5"),
                .define("ENABLE_LOCKING_STYLE", to: "0"), // may need to set to 1 for mac os
                .define("ENABLE_RTREE"),
                .define("ENABLE_UPDATE_DELETE_LIMIT"),
                .define("OMIT_AUTORESET"),
                .define("OMIT_BUILTIN_TEST"),
                .define("OMIT_LOAD_EXTENSION"),
                .define("SYSTEM_MALLOC"),
                .define("THREADSAFE", to: "2"),
                .unsafeFlags(["-w"])
            ]
        ),
        .binaryTarget(
            name: "libsimple",
            path: "Sources/libsimple.xcframework"
        ),
        .target(
            name: "GRDB",
            dependencies: ["CSQLite", "libsimple"],
            path: "GRDB",
            resources: [.copy("JIEBA.bundle")],
            cSettings: cSettings,
            swiftSettings: swiftSettings),
        .testTarget(
            name: "GRDBTests",
            dependencies: ["GRDB"],
            path: "Tests",
            exclude: [
                "CocoaPods",
                "Crash",
                "CustomSQLite",
                "GRDBTests/getThreadsCount.c",
                "Info.plist",
                "Performance",
                "SPM",
                "generatePerformanceReport.rb",
                "parsePerformanceTests.rb",
            ],
            resources: [
                .copy("GRDBTests/Betty.jpeg"),
                .copy("GRDBTests/InflectionsTests.json"),
                .copy("GRDBTests/Issue1383.sqlite"),
            ],
            cSettings: cSettings,
            swiftSettings: swiftSettings)
    ],
    swiftLanguageVersions: [.v5]
)
