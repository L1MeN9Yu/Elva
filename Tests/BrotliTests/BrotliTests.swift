//
// Created by Mengyu Li on 2021/9/28.
//

@testable import Brotli
import Foundation
import XCTest

final class BrotliTests: XCTestCase {
    func testMemory() throws {
        func brotli(compressConfig: Brotli.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: Self.content)
            let compressMemory = BufferedMemoryStream()
            try Brotli.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            let decompressConfig = Brotli.DecompressConfig.default
            try Brotli.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        try Self.compressConfigList.forEach {
            try brotli(compressConfig: $0)
        }
    }

    func testFile() throws {
        func brotli(compressConfig: Brotli.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "brotli_input")
            let compressFileURL = URL(fileURLWithPath: "brotli_compress")
            try Self.content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try Brotli.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "brotli_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = Brotli.DecompressConfig.default
            try Brotli.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
        }

        try Self.compressConfigList.forEach {
            try brotli(compressConfig: $0)
        }
    }
}

private extension BrotliTests {
    static let compressConfigList: [Brotli.CompressConfig] = [
        Brotli.CompressConfig.default,
        Brotli.CompressConfig(bufferSize: 2),
        Brotli.CompressConfig(mode: .text, quality: .max, windowBits: .max, inputBlockBits: .default),
        Brotli.CompressConfig(mode: .text, quality: .min, windowBits: .min, inputBlockBits: .min),
        Brotli.CompressConfig(mode: .text, quality: .min, windowBits: .min, inputBlockBits: .max),
    ]
}

private extension BrotliTests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
