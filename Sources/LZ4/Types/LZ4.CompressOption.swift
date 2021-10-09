//
// Created by Mengyu Li on 2021/9/28.
//

import ElvaCore

public extension LZ4 {
    struct CompressOption: CompressConfigurable {
        public let bufferSize: Int
        public let autoCloseReadStream: Bool
        public let autoCloseWriteStream: Bool
        public let blockSize: BlockSize
        public let blockMode: BlockMode
        public let contentChecksum: ContentChecksum
        public let frameType: FrameType
        public let contentSize: UInt64
        public let dictID: UInt32
        public let blockChecksum: BlockChecksum

        public let compressLevel: Int32
        public let autoFlush: Bool
        public let favorDecompressSpeed: Bool

        public init(
            bufferSize: Int = 1 << 11,
            autoCloseReadStream: Bool = true,
            autoCloseWriteStream: Bool = true,
            blockSize: BlockSize = .max64KB,
            blockMode: BlockMode = .linked,
            contentChecksum: ContentChecksum = .noChecksum,
            frameType: FrameType = .frame,
            contentSize: UInt64 = 0,
            dictID: UInt32 = 0,
            blockChecksum: BlockChecksum = .noChecksum,
            compressLevel: Int32 = 0,
            autoFlush: Bool = false,
            favorDecompressSpeed: Bool = false
        ) {
            self.bufferSize = bufferSize
            self.autoCloseReadStream = autoCloseReadStream
            self.autoCloseWriteStream = autoCloseWriteStream
            self.blockSize = blockSize
            self.blockMode = blockMode
            self.contentChecksum = contentChecksum
            self.frameType = frameType
            self.contentSize = contentSize
            self.dictID = dictID
            self.blockChecksum = blockChecksum
            self.compressLevel = compressLevel
            self.autoFlush = autoFlush
            self.favorDecompressSpeed = favorDecompressSpeed
        }
    }
}

public extension LZ4.CompressOption {
    static let `default`: Self = .init()
}
