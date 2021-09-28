//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif
@_implementationOnly import Elva_Brotli
@_implementationOnly import ElvaCore
import Foundation

public enum Brotli {}

private extension Brotli {
    static let fileBufferSize: size_t = 1 << 19
}

// MARK: - File

public extension Brotli {
    static func compress(inputFile: URL, outputFile: URL, mode: Mode = Mode.default, quality: Quality = Quality.default, windowBits: WindowBits = WindowBits.default) throws {
        guard FileManager.default.fileExists(atPath: inputFile.path) else { throw Error.fileNotExist }
        guard let fileIn = fopen(inputFile.path, "rb") else { throw Error.openFile(fileURL: inputFile) }
        defer { fclose(fileIn) }
        let fd = open(outputFile.path, O_CREAT | (true ? 0 : O_EXCL) | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR)
        guard fd > 0 else { throw Error.openFile(fileURL: outputFile) }
        guard let fileOut = fdopen(fd, "wb") else { throw Error.openFile(fileURL: outputFile) }
        defer { fclose(fileOut) }
        guard let encoderState = BrotliEncoderCreateInstance(nil, nil, nil) else { throw Error.encoderCreate }
        defer { BrotliEncoderDestroyInstance(encoderState) }

        guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_MODE, mode.rawValue) == BROTLI_TRUE else { throw Error.encoderCreate }
        guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_QUALITY, UInt32(quality.rawValue)) == BROTLI_TRUE else { throw Error.encoderCreate }
        guard BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_LGWIN, UInt32(windowBits.rawValue)) == BROTLI_TRUE else { throw Error.encoderCreate }

        var isEndOfFile = false
        guard let rawBuffer = malloc(fileBufferSize * 2) else { throw Error.memory }
        let buffer = rawBuffer.assumingMemoryBound(to: UInt8.self)
        let inputBuffer = buffer
        let outputBuffer = buffer + fileBufferSize
        var availableInSize: size_t = 0
        var nextInBuffer: UnsafePointer<UInt8>?
        var availableOutSize: size_t = fileBufferSize
        var nextOutBuffer: UnsafeMutablePointer<UInt8>? = outputBuffer

        while true {
            if availableInSize == 0 && !isEndOfFile {
                availableInSize = fread(inputBuffer, 1, fileBufferSize, fileIn)
                nextInBuffer = UnsafePointer<UInt8>(inputBuffer)
                guard ferror(fileIn) == 0 else { throw Error.fileIO }
                isEndOfFile = feof(fileIn) == 1
            }

            let compressResult = BrotliEncoderCompressStream(
                encoderState,
                isEndOfFile ? BROTLI_OPERATION_FINISH : BROTLI_OPERATION_PROCESS,
                &availableInSize, &nextInBuffer,
                &availableOutSize, &nextOutBuffer, nil
            )
            guard compressResult == BROTLI_TRUE else { throw Error.compress }

            if availableOutSize == 0 {
                let outSize: size_t = nextOutBuffer! - outputBuffer
                if outSize != 0 {
                    fwrite(outputBuffer, 1, outSize, fileOut)
                    guard ferror(fileOut) == 0 else { throw Error.fileIO }
                }
                availableOutSize = fileBufferSize
                nextOutBuffer = outputBuffer
            }

            if BrotliEncoderIsFinished(encoderState) == BROTLI_TRUE {
                let outSize: size_t = nextOutBuffer! - outputBuffer
                if outSize != 0 {
                    fwrite(outputBuffer, 1, outSize, fileOut)
                    guard ferror(fileOut) == 0 else { throw Error.fileIO }
                    availableOutSize = 0
                    break
                }
            }
        }
    }

    static func decompress(inputFile: URL, outputFile: URL) throws {
        guard FileManager.default.fileExists(atPath: inputFile.path) else { throw Error.fileNotExist }
        guard let fileIn = fopen(inputFile.path, "rb") else { throw Error.openFile(fileURL: inputFile) }
        let fd = open(outputFile.path, O_CREAT | (true ? 0 : O_EXCL) | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR)
        guard fd > 0 else { throw Error.openFile(fileURL: outputFile) }
        guard let fileOut = fdopen(fd, "wb") else { throw Error.openFile(fileURL: outputFile) }
        guard let decoderState = BrotliDecoderCreateInstance(nil, nil, nil) else { throw Error.decoderCreate }
        guard BrotliDecoderSetParameter(decoderState, BROTLI_DECODER_PARAM_LARGE_WINDOW, 1) == BROTLI_TRUE else { throw Error.decoderCreate }
        defer {
            BrotliDecoderDestroyInstance(decoderState)
            fclose(fileIn)
            fclose(fileOut)
        }
        var result: BrotliDecoderResult = BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT
        guard let rawBuffer = malloc(fileBufferSize * 2) else { throw Error.memory }
        let buffer = rawBuffer.assumingMemoryBound(to: UInt8.self)
        let inputBuffer = buffer
        let outputBuffer = buffer + fileBufferSize
        var availableIn: size_t = 0
        var nextInBuffer: UnsafePointer<UInt8>?
        var availableOut: size_t = fileBufferSize
        var nextOutBuffer: UnsafeMutablePointer<UInt8>? = outputBuffer

        while true {
            if result == BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT {
                if feof(fileIn) == 1 { throw Error.fileIO }
                availableIn = fread(inputBuffer, 1, fileBufferSize, fileIn)
                nextInBuffer = UnsafePointer<UInt8>(inputBuffer)
                guard ferror(fileIn) == 0 else { throw Error.fileIO }
            } else if result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT {
                let outSize: size_t = nextOutBuffer! - outputBuffer
                if outSize != 0 {
                    fwrite(outputBuffer, 1, outSize, fileOut)
                    guard ferror(fileOut) == 0 else { throw Error.fileIO }
                }
                availableOut = fileBufferSize
                nextOutBuffer = outputBuffer
            } else if result == BROTLI_DECODER_RESULT_SUCCESS {
                let outSize: size_t = nextOutBuffer! - outputBuffer
                if outSize != 0 {
                    fwrite(outputBuffer, 1, outSize, fileOut)
                    guard ferror(fileOut) == 0 else { throw Error.fileIO }
                    availableOut = 0
                    break
                }
            } else {
                throw Error.decompress
            }

            result = BrotliDecoderDecompressStream(decoderState, &availableIn, &nextInBuffer, &availableOut, &nextOutBuffer, nil)
        }
    }
}

