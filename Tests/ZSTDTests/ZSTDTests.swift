import Foundation
import XCTest
@testable import ZSTD

final class ZSTDTests: XCTestCase {
    func testMemory() throws {
        func zstd(content: Data, compressConfig: ZSTD.CompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
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

        try compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try zstd(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFile() throws {
        func zstd(content: Data, compressConfig: ZSTD.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "zstd_input")
            let compressFileURL = URL(fileURLWithPath: "zstd_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = FileReadStream(path: inputFileURL.path)
            let fileWriteStream = FileWriteStream(path: compressFileURL.path)
            try ZSTD.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
            let compressedReaderStream = FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = FileWriteStream(path: decompressFileURL.path)
            let decompressConfig = ZSTD.DecompressConfig.default
            try ZSTD.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        let compressConfigList: [ZSTD.CompressConfig] = [
            ZSTD.CompressConfig.default,
            ZSTD.CompressConfig(bufferSize: 2),
            ZSTD.CompressConfig.zstd,
        ]

        try compressConfigList.forEach { compressConfig in
            try Self.contents.forEach { content in
                try zstd(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testOptions() {
        func level() {
            XCTAssertNil(ZSTD.Level(rawValue: ZSTD.Level.max.rawValue + 1))
            XCTAssertNil(ZSTD.Level(rawValue: ZSTD.Level.min.rawValue - 1))
            XCTAssertNotNil(ZSTD.Level(rawValue: ZSTD.Level.RawValue.random(in: ZSTD.Level.min.rawValue...ZSTD.Level.max.rawValue)))
        }

        level()
    }
}

private extension ZSTDTests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]
}
