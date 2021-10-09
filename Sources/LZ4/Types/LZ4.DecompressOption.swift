//
// Created by Mengyu Li on 2021/9/29.
//

import ElvaCore

public extension LZ4 {
    struct DecompressOption: DecompressConfigurable {
        public let bufferSize: Int
        public let autoCloseReadStream: Bool
        public let autoCloseWriteStream: Bool

        public init(
            bufferSize: Int = 1 << 11,
            autoCloseReadStream: Bool = true,
            autoCloseWriteStream: Bool = true
        ) {
            self.bufferSize = bufferSize
            self.autoCloseReadStream = autoCloseReadStream
            self.autoCloseWriteStream = autoCloseWriteStream
        }
    }
}

public extension LZ4.DecompressOption {
    static let `default`: Self = .init()
}
