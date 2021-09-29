import Foundation
import XCTest
@testable import ZSTD

final class ZSTDTests: XCTestCase {
    func testZSTDMemory() throws {
        let originalData = Self.content
        let compressed: Data = try ZSTD.compress(data: originalData)
        let decompressed: Data = try ZSTD.decompress(data: compressed)
        XCTAssertEqual(originalData, decompressed)
    }

    func testZSTDFile() throws {
        let inputFileURL = URL(fileURLWithPath: "zstd_input")
        let compressFileURL = URL(fileURLWithPath: "zstd_compress")
        let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
        try Self.content.write(to: inputFileURL)
        try ZSTD.compress(inputFile: inputFileURL, outputFile: compressFileURL)
        try ZSTD.decompress(inputFile: compressFileURL, outputFile: decompressFileURL)
        try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
    }
}

private extension ZSTDTests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
