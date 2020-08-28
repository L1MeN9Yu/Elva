//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_Brotli
import Foundation

public extension Brotli {
    struct WindowBits: RawRepresentable, Hashable {
        public typealias RawValue = Int32
        public let rawValue: RawValue

        public init?(rawValue: RawValue) {
            guard Self._min...Self._max ~= rawValue else { return nil }
            self.rawValue = rawValue
        }

        private init(builtinValue: RawValue) {
            rawValue = builtinValue
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
    private static let _min = BROTLI_MIN_WINDOW_BITS
    private static let _max = BROTLI_MAX_WINDOW_BITS
    private static let _largeMax = BROTLI_LARGE_MAX_WINDOW_BITS
    private static let _default = BROTLI_DEFAULT_WINDOW
}
