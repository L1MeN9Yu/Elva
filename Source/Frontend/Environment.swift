//
// Created by Mengyu Li on 2019/9/2.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

public protocol Environment {
    static func log(logFlag: LogFlag, message: CustomStringConvertible?, filename: String, function: String, line: Int)
}

