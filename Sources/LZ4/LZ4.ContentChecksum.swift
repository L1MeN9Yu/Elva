//
// Created by Mengyu Li on 2021/9/29.
//

import Elva_lz4

public extension LZ4 {
    enum ContentChecksum {
        case noChecksum
        case enabled
    }
}

extension LZ4.ContentChecksum {
    var value: LZ4F_contentChecksum_t {
        switch self {
        case .noChecksum:
            return LZ4F_noContentChecksum
        case .enabled:
            return LZ4F_contentChecksumEnabled
        }
    }
}
