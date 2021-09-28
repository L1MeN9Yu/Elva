// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Elva",
    products: [
        .library(name: "ZSTD", targets: ["ZSTD"]),
        .library(name: "Brotli", targets: ["Brotli"]),
    ],
    targets: [
        .target(name: "Elva.lz4", cSettings: [.define("XXH_NAMESPACE", to: "Elva_lz4_")]),
        .target(name: "LZ4", dependencies: [.target(name: "Elva.lz4"), .target(name: "ElvaCore")]),
        .testTarget(name: "LZ4Tests", dependencies: [.target(name: "LZ4")]),

        .target(name: "Elva.zstd", cSettings: [.define("XXH_NAMESPACE", to: "Elva_zstd_")]),
        .target(name: "ZSTD", dependencies: [.target(name: "Elva.zstd"), .target(name: "ElvaCore")]),
        .testTarget(name: "ZSTDTests", dependencies: [.target(name: "ZSTD")]),

        .target(name: "Elva.Brotli"),
        .target(name: "Brotli", dependencies: [.target(name: "Elva.Brotli"), .target(name: "ElvaCore")]),
        .testTarget(name: "BrotliTests", dependencies: [.target(name: "Brotli")]),

        .target(name: "ElvaCore"),
        .testTarget(name: "ElvaCoreTests", dependencies: [.target(name: "ElvaCore")]),
    ]
)
