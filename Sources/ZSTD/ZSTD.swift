//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_zstd
@_implementationOnly import ElvaCore
import Foundation

public struct ZSTD { private init() {} }

// MARK: - File

public extension ZSTD {
    static func compress(inputFile: URL, outputFile: URL, level: Level = Level.default) -> Result<Void, Error> {
        guard FileManager.default.fileExists(atPath: inputFile.path) else { return .failure(.fileNotExist) }
        guard !FileManager.default.fileExists(atPath: outputFile.path) else { return .failure(.outputFileExist) }
        guard let fileIn = fopen(inputFile.path, "rb") else { return .failure(.openFile(fileURL: inputFile)) }
        guard let fileOut = fopen(outputFile.path, "wb") else { return .failure(.openFile(fileURL: outputFile)) }
        defer {
            fclose(fileIn)
            fclose(fileOut)
        }
        guard let compressContext = ZSTD_createCCtx() else { return .failure(.encoderCreate) }
        defer { ZSTD_freeCCtx(compressContext) }

        let inputBufferSize = ZSTD_CStreamInSize()
        guard let inputBuffer = malloc(inputBufferSize) else { return .failure(.memory) }
        defer { inputBuffer.deallocate() }
        let outputBufferSize = ZSTD_CStreamOutSize()
        guard let outputBuffer = malloc(outputBufferSize) else { return .failure(.memory) }
        defer { outputBuffer.deallocate() }
        var setParameterResult = ZSTD_CCtx_setParameter(compressContext, ZSTD_c_compressionLevel, level.rawValue)
        guard ZSTD_isError(setParameterResult) == 0 else { return .failure(.encoderCreate) }
        setParameterResult = ZSTD_CCtx_setParameter(compressContext, ZSTD_c_checksumFlag, 1)
        guard ZSTD_isError(setParameterResult) == 0 else { return .failure(.encoderCreate) }

        while true {
            let readSize = fread(inputBuffer, 1, inputBufferSize, fileIn)
            let lastChunk = readSize < inputBufferSize
            let mode: ZSTD_EndDirective = lastChunk ? ZSTD_e_end : ZSTD_e_continue
            var input = ZSTD_inBuffer(src: inputBuffer, size: readSize, pos: 0)
            var finished = false
            while !finished {
                var output = ZSTD_outBuffer(dst: outputBuffer, size: outputBufferSize, pos: 0)
                let remaining = ZSTD_compressStream2(compressContext, &output, &input, mode)
                guard ZSTD_isError(remaining) == 0 else { return .failure(.compress) }
                fwrite(outputBuffer, 1, output.pos, fileOut)
                finished = lastChunk ? (remaining == 0) : (input.pos == input.size)
            }

            if input.pos != input.size { return .failure(.compress) }

            if lastChunk { break }
        }

        return .success(())
    }

    static func decompress(inputFile: URL, outputFile: URL) -> Result<Void, Error> {
        guard FileManager.default.fileExists(atPath: inputFile.path) else { return .failure(.fileNotExist) }
        guard !FileManager.default.fileExists(atPath: outputFile.path) else { return .failure(.outputFileExist) }
        guard let decompressContext = ZSTD_createDCtx() else { return .failure(.decoderCreate) }
        defer { ZSTD_freeDCtx(decompressContext) }
        guard let fileIn = fopen(inputFile.path, "rb") else { return .failure(.openFile(fileURL: inputFile)) }
        defer { fclose(fileIn) }
        guard let fileOut = fopen(outputFile.path, "wb") else { return .failure(.openFile(fileURL: outputFile)) }
        defer { fclose(fileOut) }
        let inputBufferSize = ZSTD_DStreamInSize()
        guard let inputBuffer = malloc(inputBufferSize) else { return .failure(.memory) }
        defer { inputBuffer.deallocate() }
        let outputBufferSize = ZSTD_DStreamOutSize()
        guard let outputBuffer = malloc(outputBufferSize) else { return .failure(.memory) }

        var read = 0
        var lastRet = 0

        repeat {
            read = fread(inputBuffer, 1, inputBufferSize, fileIn)
            var input = ZSTD_inBuffer(src: inputBuffer, size: read, pos: 0)

            while input.pos < input.size {
                var output = ZSTD_outBuffer(dst: outputBuffer, size: outputBufferSize, pos: 0)
                let decompressResult = ZSTD_decompressStream(decompressContext, &output, &input)
                guard ZSTD_isError(decompressResult) == 0 else { return .failure(.decompress) }
                fwrite(outputBuffer, 1, output.pos, fileOut)
                lastRet = decompressResult
            }
        } while read > 0

        guard lastRet == 0 else { return .failure(.decompress) }

        return .success(())
    }
}

// MARK: - Data

public extension ZSTD {
    static func compress(data: Data, level: Level = Level.default) -> Result<Data, Error> {
        let inputBuffer = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let inputBufferSize = data.count
        let outputBufferSize = ZSTD_compressBound(inputBufferSize)
        guard let outputBuffer = malloc(outputBufferSize) else { return .failure(.memory) }
        defer { outputBuffer.deallocate() }
        let compressResult = ZSTD_compress(outputBuffer, outputBufferSize, inputBuffer, inputBufferSize, level.rawValue)
        guard ZSTD_isError(compressResult) == 0 else { return .failure(.compress) }

        let data = Data(bytes: outputBuffer, count: compressResult)
        return .success(data)
    }

    static func decompress(data: Data) -> Result<Data, Error> {
        let inputBuffer = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let inputBufferSize = data.count
        let outputBufferSize = Int(ZSTD_getFrameContentSize(inputBuffer, inputBufferSize))
        guard outputBufferSize != ZSTD_CONTENTSIZE_ERROR else { return .failure(.invalidData) }
        guard outputBufferSize != ZSTD_CONTENTSIZE_UNKNOWN else { return .failure(.invalidData) }
        guard let outputBuffer = malloc(outputBufferSize) else { return .failure(.memory) }
        defer { outputBuffer.deallocate() }
        let decompressResult = ZSTD_decompress(outputBuffer, outputBufferSize, inputBuffer, inputBufferSize)
        guard ZSTD_isError(decompressResult) == 0 else { return .failure(.decompress) }
        guard decompressResult == outputBufferSize else { return .failure(.decompress) }

        let data = Data(bytes: outputBuffer, count: outputBufferSize)
        return .success(data)
    }
}
