//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_Brotli

public extension Brotli {
    struct Quality: RawRepresentable, Hashable {
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

public extension Brotli.Quality {
    static let `default` = Self(builtinValue: Self._default)
    static let min = Self(builtinValue: Self._min)
    static let max = Self(builtinValue: Self._max)
}

private extension Brotli.Quality {
    private static let _min = BROTLI_MIN_QUALITY
    private static let _max = BROTLI_MAX_QUALITY
    private static let _default = BROTLI_DEFAULT_QUALITY
}
