//
// Created by Mengyu Li on 2021/9/28.
//

public protocol GreedyStream {
    func readAll(sink: WriteableStream) -> Int
    func readAll(_ buffer: UnsafeMutablePointer<UInt8>) -> Int
    var size: Int { get }
}
