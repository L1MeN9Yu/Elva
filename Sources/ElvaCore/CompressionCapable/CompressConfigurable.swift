//
// Created by Mengyu Li on 2021/10/9.
//

public protocol CompressConfigurable {
    var bufferSize: Int { get }
    var autoCloseReadStream: Bool { get }
    var autoCloseWriteStream: Bool { get }
    static var `default`: Self { get }
}
