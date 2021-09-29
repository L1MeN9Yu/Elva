//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation
@testable import LZ4
import XCTest

final class LZ4Tests: XCTestCase {
    func testMemory() throws {
        let inputMemory = BufferedMemoryStream(startData: Self.content)
        let compressMemory = BufferedMemoryStream()
        let compressConfig = LZ4.CompressConfig.default
        try LZ4.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
        XCTAssertEqual(compressMemory.size, Self.content.count + 15)
        let decompressMemory = BufferedMemoryStream()
        let decompressConfig = LZ4.DecompressConfig.default
        try LZ4.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
        XCTAssertEqual(inputMemory, decompressMemory)
    }

    func testFile() throws {
        let inputFileURL = URL(fileURLWithPath: "lz4_input")
        let compressFileURL = URL(fileURLWithPath: "lz4_compress")
        try Self.content.write(to: inputFileURL)
        let fileReadStream = FileReadStream(path: inputFileURL.path)
        let fileWriteStream = FileWriteStream(path: compressFileURL.path)
        let compressConfig = LZ4.CompressConfig.default
        try LZ4.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
        let decompressFileURL = URL(fileURLWithPath: "lz4_decompress")
        let compressedReaderStream = FileReadStream(path: compressFileURL.path)
        let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
        let decompressConfig = LZ4.DecompressConfig.default
        try LZ4.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
        try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
    }
}

private extension LZ4Tests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
