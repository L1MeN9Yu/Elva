//
// Created by Mengyu Li on 2021/9/28.
//

public protocol ReadableStream: ByteStream {
    func read(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Int
}
