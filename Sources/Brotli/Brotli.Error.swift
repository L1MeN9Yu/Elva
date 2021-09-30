//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public extension Brotli {
    enum Error: Swift.Error {
        case fileNotExist
        case openFile(fileURL: URL)
        case encoderCreate
        case decoderCreate
        case memory
        case fileIO
        case compress
        case decompress
        case write(expect: Int, written: Int)
    }
}
