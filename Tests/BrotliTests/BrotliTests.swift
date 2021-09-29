//
// Created by Mengyu Li on 2021/9/28.
//

@testable import Brotli
import Foundation
import XCTest

final class BrotliTests: XCTestCase {
    func testBrotliMemory() throws {
        let originalData = Self.content
        let compressed: Data = try Brotli.compress(data: originalData)
        let decompressed: Data = try Brotli.decompress(data: compressed)
        XCTAssertEqual(originalData, decompressed)
    }

    func testBrotliFile() throws {
        let inputFileURL = URL(fileURLWithPath: "brotli_input")
        let compressFileURL = URL(fileURLWithPath: "brotli_compress")
        let decompressFileURL = URL(fileURLWithPath: "brotli_decompress")
        try Self.content.write(to: inputFileURL)
        try Brotli.compress(inputFile: inputFileURL, outputFile: compressFileURL)
        try Brotli.decompress(inputFile: compressFileURL, outputFile: decompressFileURL)
        try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
    }
}

private extension BrotliTests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
