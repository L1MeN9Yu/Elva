//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public struct Compressor {
    private init() {}
}

public extension Compressor {
    static func compress(from inFile: URL, to outFile: URL, level: Int32) -> Result<Void, Error> {
        let ret = elva_compressFile(inFile.path, outFile.path, level)
        guard ret == 0 else { return .failure(.compress) }
        return .success(())
    }
}
