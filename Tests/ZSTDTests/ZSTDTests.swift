import Foundation
import XCTest
@testable import ZSTD

typealias Compression = ZSTD

final class ZSTDTests: XCTestCase {
    func testMemory() throws {
        func zstd(content: Data, compressConfig: Compression.CompressConfig) throws {
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
                try zstd(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFile() throws {
        func zstd(content: Data, compressConfig: Compression.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "zstd_input")
            let compressFileURL = URL(fileURLWithPath: "zstd_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try Compression.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = Compression.DecompressConfig.default
            try Compression.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try zstd(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testOptions() {
        func level() {
            XCTAssertNil(Compression.Level(rawValue: Compression.Level.max.rawValue + 1))
            XCTAssertNil(Compression.Level(rawValue: Compression.Level.min.rawValue - 1))
            XCTAssertNotNil(Compression.Level(rawValue: Compression.Level.RawValue.random(in: Compression.Level.min.rawValue...Compression.Level.max.rawValue)))
        }

        level()
    }

    func testMemoryHandler() throws {
        func zstd(content: Data, compressConfig: Compression.CompressConfig) throws {
            let compressedData = try Compression.memory.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.memory.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try zstd(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testGreedyHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let compressedData = try Compression.greedy.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.greedy.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }
}

private extension ZSTDTests {
    static let compressConfigList: [Compression.CompressConfig] = [
        Compression.CompressConfig.default,
        Compression.CompressConfig(bufferSize: 2),
        Compression.CompressConfig.zstd,
    ]
}

private extension ZSTDTests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
