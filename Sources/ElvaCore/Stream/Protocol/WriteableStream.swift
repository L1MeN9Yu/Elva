//
// Created by Mengyu Li on 2021/9/28.
//

public protocol WriteableStream: ByteStream {
    func write(_ data: UnsafePointer<UInt8>, length: Int) -> Int
}
