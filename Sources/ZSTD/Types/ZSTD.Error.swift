//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

public extension ZSTD {
    enum Error: Swift.Error {
        case encoderCreate
        case decoderCreate
        case setParameter
        case compress
        case decompress
        case invalidData
        case write(expect: Int, written: Int)
    }
}
