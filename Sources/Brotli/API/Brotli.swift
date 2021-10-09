//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_Brotli
import ElvaCore
import Foundation

public enum Brotli {}

extension Brotli: CompressionCapable {
    public typealias CompressConfig = CompressOption
    public typealias DecompressConfig = DecompressOption

    public static func compress(reader: ReadableStream, writer: WriteableStream, config: CompressConfig) throws {
        let bufferSize = config.bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        func createEncoder() throws -> OpaquePointer {
            guard let encoderState = BrotliEncoderCreateInstance(nil, nil, nil) else { throw Error.encoderCreate }
            guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_MODE, config.mode.rawValue) == BROTLI_TRUE else { throw Error.encoderCreate }
            guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_QUALITY, UInt32(config.quality.rawValue)) == BROTLI_TRUE else { throw Error.encoderCreate }
            guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_LGWIN, UInt32(config.windowBits.rawValue)) == BROTLI_TRUE else { throw Error.encoderCreate }
            guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_LGBLOCK, UInt32(config.inputBlockBits.rawValue)) == BROTLI_TRUE else { throw Error.encoderCreate }
            return encoderState
        }

        let encoderState = try createEncoder()
        defer { BrotliEncoderDestroyInstance(encoderState) }

        func writeCompress() throws {
            var isEnd = false
            let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: bufferSize)
            defer { readBuffer.deallocate() }
            let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: bufferSize)
            defer { writeBuffer.deallocate() }
            var availableIn: size_t = 0
            var nextInBuffer: UnsafePointer<UInt8>?
            var availableOut: size_t = bufferSize
            var nextOutBuffer: UnsafeMutablePointer<UInt8>? = writeBuffer

            while true {
                if availableIn == 0 && !isEnd {
                    availableIn = reader.read(readBuffer, length: bufferSize)
                    nextInBuffer = UnsafePointer<UInt8>(readBuffer)
                    isEnd = availableIn < bufferSize
                }
                let operation: BrotliEncoderOperation = isEnd ? BROTLI_OPERATION_FINISH : BROTLI_OPERATION_PROCESS
                let compressResult = BrotliEncoderCompressStream(encoderState, operation, &availableIn, &nextInBuffer, &availableOut, &nextOutBuffer, nil)
                guard compressResult == BROTLI_TRUE else {
                    throw Error.compress
                }

                guard let nextOutBufferWrapped = nextOutBuffer else {
                    throw Error.compress
                }
                if availableOut == 0 {
                    let outputSize: size_t = nextOutBufferWrapped - writeBuffer
                    let written = writer.write(writeBuffer, length: outputSize)
                    guard written == outputSize else {
                        throw Error.write(expect: outputSize, written: written)
                    }
                    availableOut = bufferSize
                    nextOutBuffer = writeBuffer
                }

                if BrotliEncoderIsFinished(encoderState) == BROTLI_TRUE {
                    let outSize: size_t = nextOutBufferWrapped - writeBuffer
                    let written = writer.write(writeBuffer, length: outSize)
                    guard written == outSize else {
                        throw Error.write(expect: outSize, written: written)
                    }
                    availableOut = 0
                    break
                }
            }
        }

        try writeCompress()
    }

    public static func decompress(reader: ReadableStream, writer: WriteableStream, config: DecompressConfig) throws {
        let bufferSize = config.bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        func createDecoder() throws -> OpaquePointer {
            guard let decoderState: OpaquePointer = BrotliDecoderCreateInstance(nil, nil, nil) else { throw Error.decoderCreate }
            guard BrotliDecoderSetParameter(decoderState, BROTLI_DECODER_PARAM_LARGE_WINDOW, 1) == BROTLI_TRUE else { throw Error.decoderCreate }
            return decoderState
        }

        let decoderState = try createDecoder()
        defer { BrotliDecoderDestroyInstance(decoderState) }

        func writeDecompress() throws {
            var result: BrotliDecoderResult = BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT
            let readBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: bufferSize)
            defer { readBuffer.deallocate() }
            let writeBuffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: bufferSize)
            defer { writeBuffer.deallocate() }
            var availableIn: size_t = 0
            var nextInBuffer: UnsafePointer<UInt8>?
            var availableOut: size_t = bufferSize
            var nextOutBuffer: UnsafeMutablePointer<UInt8>? = writeBuffer

            whileLoop: while true {
                guard let nextOutBufferWrapped = nextOutBuffer else {
                    throw Error.decompress
                }
                switch result {
                case BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT:
                    availableIn = reader.read(readBuffer, length: bufferSize)
                    nextInBuffer = UnsafePointer<UInt8>(readBuffer)
                case BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT:
                    let outSize: size_t = nextOutBufferWrapped - writeBuffer
                    let written = writer.write(writeBuffer, length: outSize)
                    guard written == outSize else {
                        throw Error.write(expect: outSize, written: written)
                    }
                    availableOut = bufferSize
                    nextOutBuffer = writeBuffer
                case BROTLI_DECODER_RESULT_SUCCESS:
                    let outputSize: size_t = nextOutBufferWrapped - writeBuffer
                    let written = writer.write(writeBuffer, length: outputSize)
                    guard written == outputSize else {
                        throw Error.write(expect: outputSize, written: written)
                    }
                    availableOut = 0
                    break whileLoop
                default:
                    throw Error.decompress
                }

                result = BrotliDecoderDecompressStream(decoderState, &availableIn, &nextInBuffer, &availableOut, &nextOutBuffer, nil)
            }
        }

        try writeDecompress()
    }

    public static func compress(greedy: GreedyStream, writer: WriteableStream, config: CompressConfig) throws {
        let inputMemory = BufferedMemoryStream()
        let read = greedy.readAll(sink: inputMemory)
        let maxOutputSize = BrotliEncoderMaxCompressedSize(read)
        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxOutputSize)
        defer { outputBuffer.deallocate() }
        var outputSize = maxOutputSize
        guard BrotliEncoderCompress(config.quality.rawValue, config.windowBits.rawValue, config.mode.value, read, [UInt8](inputMemory.representation), &outputSize, outputBuffer) == BROTLI_TRUE else {
            throw Error.compress
        }
        let written = writer.write(outputBuffer, length: outputSize)
        guard written == outputSize else {
            throw Error.write(expect: outputSize, written: written)
        }
    }

    public static func decompress(greedy: GreedyStream, writer: WriteableStream, config: DecompressConfig) throws {
        let bufferSize = config.bufferSize

        let inputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: greedy.size)
        defer { inputBuffer.deallocate() }
        let read = greedy.readAll(inputBuffer)

        var availableIn = read
        var nextInputBuffer: UnsafePointer<UInt8>? = UnsafePointer<UInt8>(inputBuffer)
        var outputSize: Int = 0
        var lastOutputBufferSize = bufferSize
        var outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: lastOutputBufferSize)
        defer { outputBuffer.deallocate() }

        guard let decoderState = BrotliDecoderCreateInstance(nil, nil, nil) else {
            throw Error.decoderCreate
        }
        defer { BrotliDecoderDestroyInstance(decoderState) }
        var result: BrotliDecoderResult = BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT
        var outputBufferCapacity = bufferSize
        while result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT {
            var availableOutSize = outputBufferCapacity - outputSize
            var nextOutBuffer: UnsafeMutablePointer<UInt8>? = outputBuffer + outputSize
            result = BrotliDecoderDecompressStream(decoderState, &availableIn, &nextInputBuffer, &availableOutSize, &nextOutBuffer, nil)
            outputSize = outputBufferCapacity - availableOutSize
            if availableOutSize < bufferSize {
                outputBufferCapacity += bufferSize
                let newBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferCapacity)
                newBuffer.initialize(from: outputBuffer, count: lastOutputBufferSize)
                outputBuffer.deallocate()
                outputBuffer = newBuffer
                lastOutputBufferSize = outputBufferCapacity
            }
        }

        if result != BROTLI_DECODER_RESULT_SUCCESS && result != BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT {
            throw Error.decompress
        }
        let written = writer.write(outputBuffer, length: outputSize)
        guard written == outputSize else {
            throw Error.write(expect: outputSize, written: written)
        }
    }
}
