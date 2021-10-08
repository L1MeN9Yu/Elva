//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation
@testable import LZ4
import XCTest

final class LZ4Tests: XCTestCase {
    func testMemory() throws {
        func lz4(content: Data, compressConfig: LZ4.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
            let compressMemory = BufferedMemoryStream()
            let compressConfig = LZ4.CompressConfig.default
            try LZ4.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            let decompressConfig = LZ4.DecompressConfig.default
            try LZ4.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try lz4(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFile() throws {
        func lz4(content: Data, compressConfig: LZ4.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "lz4_input")
            let compressFileURL = URL(fileURLWithPath: "lz4_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            let compressConfig = LZ4.CompressConfig.default
            try LZ4.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "lz4_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = LZ4.DecompressConfig.default
            try LZ4.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        try Self.compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try lz4(content: content, compressConfig: compressConfig)
            }
        }
    }
}

private extension LZ4Tests {
    static let compressConfigList: [LZ4.CompressConfig] = [
        LZ4.CompressConfig.default,
        LZ4.CompressConfig(bufferSize: 2),
        LZ4.CompressConfig(blockSize: .max256KB, blockMode: .independent, contentChecksum: .enabled, frameType: .skippableFrame, blockChecksum: .noChecksum, compressLevel: 0, autoFlush: true, favorDecompressSpeed: false),
        LZ4.CompressConfig(blockSize: .max1MB, blockMode: .linked, contentChecksum: .noChecksum, frameType: .frame, blockChecksum: .enabled, compressLevel: 1, autoFlush: false, favorDecompressSpeed: true),
        LZ4.CompressConfig(blockSize: .max4MB, blockMode: .independent, contentChecksum: .enabled, frameType: .skippableFrame, blockChecksum: .noChecksum, compressLevel: 2, autoFlush: true, favorDecompressSpeed: false),
    ]
}

private extension LZ4Tests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
