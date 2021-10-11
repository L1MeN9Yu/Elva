//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation

public class FileReadStream {
    private let filePointer: UnsafeMutablePointer<FILE>
    public private(set) var size: Int = 0

    public init(path: String) throws {
        guard let filePointer = fopen(path, "rb") else {
            throw Error.fopen
        }
        self.filePointer = filePointer
    }
}

extension FileReadStream: ReadableStream {
    public func read(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Int {
        let read = fread(buffer, 1, length, filePointer)
        size += read
        return read
    }
}

extension FileReadStream: ByteStream {
    public func close() {
        fclose(filePointer)
    }
}

public extension FileReadStream {
    enum Error: Swift.Error {
        case fopen
    }
}