// MARK: - Data

public extension Brotli {
    static func compress(data: Data, mode: Mode = Mode.default,
                         quality: Quality = Quality.default, windowBits: WindowBits = WindowBits.default) throws -> Data
    {
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let inputBuffer = input.assumingMemoryBound(to: UInt8.self)
        var outputSize: Int = 0
        let maxOutputSize = BrotliEncoderMaxCompressedSize(data.count)
        guard let outputRawBuffer = malloc(maxOutputSize * MemoryLayout<UInt8>.size) else { throw Error.memory }
        let outputBuffer = outputRawBuffer.assumingMemoryBound(to: UInt8.self)
        defer { outputBuffer.deallocate() }
        outputSize = maxOutputSize
        guard BrotliEncoderCompress(quality.rawValue, windowBits.rawValue, mode.brotliEncoderMode, data.count, inputBuffer, &outputSize, outputBuffer) == BROTLI_TRUE else {
            throw Error.compress
        }
        let data = Data(bytes: outputBuffer, count: outputSize)
        return data
    }

    static func decompress(data: Data, bufferCapacity: Int = 1024) throws -> Data {
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        var availableInSize = data.count
        var nextInputBuffer: UnsafePointer<UInt8>? = input.assumingMemoryBound(to: UInt8.self)
        var outputBufferSize = 0
        var outputBuffer = malloc(bufferCapacity * MemoryLayout<UInt8>.size).assumingMemoryBound(to: UInt8.self)
        defer { outputBuffer.deallocate() }
        guard let decoderState = BrotliDecoderCreateInstance(nil, nil, nil) else { throw Error.decoderCreate }
        defer { BrotliDecoderDestroyInstance(decoderState) }
        var result: BrotliDecoderResult = BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT
        var totalOut: size_t = 0
        var outputBufferCapacity = bufferCapacity
        while result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT {
            var availableOutSize = outputBufferCapacity - outputBufferSize
            var nextOutBuffer: UnsafeMutablePointer<UInt8>? = outputBuffer + outputBufferSize
            result = BrotliDecoderDecompressStream(decoderState, &availableInSize, &nextInputBuffer, &availableOutSize, &nextOutBuffer, &totalOut)
            outputBufferSize = outputBufferCapacity - availableOutSize
            if availableOutSize < bufferCapacity {
                outputBufferCapacity += bufferCapacity
                outputBuffer = realloc(outputBuffer, outputBufferCapacity * MemoryLayout<UInt8>.size).assumingMemoryBound(to: UInt8.self)
            }
        }

        if result != BROTLI_DECODER_RESULT_SUCCESS && result != BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT {
            throw Error.decompress
        }

        let data = Data(bytes: outputBuffer, count: totalOut)
        return data
    }
}
