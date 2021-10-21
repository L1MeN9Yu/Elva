//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_zstd
import Foundation

public extension ZSTD {
    struct Level: RawRepresentable, Hashable {
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

public extension ZSTD.Level {
    static let `default` = Self(builtinValue: Self._default)
    static let min = Self(builtinValue: Self._min)
    static let max = Self(builtinValue: Self._max)
}

private extension ZSTD.Level {
    private static let _min = ZSTD_minCLevel()
    private static let _max = ZSTD_maxCLevel()
    private static let _default = ZSTD_defaultCLevel()
}
