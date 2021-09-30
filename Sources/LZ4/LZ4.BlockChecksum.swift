//
// Created by Mengyu Li on 2021/9/29.
//

@_implementationOnly import Elva_lz4

public extension LZ4 {
    enum BlockChecksum {
        case noChecksum
        case enabled
    }
}

extension LZ4.BlockChecksum {
    var value: LZ4F_blockChecksum_t {
        switch self {
        case .noChecksum:
            return LZ4F_noBlockChecksum
        case .enabled:
            return LZ4F_blockChecksumEnabled
        }
    }
}
