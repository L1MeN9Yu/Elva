//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

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

        public static var `default`: Mode {
            switch Self._default {
            case self.generic.rawValue:
                return Mode.generic
            case self.text.rawValue:
                return Mode.text
            case self.font.rawValue:
                return Mode.font
            default:
                return Mode.generic
            }
        }
    }
}

private extension Brotli.Mode {
    static var _generic: UInt32 = 0
    static var _text: UInt32 = 0
    static var _font: UInt32 = 0
    static var _default: UInt32 = 0
}

internal extension Brotli.Mode {
    static func register() {
        Brotli_GetMode(&_generic, &_text, &_font, &_default)
    }
}