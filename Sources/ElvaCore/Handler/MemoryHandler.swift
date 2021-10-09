//
// Created by Mengyu Li on 2021/10/9.
//

import Foundation

public struct MemoryHandler<Compression: CompressionCapable> {
    public let compression: Compression.Type

    public init(compression: Compression.Type) {
        self.compression = compression
    }
}

public extension MemoryHandler {
    func compress(data: Data, config: Compression.CompressConfig) throws -> Data {
        let inputMemory = BufferedMemoryStream(startData: data)
        let compressMemory = BufferedMemoryStream()
        try compression.compress(reader: inputMemory, writer: compressMemory, config: config)
        return compressMemory.representation
    }

    func decompress(data: Data, config: Compression.DecompressConfig) throws -> Data {
        let inputMemory = BufferedMemoryStream(startData: data)
        let decompressMemory = BufferedMemoryStream()
        try compression.decompress(reader: inputMemory, writer: decompressMemory, config: config)
        return decompressMemory.representation
    }
}
