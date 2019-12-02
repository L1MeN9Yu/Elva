//
// Created by Mengyu Li on 2019-04-09.
// Copyright (c) 2019 limengyu.top. All rights reserved.
//

import Foundation

extension Data {
    func withUnsafePointer<ResultType>(_ body: (UnsafePointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        return try withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            let unsafeBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            guard let unsafePointer = unsafeBufferPointer.baseAddress else {
                var int: UInt8 = 0
                return try body(&int)
            }
            return try body(unsafePointer)
        }
    }
}