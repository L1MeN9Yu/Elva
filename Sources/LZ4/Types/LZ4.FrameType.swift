//
// Created by Mengyu Li on 2021/9/29.
//

@_implementationOnly import Elva_lz4

public extension LZ4 {
    enum FrameType {
        case frame
        case skippableFrame
    }
}

extension LZ4.FrameType {
    var value: LZ4F_frameType_t {
        switch self {
        case .frame:
            return LZ4F_frame
        case .skippableFrame:
            return LZ4F_skippableFrame
        }
    }
}
