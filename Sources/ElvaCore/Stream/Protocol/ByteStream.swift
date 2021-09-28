//
// Created by Mengyu Li on 2021/9/28.
//

public protocol ByteStream {
    func close()
}

public extension ByteStream {
    func close() {}
}
