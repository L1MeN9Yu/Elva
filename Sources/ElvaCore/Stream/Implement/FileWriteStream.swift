//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation

public class FileWriteStream {
    private let filePointer: UnsafeMutablePointer<FILE>
    public private(set) var size: Int = 0

    public init(path: String) throws {
        guard let filePointer = fopen(path, "wb") else {
            throw Error.fopen
        }
        self.filePointer = filePointer
    }
}

public extension FileWriteStream {
    func close() {
        fclose(filePointer)
    }
}

extension FileWriteStream: WriteableStream {
    public func write(_ data: UnsafePointer<UInt8>, length: Int) -> Int {
        let written = fwrite(data, 1, length, filePointer)
        size += written
        return written
    }
}

public extension FileWriteStream {
    enum Error: Swift.Error {
        case fopen
    }
}
