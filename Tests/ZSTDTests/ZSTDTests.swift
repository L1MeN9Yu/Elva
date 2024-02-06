import Elva_zstd
import Foundation
import XCTest
@testable import ZSTD

typealias Compression = ZSTD
typealias Decompression = ZSTD

final class ZSTDTests: XCTestCase {
    func testMemory() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig, decompressConfig: Decompression.DecompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
            let compressMemory = BufferedMemoryStream()
            try Compression.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            try Compression.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        for compressConfig in Self.compressConfigList {
            for decompressConfig in Self.decompressConfigList {
                for content in Self.contents {
                    try run(content: content, compressConfig: compressConfig, decompressConfig: decompressConfig)
                }
            }
        }
    }

    func testFile() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig, decompressConfig: Decompression.DecompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "zstd_input")
            let compressFileURL = URL(fileURLWithPath: "zstd_compress")
            try content.write(to: inputFileURL)
            let fileReadStream = try FileReadStream(path: inputFileURL.path)
            let fileWriteStream = try FileWriteStream(path: compressFileURL.path)
            try Compression.compress(reader: fileReadStream, writer: fileWriteStream, config: compressConfig)
            let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
            let compressedReaderStream = try FileReadStream(path: compressFileURL.path)
            let decompressWriterStream = try FileWriteStream(path: decompressFileURL.path)
            try Compression.decompress(reader: compressedReaderStream, writer: decompressWriterStream, config: decompressConfig)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        for compressConfig in Self.compressConfigList {
            for decompressConfig in Self.decompressConfigList {
                for content in Self.contents {
                    try run(content: content, compressConfig: compressConfig, decompressConfig: decompressConfig)
                }
            }
        }
    }

    func testOptions() {
        func level() {
            XCTAssertNil(Compression.Level(rawValue: Compression.Level.max.rawValue + 1))
            XCTAssertNil(Compression.Level(rawValue: Compression.Level.min.rawValue - 1))
            XCTAssertNotNil(Compression.Level(rawValue: Compression.Level.RawValue.random(in: Compression.Level.min.rawValue...Compression.Level.max.rawValue)))
        }

        level()
    }

    func testMemoryHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let compressedData = try Compression.memory.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.memory.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        for compressConfig in Self.compressConfigList {
            for content in Self.contents {
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testGreedyHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let compressedData = try Compression.greedy.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.greedy.decompress(data: compressedData, config: .default)
            XCTAssertEqual(decompressedData, content)
        }

        for compressConfig in Self.compressConfigList {
            for content in Self.contents {
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testFileHandler() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig) throws {
            let inputFileURL = URL(fileURLWithPath: "zstd_input")
            let compressFileURL = URL(fileURLWithPath: "zstd_compress")
            let decompressFileURL = URL(fileURLWithPath: "zstd_decompress")
            try content.write(to: inputFileURL)
            try Compression.file.compress(inputFileURL: inputFileURL, outputFileURL: compressFileURL, config: compressConfig)
            try Compression.file.decompress(inputFileURL: compressFileURL, outputFileURL: decompressFileURL)
            try XCTAssertEqual(Data(contentsOf: decompressFileURL), content)
        }

        for compressConfig in Self.compressConfigList {
            for content in Self.contents {
                try run(content: content, compressConfig: compressConfig)
            }
        }
    }

    func testDictionary() throws {
        func run(content: Data, compressConfig: Compression.CompressConfig, decompressConfig: Decompression.DecompressConfig) throws {
            let inputMemory = BufferedMemoryStream(startData: content)
            let compressMemory = BufferedMemoryStream()
            try Compression.compress(reader: inputMemory, writer: compressMemory, config: compressConfig)
            let decompressMemory = BufferedMemoryStream()
            try Compression.decompress(reader: compressMemory, writer: decompressMemory, config: decompressConfig)
            XCTAssertEqual(inputMemory, decompressMemory)
        }

        func runGreedy(content: Data, compressConfig: Compression.CompressConfig, decompressConfig: Decompression.DecompressConfig) throws {
            let compressedData = try Compression.greedy.compress(data: content, config: compressConfig)
            let decompressedData = try Compression.greedy.decompress(data: compressedData, config: decompressConfig)
            XCTAssertEqual(decompressedData, content)
        }

        for (compressConfig, decompressConfig) in Self.dictionaryConfigs {
            for content in Self.contents {
                try run(content: content, compressConfig: compressConfig, decompressConfig: decompressConfig)
                try runGreedy(content: content, compressConfig: compressConfig, decompressConfig: decompressConfig)
            }
        }
    }

    func testErrors() {
        let errors: [ZSTD_ErrorCode] = [
            ZSTD_error_no_error,
            ZSTD_error_GENERIC,
            ZSTD_error_prefix_unknown,
            ZSTD_error_version_unsupported,
            ZSTD_error_frameParameter_unsupported,
            ZSTD_error_frameParameter_windowTooLarge,
            ZSTD_error_corruption_detected,
            ZSTD_error_checksum_wrong,
            ZSTD_error_literals_headerWrong,
            ZSTD_error_dictionary_corrupted,
            ZSTD_error_dictionary_wrong,
            ZSTD_error_dictionaryCreation_failed,
            ZSTD_error_parameter_unsupported,
            ZSTD_error_parameter_combination_unsupported,
            ZSTD_error_parameter_outOfBound,
            ZSTD_error_tableLog_tooLarge,
            ZSTD_error_maxSymbolValue_tooLarge,
            ZSTD_error_maxSymbolValue_tooSmall,
            ZSTD_error_stabilityCondition_notRespected,
            ZSTD_error_stage_wrong,
            ZSTD_error_init_missing,
            ZSTD_error_memory_allocation,
            ZSTD_error_workSpace_tooSmall,
            ZSTD_error_dstSize_tooSmall,
            ZSTD_error_srcSize_wrong,
            ZSTD_error_dstBuffer_null,
            ZSTD_error_noForwardProgress_destFull,
            ZSTD_error_noForwardProgress_inputEmpty,
            ZSTD_error_frameIndex_tooLarge,
            ZSTD_error_seekableIO,
            ZSTD_error_dstBuffer_wrong,
            ZSTD_error_srcBuffer_wrong,
            ZSTD_error_sequenceProducer_failed,
            ZSTD_error_externalSequences_invalid,
            ZSTD_error_maxCode,
        ]
        for errorCode in errors {
            let code = -Int(errorCode.rawValue)
            let errorName = ZSTD.Error.errorName(code: code)
            print("\(code): \(errorName ?? "nil")")
            XCTAssertNotNil(errorName)
        }
    }
}

