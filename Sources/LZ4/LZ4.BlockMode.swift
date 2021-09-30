//
// Created by Mengyu Li on 2021/9/29.
//

@_implementationOnly import Elva_lz4

public extension LZ4 {
    enum BlockMode {
        case linked
        case independent
    }
}

extension LZ4.BlockMode {
    var value: LZ4F_blockMode_t {
        switch self {
        case .linked:
            return LZ4F_blockLinked
        case .independent:
            return LZ4F_blockIndependent
        }
    }
}
