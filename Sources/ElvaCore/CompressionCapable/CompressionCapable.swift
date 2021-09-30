//
// Created by Mengyu Li on 2021/9/28.
//

public protocol CompressionCapable {
    associatedtype CompressConfig: CompressConfigurable
    associatedtype DecompressConfig: DecompressConfigurable
    static func compress(reader: ReadableStream, writer: WriteableStream, config: CompressConfig) throws
    static func decompress(reader: ReadableStream, writer: WriteableStream, config: DecompressConfig) throws
}

public protocol CompressConfigurable {
    var bufferSize: Int { get }
    var autoCloseReadStream: Bool { get }
    var autoCloseWriteStream: Bool { get }
}

public protocol DecompressConfigurable {
    var bufferSize: Int { get }
    var autoCloseReadStream: Bool { get }
    var autoCloseWriteStream: Bool { get }
}
