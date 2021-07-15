@testable import Brotli
import Foundation
import XCTest
@testable import ZSTD

final class ElvaTests: XCTestCase {
    static let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15])

    func testBrotliFile() throws {
        let dataFileURL = URL(fileURLWithPath: "data")
        try Self.data.write(to: dataFileURL)
        let compressedFileURL = URL(fileURLWithPath: "data.br")
        try Brotli.compress(inputFile: dataFileURL, outputFile: compressedFileURL)
        let decompressFileURL = URL(fileURLWithPath: "data.br.decompressed")
        try Brotli.decompress(inputFile: compressedFileURL, outputFile: decompressFileURL)
        let decompressedData = try Data(contentsOf: decompressFileURL)
        XCTAssertEqual(decompressedData, Self.data)
        try FileManager.default.removeItem(at: dataFileURL)
        try FileManager.default.removeItem(at: compressedFileURL)
        try FileManager.default.removeItem(at: decompressFileURL)
    }

    func testBrotliData() throws {
        let compressedData = try Brotli.compress(data: Self.data)
        let data = try Brotli.decompress(data: compressedData)
        XCTAssertEqual(data, Self.data)
    }

    func testZSTDFile() throws {
        let dataFileURL = URL(fileURLWithPath: "data")
        try Self.data.write(to: dataFileURL)
        let compressedFileURL = URL(fileURLWithPath: "data.zstd")
        try ZSTD.compress(inputFile: dataFileURL, outputFile: compressedFileURL)
        let decompressFileURL = URL(fileURLWithPath: "data.zstd.decompressed")
        try ZSTD.decompress(inputFile: compressedFileURL, outputFile: decompressFileURL)
        let decompressedData = try Data(contentsOf: decompressFileURL)
        XCTAssertEqual(decompressedData, Self.data)
        try FileManager.default.removeItem(at: dataFileURL)
        try FileManager.default.removeItem(at: compressedFileURL)
        try FileManager.default.removeItem(at: decompressFileURL)
    }

    func testZSTDData() throws {
        let compressedData = try ZSTD.compress(data: Self.data)
        let data = try ZSTD.decompress(data: compressedData)
        XCTAssertEqual(data, Self.data)
    }

    static var allTests = [
        ("testBrotliFile", testBrotliFile),
        ("testBrotliData", testBrotliData),
        ("testZSTDFile", testZSTDFile),
        ("testZSTDData", testZSTDData),
    ]
}
