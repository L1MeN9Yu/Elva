//
// Created by Mengyu Li on 2021/10/11.
//

import Foundation

public struct FileHandler<Compression: CompressionCapable> {
    public let compression: Compression.Type

    public init(compression: Compression.Type) {
        self.compression = compression
    }
}

public extension FileHandler {
    func compress(inputFileURL: URL, outputFileURL: URL, config: Compression.CompressConfig = .default) throws {
        let fileReadStream = try FileReadStream(path: inputFileURL.path)
        let fileWriteStream = try FileWriteStream(path: outputFileURL.path)
        try Compression.compress(reader: fileReadStream, writer: fileWriteStream, config: config)
    }

    func decompress(inputFileURL: URL, outputFileURL: URL, config: Compression.DecompressConfig = .default) throws {
        let fileReadStream = try FileReadStream(path: inputFileURL.path)
        let fileWriteStream = try FileWriteStream(path: outputFileURL.path)
        try Compression.decompress(reader: fileReadStream, writer: fileWriteStream, config: config)
    }
}
