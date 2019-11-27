//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public extension Brotli {
    struct WindowBits: RawRepresentable, Hashable {
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

public extension Brotli.WindowBits {
    static let `default` = Self(builtinValue: Self._default)
    static let min = Self(builtinValue: Self._min)
    static let max = Self(builtinValue: Self._max)
    static let largeMax = Self(builtinValue: Self._largeMax)
}

private extension Brotli.WindowBits {
    private static var _min: UInt32 = 0
    private static var _max: UInt32 = 0
    private static var _largeMax: UInt32 = 0
    private static var _default: UInt32 = 0
}

internal extension Brotli.WindowBits {
    static func register() {
        Brotli_GetWindowBits(&_min, &_max, &_largeMax, &_default)
    }
}