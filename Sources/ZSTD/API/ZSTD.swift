//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_zstd
import Foundation

public enum ZSTD {}

extension ZSTD: CompressionCapable {
    public typealias CompressConfig = CompressOption
    public typealias DecompressConfig = DecompressOption

    public static func compress(reader: ReadableStream, writer: WriteableStream, config: CompressConfig) throws {
        let bufferSize: Int = config.bufferSize
        let inputBufferSize: Int = config.inputBufferSize ?? bufferSize
        let outputBufferSize: Int = config.outputBufferSize ?? bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        let context: CompressContext = try CompressContext()
        try context.set(level: config.level)
        if let dictionary: Dictionary = config.dictionary {
            try context.load(dictionary: dictionary)
        }

        func writeCompress() throws {
            while true {
                let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: inputBufferSize)
                defer { readBuffer.deallocate() }
                let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: outputBufferSize)
                defer { writeBuffer.deallocate() }

                let read: Int = reader.read(readBuffer, length: inputBufferSize)
                let lastChunk: Bool = read < inputBufferSize

                let mode: ZSTD_EndDirective = lastChunk ? ZSTD_e_end : ZSTD_e_continue
                var input: ZSTD_inBuffer_s = ZSTD_inBuffer(src: readBuffer, size: read, pos: 0)
                var finished: Bool = false
                while !finished {
                    var output: ZSTD_outBuffer_s = ZSTD_outBuffer(dst: writeBuffer, size: outputBufferSize, pos: 0)
                    let remaining: Int = ZSTD_compressStream2(context.pointer, &output, &input, mode)
                    if Error.isError(remaining) { throw Error.compress }
                    let written: Int = writer.write(writeBuffer, length: output.pos)
                    guard written == output.pos else {
                        throw Error.write(expect: output.pos, written: written)
                    }
                    finished = lastChunk ? (remaining == 0) : (input.pos == input.size)
                }

                if input.pos != input.size { throw Error.compress }

                if lastChunk { break }
            }
        }

        try writeCompress()
    }

    public static func decompress(reader: ReadableStream, writer: WriteableStream, config: DecompressConfig) throws {
        let bufferSize: Int = config.bufferSize
        let inputBufferSize: Int = config.inputBufferSize ?? bufferSize
        let outputBufferSize: Int = config.outputBufferSize ?? bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        let context: DecompressContext = try DecompressContext()
        try context.set(parameters: config.parameters)
        if let dictionary: Dictionary = config.dictionary {
            try context.load(dictionary: dictionary)
        }

        func writeDecompress() throws {
            var read = 0
            var decompressResult = 0

            repeat {
                let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: inputBufferSize)
                defer { readBuffer.deallocate() }
                let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: outputBufferSize)
                defer { writeBuffer.deallocate() }

                read = reader.read(readBuffer, length: inputBufferSize)
                var input: ZSTD_inBuffer_s = ZSTD_inBuffer(src: readBuffer, size: read, pos: 0)

                while input.pos < input.size {
                    var output: ZSTD_outBuffer_s = ZSTD_outBuffer(dst: writeBuffer, size: outputBufferSize, pos: 0)
                    decompressResult = ZSTD_decompressStream(context.pointer, &output, &input)
                    if Error.isError(decompressResult) { throw Error.decompress }

                    let written: Int = writer.write(writeBuffer, length: output.pos)
                    guard written == output.pos else {
                        throw Error.write(expect: output.pos, written: written)
                    }
                }
            } while read > 0
        }

        try writeDecompress()
    }

    public static func compress(greedy: GreedyStream, writer: WriteableStream, config: CompressConfig) throws {
        let inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: greedy.size)
        let read: Int = greedy.readAll(inputBuffer)
        let inputBufferSize: Int = read
        let outputBufferSize: Int = ZSTD_compressBound(inputBufferSize)
        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferSize)
        defer { outputBuffer.deallocate() }

        let context: CompressContext = try CompressContext()
        try context.set(level: config.level)

        if let dictionary: Dictionary = config.dictionary {
            try context.load(dictionary: dictionary)
        }

        let compressResult: Int = ZSTD_compress2(context.pointer, outputBuffer, outputBufferSize, inputBuffer, inputBufferSize)
        guard ZSTD_isError(compressResult) == 0 else { throw Error.compress }

        let written: Int = writer.write(outputBuffer, length: compressResult)
        guard written == compressResult else { throw Error.write(expect: compressResult, written: written) }
    }

    public static func decompress(greedy: GreedyStream, writer: WriteableStream, config: DecompressConfig) throws {
        let inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: greedy.size)
        let read: Int = greedy.readAll(inputBuffer)
        let inputBufferSize: Int = read
        let outBufferLongLongSize: UInt64 = ZSTD_getFrameContentSize(UnsafeRawPointer(inputBuffer), inputBufferSize)

        guard outBufferLongLongSize <= Int.max else { throw Error.invalidData }
        let outputBufferSize = Int(outBufferLongLongSize)

        guard outputBufferSize != ZSTD_CONTENTSIZE_ERROR else { throw Error.invalidData }
        guard outputBufferSize != ZSTD_CONTENTSIZE_UNKNOWN else { throw Error.invalidData }

        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferSize)
        defer { outputBuffer.deallocate() }

        let context: DecompressContext = try DecompressContext()
        try context.set(parameters: config.parameters)

        if let dictionary: Dictionary = config.dictionary {
            try context.load(dictionary: dictionary)
        }

        let decompressResult: Int = ZSTD_decompressDCtx(context.pointer, outputBuffer, outputBufferSize, inputBuffer, inputBufferSize)
        guard ZSTD_isError(decompressResult) == 0 else { throw Error.decompress }
        guard decompressResult == outputBufferSize else { throw Error.decompress }

        let written: Int = writer.write(outputBuffer, length: outputBufferSize)
        guard written == outputBufferSize else {
            throw Error.write(expect: outputBufferSize, written: written)
        }
    }
}
