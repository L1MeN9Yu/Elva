//
// Created by Mengyu Li on 2021/9/27.
//

@_implementationOnly import Elva_lz4
import ElvaCore
import Foundation

public enum LZ4 {}

extension LZ4: CompressionCapable {
    public typealias CompressConfig = CompressOption
    public typealias DecompressConfig = DecompressOption

    public static func compress(reader: ReadableStream, writer: WriteableStream, config: CompressConfig) throws {
        let bufferSize = config.bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        let context = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: MemoryLayout<LZ4F_compressionContext_t>.size)

        let frameInfo = LZ4F_frameInfo_t(
            blockSizeID: config.blockSize.value,
            blockMode: config.blockMode.value,
            contentChecksumFlag: config.contentChecksum.value,
            frameType: config.frameType.value,
            contentSize: config.contentSize,
            dictID: config.dictID,
            blockChecksumFlag: config.blockChecksum.value
        )
        var preferences = LZ4F_preferences_t(
            frameInfo: frameInfo,
            compressionLevel: config.compressLevel,
            autoFlush: config.autoFlush ? 1 : 0,
            favorDecSpeed: config.favorDecompressSpeed ? 1 : 0,
            reserved: (0, 0, 0)
        )
        let outputBufferCapacity: Int = LZ4F_compressBound(bufferSize, &preferences)

        func createContext() throws {
            let creation: LZ4F_errorCode_t = LZ4F_createCompressionContext(context, UInt32(LZ4F_VERSION))
            guard LZ4F_isError(creation) == 0 else {
                throw Error(lz4Code: creation)
            }
        }

        try createContext()
        defer { LZ4F_freeCompressionContext(context.pointee) }

        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBufferCapacity)
        defer { outputBuffer.deallocate() }
        outputBuffer.initialize(repeating: 0, count: outputBufferCapacity)

        func writeHeader() throws {
            let headerSize = LZ4F_compressBegin(context.pointee, outputBuffer, outputBufferCapacity, &preferences)
            guard LZ4F_isError(headerSize) == 0 else { throw Error(lz4Code: headerSize) }
            let written = writer.write(outputBuffer, length: headerSize)
            guard written == headerSize else {
                throw Error.writeHeader(expect: headerSize, written: written)
            }
        }

        try writeHeader()

        func writeCompress() throws {
            var read: Int = 0
            repeat {
                let readBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { readBuffer.deallocate() }
                read = reader.read(readBuffer, length: bufferSize)
                let compressed = LZ4F_compressUpdate(context.pointee, outputBuffer, outputBufferCapacity, readBuffer, read, nil)
                guard LZ4F_isError(compressed) == 0 else {
                    throw Error(lz4Code: compressed)
                }
                let written = writer.write(outputBuffer, length: compressed)
                guard written == compressed else {
                    throw Error.write(expect: compressed, written: written)
                }
            } while read != 0
        }

        try writeCompress()

        func writeEnd() throws {
            let end = LZ4F_compressEnd(context.pointee, outputBuffer, outputBufferCapacity, nil)
            guard LZ4F_isError(end) == 0 else {
                throw Error(lz4Code: end)
            }
            let written = writer.write(outputBuffer, length: end)
            guard written == end else {
                throw Error.writeHeader(expect: end, written: written)
            }
        }

        try writeEnd()
    }

    public static func decompress(reader: ReadableStream, writer: WriteableStream, config: DecompressConfig) throws {
        let bufferSize = config.bufferSize
        defer { if config.autoCloseReadStream { reader.close() } }
        defer { if config.autoCloseWriteStream { writer.close() } }

        let context = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: MemoryLayout<LZ4F_compressionContext_t>.size)

        func createContext() throws {
            let creation = LZ4F_createDecompressionContext(context, UInt32(LZ4F_VERSION))
            guard LZ4F_isError(creation) == 0 else {
                throw Error(lz4Code: creation)
            }
        }

        try createContext()
        defer { LZ4F_freeDecompressionContext(context.pointee) }

        func readHeader() throws -> size_t {
            let headerSize = Int(LZ4F_HEADER_SIZE_MIN)
            let headerBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: headerSize)
            headerBuffer.initialize(repeating: 0, count: headerSize)
            let read = reader.read(headerBuffer, length: headerSize)
            guard read == headerSize else {
                throw Error.readHeader(expect: headerSize, read: read)
            }
            let frameInfo = UnsafeMutablePointer<LZ4F_frameInfo_t>.allocate(capacity: MemoryLayout<LZ4F_frameInfo_t>.size)
            defer { frameInfo.deallocate() }
            let consumed = UnsafeMutablePointer<Int>.allocate(capacity: headerSize)
            defer { consumed.deallocate() }
            consumed.initialize(to: read)
            let info = LZ4F_getFrameInfo(context.pointee, frameInfo, headerBuffer, consumed)
            guard LZ4F_isError(info) == 0 else {
                throw Error(lz4Code: info)
            }

            let blockSize: size_t
            switch frameInfo.pointee.blockSizeID {
            case LZ4F_default, LZ4F_max64KB:
                blockSize = 1 << 16
            case LZ4F_max256KB:
                blockSize = 1 << 18
            case LZ4F_max1MB:
                blockSize = 1 << 20
            case LZ4F_max4MB:
                blockSize = 1 << 22
            default:
                throw Error.unknownBlockSizeID
            }
            return blockSize
        }

        let blockSize = try readHeader()

        func writeDecompress() throws {
            var remain: Int = 0
            repeat {
                let scratchBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { scratchBuffer.deallocate() }
                let read = reader.read(scratchBuffer, length: bufferSize)
                let iteratorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: blockSize)
                defer { iteratorBuffer.deallocate() }

                let srcEndPtr = scratchBuffer.advanced(by: read)
                var srcStartPtr = scratchBuffer
                remain = read
                while srcStartPtr < srcEndPtr && remain != 0 {
                    var destinationSize = blockSize
                    var sourceSize = srcStartPtr.distance(to: srcEndPtr)

                    remain = LZ4F_decompress(context.pointee, iteratorBuffer, &destinationSize, srcStartPtr, &sourceSize, nil)

                    guard LZ4F_isError(remain) == 0 else {
                        throw Error(lz4Code: remain)
                    }

                    let written = writer.write(iteratorBuffer, length: destinationSize)
                    guard written == destinationSize else {
                        throw Error.write(expect: destinationSize, written: written)
                    }

                    srcStartPtr = srcStartPtr.advanced(by: sourceSize)
                }

                guard srcStartPtr == srcEndPtr else {
                    throw Error.unknownLZ4Trailing
                }
            } while remain != 0
        }

        try writeDecompress()
    }

    public static func compress(greedy: GreedyStream, writer: WriteableStream, config: CompressConfig) throws {}

    public static func decompress(greedy: GreedyStream, writer: WriteableStream, config: DecompressConfig) throws {}
}
