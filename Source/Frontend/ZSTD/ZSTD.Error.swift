//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public extension ZSTD {
    enum Error: Swift.Error {
        case compress
        case decompress
    }
}

extension ZSTD.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compress:
            return "compress error"
        case .decompress:
            return "decompress error"
        }
    }
}
