//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation
@testable import LZ4
import XCTest

final class LZ4Tests: XCTestCase {
    func testMemory() throws {
        let memoryInput = BufferedMemoryStream(startData: Self.content)
        let memoryOutput = BufferedMemoryStream()
        let compressConfig = LZ4.CompressConfig.default
        try LZ4.compress(reader: memoryInput, writer: memoryOutput, config: compressConfig)
        XCTAssertEqual(memoryOutput.size, Self.content.count + 15)
        let memoryDecompress = BufferedMemoryStream()
        let decompressConfig = LZ4.DecompressConfig.default
        try LZ4.decompress(reader: memoryOutput, writer: memoryDecompress, config: decompressConfig)
        XCTAssertEqual(memoryInput, memoryDecompress)
    }

    func testFile() throws {
        let inputFileURL = URL(fileURLWithPath: "input")
        let outputFileURL = URL(fileURLWithPath: "output")
        try Self.content.write(to: inputFileURL)
        let fileReadStream = FileReadStream(path: inputFileURL.path)
        let fileWriteStream = FileWriteStream(path: outputFileURL.path)
        let compressConfig = LZ4.CompressConfig.default
        try LZ4.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
        let decompressFileURL = URL(fileURLWithPath: "decompress")
        let compressedReaderStream = FileReadStream(path: outputFileURL.path)
        let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
        let decompressConfig = LZ4.DecompressConfig.default
        try LZ4.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
        try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
    }
}

private extension LZ4Tests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
