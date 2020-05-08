//
// Created by Mengyu Li on 2019/9/25.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

public struct Environment { private init() {} }

public extension Environment {
    typealias Log = (_ logFlag: LogFlag, _ message: CustomStringConvertible?, _ filename: String, _ function: String, _ line: Int) -> Void
}

public extension Environment {
    static var log: Log? = nil

    static func register(log: Log?) {
        self.log = log
    }
}