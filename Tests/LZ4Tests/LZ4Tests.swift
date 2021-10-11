//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation
@testable import LZ4
import XCTest

typealias Compression = LZ4

final class LZ4Tests: XCTestCase {
    func testMemory() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
            let compressMemory = BufferedMemoryStream()
            try Compression.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            let decompressConfig = Compression.DecompressConfig.default
            try Compression.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFile() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "lz4_input")
            let compressFileURL = URL(fileURLWithPath: "lz4_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = try FileReadStream(path: inputFileURL.path)
            let fileWriteStream = try FileWriteStream(path: compressFileURL.path)
            try Compression.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "lz4_decompress")
            let compressedReaderStream = try FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = try FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = Compression.DecompressConfig.default
            try Compression.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testMemoryHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let compressedData = try Compression.memory.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.memory.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testGreedyHandler() {
        let inputMemory = BufferedMemoryStream()
        let outputMemory = BufferedMemoryStream()
        try XCTAssertThrowsError(Compression.compress(greedy: inputMemory, writer: outputMemory, config: .default))
        try XCTAssertThrowsError(Compression.decompress(greedy: inputMemory, writer: outputMemory, config: .default))
    }

    func testFileHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "lz4_input")
            let compressFileURL = URL(fileURLWithPath: "lz4_compress")
            let decompressFileURL = URL(fileURLWithPath: "lz4_decompress")
            try content.write(to: inputFileURL)
            try Compression.file.compress(inputFileURL: inputFileURL, outputFileURL: compressFileURL, config: compressConfig)
            try Compression.file.decompress(inputFileURL: compressFileURL, outputFileURL: decompressFileURL)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }
}

private extension LZ4Tests {
    static let compressConfigList: [Compression.CompressConfig] = [
        Compression.CompressConfig.default,
        Compression.CompressConfig(bufferSize: 2),
        Compression.CompressConfig(blockSize: .max256KB, blockMode: .independent, contentChecksum: .enabled, frameType: .skippableFrame, blockChecksum: .noChecksum, compressLevel: 0, autoFlush: true, favorDecompressSpeed: false),
        Compression.CompressConfig(blockSize: .max1MB, blockMode: .linked, contentChecksum: .noChecksum, frameType: .frame, blockChecksum: .enabled, compressLevel: 1, autoFlush: false, favorDecompressSpeed: true),
        Compression.CompressConfig(blockSize: .max4MB, blockMode: .independent, contentChecksum: .enabled, frameType: .skippableFrame, blockChecksum: .noChecksum, compressLevel: 2, autoFlush: true, favorDecompressSpeed: false),
    ]
}

private extension LZ4Tests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
