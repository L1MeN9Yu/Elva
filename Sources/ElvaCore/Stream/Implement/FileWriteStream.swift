//
// Created by Mengyu Li on 2021/9/28.
//

import Foundation

public class FileWriteStream {
    private let filePointer: UnsafeMutablePointer<FILE>
    private var size: Int = 0

    public init(path: String) {
        filePointer = fopen(path, "wb")
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
