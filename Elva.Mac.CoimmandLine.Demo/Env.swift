//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation
import Elva

struct Env: Environment {
    static func log(logFlag: LogFlag, message: CustomStringConvertible?, filename: String, function: String, line: Int) {
        print(message?.description ?? "")
    }
}
