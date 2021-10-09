//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

public extension Brotli {
    enum Error: Swift.Error {
        case encoderCreate
        case decoderCreate
        case compress
        case decompress
        case write(expect: Int, written: Int)
    }
}
