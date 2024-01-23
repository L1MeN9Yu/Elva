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
        let bufferSize = config.bufferSize
        let inputBufferSize = config.inputBufferSize ?? bufferSize
        let outputBufferSize = config.outputBufferSize ?? bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        func createContext() throws -> OpaquePointer {
            guard let compressContext: OpaquePointer = ZSTD_createCCtx() else { throw Error.encoderCreate }
            guard ZSTD_isError(ZSTD_CCtx_setParameter(compressContext, ZSTD_c_compressionLevel, config.level.rawValue)) == 0 else { throw Error.encoderCreate }
            guard ZSTD_isError(ZSTD_CCtx_setParameter(compressContext, ZSTD_c_checksumFlag, 1)) == 0 else { throw Error.encoderCreate }
            return compressContext
        }

        let compressContext = try createContext()
        defer { ZSTD_freeCCtx(compressContext) }

        func writeCompress() throws {
            while true {
                let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: inputBufferSize)
                defer { readBuffer.deallocate() }
                let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: outputBufferSize)
                defer { writeBuffer.deallocate() }

                let read = reader.read(readBuffer, length: inputBufferSize)
                let lastChunk = read < inputBufferSize
                let mode: ZSTD_EndDirective = lastChunk ? ZSTD_e_end : ZSTD_e_continue
                var input = ZSTD_inBuffer(src: readBuffer, size: read, pos: 0)
                var finished = false
                while !finished {
                    var output = ZSTD_outBuffer(dst: writeBuffer, size: outputBufferSize, pos: 0)
                    let remaining = ZSTD_compressStream2(compressContext, &output, &input, mode)
                    guard ZSTD_isError(remaining) == 0 else { throw Error.compress }
                    let written = writer.write(writeBuffer, length: output.pos)
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
        let bufferSize = config.bufferSize
        let inputBufferSize = config.inputBufferSize ?? bufferSize
        let outputBufferSize = config.outputBufferSize ?? bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        func createContext() throws -> OpaquePointer {
            guard let decompressContext = ZSTD_createDCtx() else { throw Error.decoderCreate }
            return decompressContext
        }

        let decompressContext = try createContext()
        defer { ZSTD_freeDCtx(decompressContext) }

        func setParameters() throws {
            try config.parameters.forEach { parameter in
                switch parameter {
                case let .windowLogMax(value):
                    let resultCode: Int = ZSTD_DCtx_setParameter(decompressContext, ZSTD_d_windowLogMax, value)
                    guard ZSTD_isError(resultCode) == 0 else { throw Error.setParameter }
                }
            }
        }

        try setParameters()

        func writeDecompress() throws {
            var read = 0
            var decompressResult = 0

            repeat {
                let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: inputBufferSize)
                defer { readBuffer.deallocate() }
                let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: outputBufferSize)
                defer { writeBuffer.deallocate() }

                read = reader.read(readBuffer, length: inputBufferSize)
                var input = ZSTD_inBuffer(src: readBuffer, size: read, pos: 0)

                while input.pos < input.size {
                    var output = ZSTD_outBuffer(dst: writeBuffer, size: outputBufferSize, pos: 0)
                    decompressResult = ZSTD_decompressStream(decompressContext, &output, &input)
                    guard ZSTD_isError(decompressResult) == 0 else { throw Error.decompress }

                    let written = writer.write(writeBuffer, length: output.pos)
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
        let read = greedy.readAll(inputBuffer)
        let inputBufferSize = read
        let outputBufferSize = ZSTD_compressBound(inputBufferSize)
        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferSize)
        defer { outputBuffer.deallocate() }
        let compressResult = ZSTD_compress(outputBuffer, outputBufferSize, inputBuffer, inputBufferSize, config.level.rawValue)
        guard ZSTD_isError(compressResult) == 0 else { throw Error.compress }

        let written = writer.write(outputBuffer, length: compressResult)
        guard written == compressResult else { throw Error.write(expect: compressResult, written: written) }
    }

    public static func decompress(greedy: GreedyStream, writer: WriteableStream, config: DecompressConfig) throws {
        let inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: greedy.size)
        let read = greedy.readAll(inputBuffer)
        let inputBufferSize = read
        let outBufferLongLongSize = ZSTD_getFrameContentSize(inputBuffer, inputBufferSize)

        guard outBufferLongLongSize <= Int.max else { throw Error.invalidData }
        let outputBufferSize = Int(outBufferLongLongSize)

        guard outputBufferSize != ZSTD_CONTENTSIZE_ERROR else { throw Error.invalidData }
        guard outputBufferSize != ZSTD_CONTENTSIZE_UNKNOWN else { throw Error.invalidData }

        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferSize)
        defer { outputBuffer.deallocate() }

        let decompressResult = ZSTD_decompress(outputBuffer, outputBufferSize, inputBuffer, inputBufferSize)
        guard ZSTD_isError(decompressResult) == 0 else { throw Error.decompress }
        guard decompressResult == outputBufferSize else { throw Error.decompress }

        let written = writer.write(outputBuffer, length: outputBufferSize)
        guard written == outputBufferSize else {
            throw Error.write(expect: outputBufferSize, written: written)
        }
    }
}
