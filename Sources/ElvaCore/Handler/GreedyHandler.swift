//
// Created by Mengyu Li on 2021/10/9.
//

import Foundation

public struct GreedyHandler<Compression: CompressionCapable> {
    public let compression: Compression.Type

    public init(compression: Compression.Type) {
        self.compression = compression
    }
}

public extension GreedyHandler {
    func compress(data: Data, config: Compression.CompressConfig = .default) throws -> Data {
        let inputMemory = BufferedMemoryStream(startData: data)
        let compressMemory = BufferedMemoryStream()
        try compression.compress(greedy: inputMemory, writer: compressMemory, config: config)
        return compressMemory.representation
    }

    func decompress(data: Data, config: Compression.DecompressConfig = .default) throws -> Data {
        let inputMemory = BufferedMemoryStream(startData: data)
        let decompressMemory = BufferedMemoryStream()
        try compression.decompress(greedy: inputMemory, writer: decompressMemory, config: config)
        return decompressMemory.representation
    }
}
