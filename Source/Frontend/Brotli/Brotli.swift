//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct Brotli {
    private init() {}
}

internal extension Brotli {
    static func register() {
        Mode.register()
        Quality.register()
        WindowBits.register()
        InputBlockBits.register()
    }
}

public extension Brotli {
    static func compress(inputFile: URL, outputFile: URL, mode: Mode = Mode.default, quality: Quality = Quality.default, windowBits: WindowBits = WindowBits.default) -> Result<Void, Error> {
        let ret = Brotli_CompressFile(inputFile.path, outputFile.path, mode.rawValue, windowBits.rawValue, quality.rawValue)
        guard ret == 0 else { return .failure(.compress) }
        return .success(())
    }

    static func compress(data: Data, mode: Mode = Mode.default, quality: Quality = Quality.default, windowBits: WindowBits = WindowBits.default) -> Result<Data, Error> {
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        var outputData: UnsafeMutableRawPointer? = nil
        var outputSize: Int = 0
        let ret = Brotli_CompressData(input, data.count, mode.rawValue, windowBits.rawValue, quality.rawValue, &outputData, &outputSize)
        guard ret == 0, let cOutputData = outputData else { return .failure(Error.compress) }
        let compressData = Data(bytes: cOutputData, count: outputSize)
        defer {
            cOutputData.deallocate()
        }
        return .success(compressData)
    }
}

public extension Brotli {
    static func decompress(inputFile: URL, outputFile: URL) -> Result<Void, Error> {
        let ret = Brotli_DecompressFile(inputFile.path, outputFile.path)
        guard ret == 0 else { return .failure(.decompress) }
        return .success(())
    }

    static func decompress(data: Data, bufferCapacity: Int = 1024) -> Result<Data, Error> {
        var outputData: UnsafeMutableRawPointer? = nil
        var outputSize: Int = 0
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let ret = Brotli_DecompressData(input, data.count, &outputData, &outputSize, bufferCapacity)
        guard ret == 0, let cOutputData = outputData else { return .failure(Error.decompress) }
        let decompressData = Data(bytes: cOutputData, count: outputSize)
        defer {
            cOutputData.deallocate()
        }
        return .success(decompressData)
    }
}
