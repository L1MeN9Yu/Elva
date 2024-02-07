//
// Created by mengyu.li on 2024/2/6.
//

@_implementationOnly import Elva_zstd
import Foundation

public extension ZSTD {
    struct Dictionary {
        public let data: Data

        public init(data: Data) { self.data = data }
    }
}

extension ZSTD.Dictionary: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let data = Data(value.utf8)
        self.init(data: data)
    }
}

extension ZSTD.Dictionary {
    var pointer: UnsafeRawPointer {
        get throws {
            try data.withUnsafeBytes {
                guard let baseAddress: UnsafeRawPointer = $0.baseAddress else { throw ZSTD.Error.dictionaryData }
                return baseAddress
            }
        }
    }

    var size: Int {
        data.count
    }
}
