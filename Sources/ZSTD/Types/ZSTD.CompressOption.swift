//
// Created by Mengyu Li on 2021/9/30.
//

@_implementationOnly import Elva_zstd

public extension ZSTD {
    struct CompressOption: CompressConfigurable {
        public let bufferSize: Int
        public let inputBufferSize: Int?
        public let outputBufferSize: Int?
        public let autoCloseReadStream: Bool
        public let autoCloseWriteStream: Bool
        public let level: Level
        public let dictionary: Dictionary?

        public init(
            bufferSize: Int = 1 << 11,
            inputBufferSize: Int? = nil,
            outputBufferSize: Int? = nil,
            autoCloseReadStream: Bool = true,
            autoCloseWriteStream: Bool = true,
            level: Level = .default,
            dictionary: Dictionary? = nil
        ) {
            self.bufferSize = bufferSize
            self.inputBufferSize = inputBufferSize
            self.outputBufferSize = outputBufferSize
            self.autoCloseReadStream = autoCloseReadStream
            self.autoCloseWriteStream = autoCloseWriteStream
            self.level = level
            self.dictionary = dictionary
        }
    }
}

public extension ZSTD.CompressOption {
    static let `default`: Self = .init()

    static let zstd: Self = .init(inputBufferSize: ZSTD_CStreamInSize(), outputBufferSize: ZSTD_CStreamOutSize())
}
