//
// Created by Mengyu Li on 2021/9/30.
//

public extension ZSTD {
    struct CompressOption: CompressConfigurable {
        public let bufferSize: Int
        public let autoCloseReadStream: Bool
        public let autoCloseWriteStream: Bool
        public let level: Level

        public init(
            bufferSize: Int = 1 << 11,
            autoCloseReadStream: Bool = true,
            autoCloseWriteStream: Bool = true,
            level: Level = .default
        ) {
            self.bufferSize = bufferSize
            self.autoCloseReadStream = autoCloseReadStream
            self.autoCloseWriteStream = autoCloseWriteStream
            self.level = level
        }
    }
}

public extension ZSTD.CompressOption {
    static let `default`: Self = .init()
}
