//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public extension ZSTD {
    enum Error: Swift.Error {
        case fileNotExist
        case outputFileExist
        case openFile(fileURL: URL)
        case encoderCreate
        case decoderCreate
        case memory
        case fileIO
        case invalidData
        case compress
        case decompress
    }
}
