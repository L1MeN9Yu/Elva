# Elva

The `Compression` Kit.

## Status

[![Build](https://github.com/L1MeN9Yu/Elva/actions/workflows/CI.yml/badge.svg)](https://github.com/L1MeN9Yu/Elva/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/L1MeN9Yu/Elva/branch/main/graph/badge.svg?token=F130M1LL3L)](https://codecov.io/gh/L1MeN9Yu/Elva)

## Using Elva in your project

To use this package in a SwiftPM project, you need to set it up as a package dependency:

```swift
// swift-tools-version:5.4
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(
      url: "https://github.com/L1MeN9Yu/Elva.git", from: "2.0.0" // or `.upToNextMajor
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "ZSTD", package: "Elva"),// ZSTD
        .product(name: "Brotli", package: "Elva"),// Brotli
        .product(name: "LZ4", package: "Elva"),// LZ4
      ]
    )
  ]
)

```

## Modules

### ZSTD

[zstd](https://github.com/facebook/zstd.git) Swift wrapper.

#### Usage

1. Compress

```swift
import ZSTD

let compressConfig = ZSTD.CompressConfig.default
let data = Data()
let inputMemory = BufferedMemoryStream(startData: data)
let compressMemory = BufferedMemoryStream()
try ZSTD.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
let compressedData = compressMemory.representation
```

2. Decompress

```swift
import ZSTD

let decompressConfig = ZSTD.DecompressConfig.default
let data = ...
let inputMemory = BufferedMemoryStream(startData: data)
let decompressMemory = BufferedMemoryStream()
try ZSTD.decompress(reader: inputMemory, writer: decompressMemory, config: compressConfig)
let decompressedData = decompressMemory.representation
```

### Brotli

[brotli](https://github.com/google/brotli.git) Swift wrapper.

#### Usage

1. Compress

```swift
import Brotli

let compressConfig = Brotli.CompressConfig.default
let data = Data()
let inputMemory = BufferedMemoryStream(startData: data)
let compressMemory = BufferedMemoryStream()
try Brotli.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
let compressedData = compressMemory.representation
```

2. Decompress

```swift
import Brotli

let decompressConfig = Brotli.DecompressConfig.default
let data = ...
let inputMemory = BufferedMemoryStream(startData: data)
let decompressMemory = BufferedMemoryStream()
try Brotli.decompress(reader: inputMemory, writer: decompressMemory, config: compressConfig)
let decompressedData = decompressMemory.representation
```

### LZ4

[LZ4](https://github.com/lz4/lz4.git) Swift wrapper.

#### Usage

1. Compress

```swift
import LZ4

let compressConfig = LZ4.CompressConfig.default
let data = Data()
let inputMemory = BufferedMemoryStream(startData: data)
let compressMemory = BufferedMemoryStream()
try LZ4.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
let compressedData = compressMemory.representation
```

2. Decompress

```swift
import LZ4

let decompressConfig = LZ4.DecompressConfig.default
let data = ...
let inputMemory = BufferedMemoryStream(startData: data)
let decompressMemory = BufferedMemoryStream()
try LZ4.decompress(reader: inputMemory, writer: decompressMemory, config: compressConfig)
let decompressedData = decompressMemory.representation
```

## Contribution

1. `brew bundle` to install `pre-commit` , `swiftformat` , `swiftlint`
2. `pre-commit install` to install git hook.

## Thanks | 鸣谢

Thanks to [JetBrains][JetBrains] for "Licenses for Open Source Development". [JetBrains][JetBrains] supports non-commercial open source projects by providing core project contributors with a set of best-in-class developer tools free of charge.

感谢 [JetBrains][JetBrains] 提供的开源开发许可证。[JetBrains][JetBrains] 通过为项目核心开发者免费提供开发工具来支持非商业开源项目。

[JetBrains]: https://www.jetbrains.com/?from=Elva
