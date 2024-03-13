//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_zstd

public extension ZSTD {
    enum Error: Swift.Error {
        case encoderCreate
        case decoderCreate
        case setParameter(code: Int)
        case compress(code: Int = 1)
        case decompress(code: Int = 1)
        case invalidData
        case write(expect: Int, written: Int)
        case dictionaryData
        case loadDictionary(code: Int)
    }
}

public extension ZSTD.Error {
    static func isError(_ code: Int) -> Bool {
        ZSTD_isError(code) != 0
    }

    static func errorName(code: Int) -> String? {
        guard let errorName: UnsafePointer<Int8> = ZSTD_getErrorName(code) else { return nil }
        return String(cString: errorName)
    }
}
