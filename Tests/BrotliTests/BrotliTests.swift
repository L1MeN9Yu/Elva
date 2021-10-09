//
// Created by Mengyu Li on 2021/9/28.
//

@testable import Brotli
import Elva_Brotli
import Foundation
import XCTest

typealias Compression = Brotli

final class BrotliTests: XCTestCase {
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
            let inputFileURL = URL(fileURLWithPath: "brotli_input")
            let compressFileURL = URL(fileURLWithPath: "brotli_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try Compression.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "brotli_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
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

    func testOptions() {
        func inputBlockBits() {
            XCTAssertNil(Compression.InputBlockBits(rawValue: Compression.InputBlockBits.max.rawValue + 1))
            XCTAssertNil(Compression.InputBlockBits(rawValue: Compression.InputBlockBits.min.rawValue - 1))
            XCTAssertNotNil(Compression.InputBlockBits(rawValue: Compression.InputBlockBits.RawValue.random(in: Compression.InputBlockBits.min.rawValue...Compression.InputBlockBits.max.rawValue)))
        }

        inputBlockBits()

        func quality() {
            XCTAssertNil(Compression.Quality(rawValue: Compression.Quality.max.rawValue + 1))
            XCTAssertNil(Compression.Quality(rawValue: Compression.Quality.min.rawValue - 1))
            XCTAssertNotNil(Compression.Quality(rawValue: Compression.Quality.RawValue.random(in: Compression.Quality.min.rawValue...Compression.Quality.max.rawValue)))
        }

        quality()

        func windowBits() {
            XCTAssertNil(Compression.WindowBits(rawValue: Compression.WindowBits.max.rawValue + 1))
            XCTAssertNil(Compression.WindowBits(rawValue: Compression.WindowBits.min.rawValue - 1))
            XCTAssertNotNil(Compression.WindowBits(rawValue: Compression.WindowBits.RawValue.random(in: Compression.WindowBits.min.rawValue...Compression.WindowBits.max.rawValue)))
        }

        windowBits()

        func mode() {
            XCTAssertEqual(Compression.Mode.generic.value.rawValue, Compression.Mode.generic.rawValue)
            XCTAssertEqual(Compression.Mode.text.value.rawValue, Compression.Mode.text.rawValue)
            XCTAssertEqual(Compression.Mode.font.value.rawValue, Compression.Mode.font.rawValue)
        }

        mode()
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

private extension BrotliTests {
    static let compressConfigList: [Compression.CompressConfig] = [
        Compression.CompressConfig.default,
        Compression.CompressConfig(bufferSize: 2),
        Compression.CompressConfig(mode: .text, quality: .max, windowBits: .max, inputBlockBits: .default),
        Compression.CompressConfig(mode: .text, quality: .min, windowBits: .min, inputBlockBits: .min),
        Compression.CompressConfig(mode: .font, quality: .min, windowBits: .min, inputBlockBits: .max),
    ]
}

private extension BrotliTests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
