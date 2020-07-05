// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "Elva",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(name: "ZSTD",targets: ["ZSTD"]),
            .library(name: "Brotli",targets: ["Brotli"]),
            .library(name: "ZSTD.Static", type: .static, targets: ["ZSTD"]),
            .library(name: "Brotli.Static", type: .static, targets: ["Brotli"]),
            .library(name: "ZSTD.Dynamic", type: .dynamic, targets: ["ZSTD"]),
            .library(name: "Brotli.Dynamic", type: .dynamic, targets: ["Brotli"]),
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .target(name: "Elva.Brotli"),
            .target(name: "Elva.zstd"),
            .target(name: "Service"),
            .target(name: "ZSTD", dependencies: [.target(name: "Elva.zstd"), .target(name: "Service")]),
            .target(name: "Brotli", dependencies: [.target(name: "Elva.Brotli"), .target(name: "Service")]),
            .testTarget(name: "ElvaTests", dependencies: [.target(name: "ZSTD"),.target(name: "Brotli")]),
        ]
)
