//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public extension Brotli {
    struct InputBlockBits: RawRepresentable, Hashable {
        public typealias RawValue = UInt32
        public let rawValue: RawValue

        public init?(rawValue: RawValue) {
            guard Self._min...Self._max ~= rawValue else { return nil }
            self.rawValue = rawValue
        }

        private init(builtinValue: RawValue) {
            self.rawValue = builtinValue
        }
    }
}

public extension Brotli.InputBlockBits {
    static let min = Self(builtinValue: Self._min)
    static let max = Self(builtinValue: Self._max)
}

private extension Brotli.InputBlockBits {
    private static var _min: UInt32 = 0
    private static var _max: UInt32 = 0
}

internal extension Brotli.InputBlockBits {
    static func register() {
        Brotli_GetInputBlockBits(&_min, &_max)
    }
}