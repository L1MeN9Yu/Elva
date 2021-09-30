//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_implementationOnly import Elva_Brotli

public extension Brotli {
    enum Mode {
        case generic
        case text
        case font

        var rawValue: UInt32 {
            switch self {
            case .generic:
                return Self._generic
            case .text:
                return Self._text
            case .font:
                return Self._font
            }
        }

        var value: BrotliEncoderMode {
            BrotliEncoderMode(rawValue: rawValue)
        }
    }
}

public extension Brotli.Mode {
    static let `default`: Self = .generic
}

private extension Brotli.Mode {
    static let _generic = BROTLI_MODE_GENERIC.rawValue
    static let _text = BROTLI_MODE_TEXT.rawValue
    static let _font = BROTLI_MODE_FONT.rawValue
    static let _default = BROTLI_MODE_GENERIC.rawValue
}
