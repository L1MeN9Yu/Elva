//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_Brotli

public extension Brotli {
    struct InputBlockBits: RawRepresentable, Hashable {
        public typealias RawValue = UInt32
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

public extension Brotli.InputBlockBits {
    static let min = Self(builtinValue: Self._min)
    static let max = Self(builtinValue: Self._max)
}

private extension Brotli.InputBlockBits {
    static let _min = UInt32(BROTLI_MIN_INPUT_BLOCK_BITS)
    static let _max = UInt32(BROTLI_MAX_INPUT_BLOCK_BITS)
}
