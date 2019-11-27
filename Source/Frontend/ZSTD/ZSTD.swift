//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct ZSTD {
    private init() {}
}

public extension ZSTD {
    static func compress(from inFile: URL, to outFile: URL, level: Int32) -> Result<Void, Error> {
        let ret = ZSTD_compressFile(inFile.path, outFile.path, level)
        guard ret == 0 else { return .failure(.compress) }
        return .success(())
    }
}

public extension ZSTD {
    static func decompress(from inFile: URL, to outFile: URL) -> Result<Void, Error> {
        let ret = ZSTD_decompressFile(inFile.path, outFile.path)
        guard ret == 0 else { return .failure(.decompress) }
        return .success(())
    }
}