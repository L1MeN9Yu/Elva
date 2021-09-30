//
// Created by Mengyu Li on 2021/9/28.
//

@_implementationOnly import Elva_lz4

public extension LZ4 {
    enum Error: Swift.Error {
        case writeHeader(expect: Int, written: Int)
        case readHeader(expect: Int, read: Int)
        case write(expect: Int, written: Int)
        case unknownBlockSizeID
        case unknownLZ4Trailing
        case lz4(message: String)
    }
}

extension LZ4.Error {
    init(lz4Code: LZ4F_errorCode_t) {
        self = .lz4(message: String(cString: LZ4F_getErrorName(lz4Code)))
    }
}
