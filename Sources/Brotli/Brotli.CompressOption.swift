//
// Created by Mengyu Li on 2021/9/30.
//

@_implementationOnly import Elva_Brotli

public extension Brotli {
    struct CompressOption: CompressConfigurable {
        public let bufferSize: Int
        public let autoCloseReadStream: Bool
        public let autoCloseWriteStream: Bool
        public let mode: Mode
        public let quality: Quality
        public let windowBits: WindowBits

        public init(
            bufferSize: Int = 1 << 11,
            autoCloseReadStream: Bool = true,
            autoCloseWriteStream: Bool = true,
            mode: Mode = .default,
            quality: Quality = .default,
            windowBits: WindowBits = .default
        ) {
            self.bufferSize = bufferSize
            self.autoCloseReadStream = autoCloseReadStream
            self.autoCloseWriteStream = autoCloseWriteStream
            self.mode = mode
            self.quality = quality
            self.windowBits = windowBits
        }
    }
}

public extension Brotli.CompressOption {
    static let `default`: Self = .init()
}
