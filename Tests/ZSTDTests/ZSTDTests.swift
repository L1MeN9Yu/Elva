import Foundation
import XCTest
@testable import ZSTD

final class ZSTDTests: XCTestCase {
    func testMemory() throws {
        func zstd(compressConfig: ZSTD.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: Self.content)
            let compressMemory = BufferedMemoryStream()
            try ZSTD.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            let decompressConfig = ZSTD.DecompressConfig.default
            try ZSTD.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        let compressConfigList: [ZSTD.CompressConfig] = [
            ZSTD.CompressConfig.default,
            ZSTD.CompressConfig(bufferSize: 2),
            ZSTD.CompressConfig.zstd,
        ]

        try compressConfigList.forEach {
            try zstd(compressConfig: $0)
        }
    }

    func testFile() throws {
        func zstd(compressConfig: ZSTD.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "zstd_input")
            let compressFileURL = URL(fileURLWithPath: "zstd_compress")
            try Self.content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try ZSTD.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = ZSTD.DecompressConfig.default
            try ZSTD.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), Self.content)
        }

        let compressConfigList: [ZSTD.CompressConfig] = [
            ZSTD.CompressConfig.default,
            ZSTD.CompressConfig(bufferSize: 2),
            ZSTD.CompressConfig.zstd,
        ]

        try compressConfigList.forEach {
            try zstd(compressConfig: $0)
        }
    }
}

private extension ZSTDTests {
    static let content = Data("the quick brown fox jumps over the lazy dog".utf8)
}
