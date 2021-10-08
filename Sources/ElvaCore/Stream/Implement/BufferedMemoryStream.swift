//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation

public class BufferedMemoryStream {
    public private(set) var representation: Data
    private var readerIndex: Int = 0

    public init(startData: Data = Data()) {
        representation = startData
    }
}

public extension BufferedMemoryStream {
    var size: Int { representation.count }
}

extension BufferedMemoryStream: ReadableStream {
    public func read(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Int {
        guard readerIndex < size else { return 0 }

        let maxTransferable: Int = min(size - readerIndex, length)
        let readerLastIndex: Int = readerIndex + maxTransferable
        representation.copyBytes(to: buffer, from: readerIndex..<readerLastIndex)
        readerIndex += maxTransferable

        return maxTransferable
    }
}

extension BufferedMemoryStream: WriteableStream {
    public func write(_ data: UnsafePointer<UInt8>, length: Int) -> Int {
        representation += Data(bytes: data, count: length)
        return length
    }
}

extension BufferedMemoryStream: GreedyStream {
    public func readAll(sink: WriteableStream) -> Int {
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: representation.count)
        defer { bytes.deallocate() }

        representation.copyBytes(to: bytes, count: size)
        let written: Int = sink.write(bytes, length: size)
        assert(written == size)
        return written
    }
}

extension BufferedMemoryStream: Equatable {
    public static func == (lhs: BufferedMemoryStream, rhs: BufferedMemoryStream) -> Bool {
        lhs.representation == rhs.representation
    }
}
