//
// Created by Mengyu Li on 2021/9/30.
//

public extension ZSTD {
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

public extension ZSTD.DecompressOption {
    static let `default`: Self = .init()
}
