//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct Decompressor {
    private init() {}
}

public extension Decompressor {
    static func decompress(from inFile: URL, to outFile: URL) -> Result<Void, Error> {
        let ret = elva_decompressFile(inFile.path, outFile.path)
        guard ret == 0 else { return .failure(.decompress) }
        return .success(())
    }
}
