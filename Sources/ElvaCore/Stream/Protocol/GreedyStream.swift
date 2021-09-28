//
// Created by Mengyu Li on 2021/9/28.
//

public protocol GreedyStream {
    func readAll(sink: WriteableStream) -> Int
}
