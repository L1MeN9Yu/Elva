//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct ZSTD {
    private init() {}
}

// MARK: - register
internal extension ZSTD {
    static func register() {
        Level.register()
    }
}

// MARK: - compress
public extension ZSTD {
    static func compress(from inFile: URL, to outFile: URL, level: Level = Level.default) -> Result<Void, Error> {
        let ret = ZSTD_CompressFile(inFile.path, outFile.path, level.rawValue)
        guard ret == 0 else { return .failure(.compress) }
        return .success(())
    }

    static func compress(data: Data, level: Level = Level.default) -> Result<Data, Error> {
        var outputData: UnsafeMutableRawPointer? = nil
        var outputSize: Int = 0
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let ret = ZSTD_CompressData(input, data.count, level.rawValue, &outputData, &outputSize)
        guard ret == 0, let cOutputData = outputData else { return .failure(Error.compress) }
        let compressData = Data(bytes: cOutputData, count: outputSize)
        defer {
            cOutputData.deallocate()
        }
        return .success(compressData)
    }
}

// MARK: - decompress
public extension ZSTD {
    static func decompress(from inFile: URL, to outFile: URL) -> Result<Void, Error> {
        let ret = ZSTD_DecompressFile(inFile.path, outFile.path)
        guard ret == 0 else { return .failure(.decompress) }
        return .success(())
    }

    static func decompress(data: Data) -> Result<Data, Error> {
        var outputData: UnsafeMutableRawPointer? = nil
        var outputSize: Int = 0
        let input = data.withUnsafePointer { pointer -> UnsafeRawPointer in UnsafeRawPointer(pointer) }
        let ret = ZSTD_DecompressData(input, data.count, &outputData, &outputSize)
        guard ret == 0, let cOutputData = outputData else { return .failure(Error.decompress) }
        let decompressData = Data(bytes: cOutputData, count: outputSize)
        defer {
            cOutputData.deallocate()
        }
        return .success(decompressData)
    }
}