private extension ZSTDTests {
    static let compressConfigList: [Compression.CompressConfig] = [
        Compression.CompressConfig.default,
        Compression.CompressConfig(bufferSize: 2),
        Compression.CompressConfig.zstd,
    ]

    static let decompressConfigList: [Decompression.DecompressConfig] = [
        Decompression.DecompressConfig.default,
        Decompression.DecompressConfig(bufferSize: 2),
        Decompression.DecompressConfig.zstd,
        Decompression.DecompressConfig(parameters: [.windowLogMax(31)]),
    ]
}

private extension ZSTDTests {
    static let contents: [Data] = [
        Data("the quick brown fox jumps over the lazy dog".utf8),
        Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) }),
    ]

    static let dictionaryConfigs: [(Compression.CompressConfig, Decompression.DecompressConfig)] = {
        let dictionaries: [ZSTD.Dictionary] = [
            ZSTD.Dictionary("the quick brown fox jumps over the lazy dog"),
            ZSTD.Dictionary(data: Data((0..<(1 << 12)).map { _ in UInt8.random(in: UInt8.min..<UInt8.max) })),
        ]

        return dictionaries.map { dictionary in
            (
                Compression.CompressConfig(dictionary: dictionary),
                Decompression.DecompressConfig(dictionary: dictionary)
            )
        }
    }()
}
