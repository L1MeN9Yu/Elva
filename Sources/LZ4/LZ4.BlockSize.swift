//
// Created by Mengyu Li on 2021/9/29.
//

import Elva_lz4

public extension LZ4 {
    enum BlockSize {
        case max64KB
        case max256KB
        case max1MB
        case max4MB
    }
}

extension LZ4.BlockSize {
    var value: LZ4F_blockSizeID_t {
        switch self {
        case .max64KB:
            return LZ4F_max64KB
        case .max256KB:
            return LZ4F_max256KB
        case .max1MB:
            return LZ4F_max1MB
        case .max4MB:
            return LZ4F_max4MB
        }
    }
}
