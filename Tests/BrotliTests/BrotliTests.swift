//
// Created by Mengyu Li on 2021/9/28.
//

@testable import Brotli
import Elva_Brotli
import Foundation
import XCTest

final class BrotliTests: XCTestCase {
    func testMemory() throws {
        func brotli(content: Data, compressConfig: Brotli.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
            let compressMemory = BufferedMemoryStream()
            try Brotli.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            let decompressConfig = Brotli.DecompressConfig.default
            try Brotli.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try brotli(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFile() throws {
        func brotli(content: Data, compressConfig: Brotli.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "brotli_input")
            let compressFileURL = URL(fileURLWithPath: "brotli_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try Brotli.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "brotli_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = Brotli.DecompressConfig.default
            try Brotli.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try brotli(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testOptions() {
        func inputBlockBits() {
            XCTAssertNil(Brotli.InputBlockBits(rawValue: Brotli.InputBlockBits.max.rawValue + 1))
            XCTAssertNil(Brotli.InputBlockBits(rawValue: Brotli.InputBlockBits.min.rawValue - 1))
            XCTAssertNotNil(Brotli.InputBlockBits(rawValue: Brotli.InputBlockBits.RawValue.random(in: Brotli.InputBlockBits.min.rawValue...Brotli.InputBlockBits.max.rawValue)))
        }

        inputBlockBits()

        func quality() {
            XCTAssertNil(Brotli.Quality(rawValue: Brotli.Quality.max.rawValue + 1))
            XCTAssertNil(Brotli.Quality(rawValue: Brotli.Quality.min.rawValue - 1))
            XCTAssertNotNil(Brotli.Quality(rawValue: Brotli.Quality.RawValue.random(in: Brotli.Quality.min.rawValue...Brotli.Quality.max.rawValue)))
        }

        quality()

        func windowBits() {
            XCTAssertNil(Brotli.WindowBits(rawValue: Brotli.WindowBits.max.rawValue + 1))
            XCTAssertNil(Brotli.WindowBits(rawValue: Brotli.WindowBits.min.rawValue - 1))
            XCTAssertNotNil(Brotli.WindowBits(rawValue: Brotli.WindowBits.RawValue.random(in: Brotli.WindowBits.min.rawValue...Brotli.WindowBits.max.rawValue)))
        }

        windowBits()

        func mode() {
            XCTAssertEqual(Brotli.Mode.generic.value.rawValue, Brotli.Mode.generic.rawValue)
            XCTAssertEqual(Brotli.Mode.text.value.rawValue, Brotli.Mode.text.rawValue)
            XCTAssertEqual(Brotli.Mode.font.value.rawValue, Brotli.Mode.font.rawValue)
        }

        mode()
    }

    func testMemoryHandler() throws {
        func brotli(content: Data, compressConfig: Brotli.CompressConfig) throws {
            let compressedData = try Brotli.memory.compress(data: content, config: compressConfig)
            let decompressedData = try Brotli.memory.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try brotli(content: content, compressConfig: compressConfig)
            }
        }
    }
}

private extension BrotliTests {
    static let compressConfigList: [Brotli.CompressConfig] = [
        Brotli.CompressConfig.default,
        Brotli.CompressConfig(bufferSize: 2),
        Brotli.CompressConfig(mode: .text, quality: .max, windowBits: .max, inputBlockBits: .default),
        Brotli.CompressConfig(mode: .text, quality: .min, windowBits: .min, inputBlockBits: .min),
        Brotli.CompressConfig(mode: .font, quality: .min, windowBits: .min, inputBlockBits: .max),
    ]
}

private extension BrotliTests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
