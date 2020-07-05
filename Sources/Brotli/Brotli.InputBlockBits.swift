//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation
import Elva_Brotli

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
    private static let _min: UInt32 = UInt32(BROTLI_MIN_INPUT_BLOCK_BITS)
    private static let _max: UInt32 = UInt32(BROTLI_MAX_INPUT_BLOCK_BITS)
}
