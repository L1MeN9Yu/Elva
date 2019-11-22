//
// Created by Mengyu Li on 2019/9/2.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public enum LogFlag {
    case trace
    case debug
    case info
    case warning
    case error
    case critical
    case off

    init?(unsignedIntValue: CUnsignedInt) {
        switch unsignedIntValue {
        case 0:
            self = .trace
        case 1:
            self = .debug
        case 2:
            self = .info
        case 3:
            self = .warning
        case 4:
            self = .error
        case 5:
            self = .critical
        case 6:
            self = .off
        default:
            return nil
        }
    }
}