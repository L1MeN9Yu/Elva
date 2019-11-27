//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct Brotli {
    private init() {}
}

internal extension Brotli {
    static func register() {
        Mode.register()
        Quality.register()
        WindowBits.register()
        InputBlockBits.register()
    }
}

public extension Brotli {
    static func compress(inputFile: URL, outputFile: URL, mode: Mode = Mode.default, quality: Quality = Quality.default, windowBits: WindowBits = WindowBits.default) -> Result<Void, Error> {
        let ret = Brotli_Compress(inputFile.path, outputFile.path, mode.rawValue, windowBits.rawValue, quality.rawValue)
        guard ret == 0 else { return .failure(.compress) }
        return .success(())
    }
}

public extension Brotli {
    static func decompress(inputFile: URL, outputFile: URL) -> Result<Void, Error> {
        let ret = Brotli_Decompress(inputFile.path, outputFile.path)
        guard ret == 0 else { return .failure(.decompress) }
        return .success(())
    }
}
