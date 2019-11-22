//
//  Elva.swift
//  Elva
//
//  Created by Mengyu Li on 2019/11/21.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//


private(set) var __environment: Environment.Type?

public func setup(environment: Environment.Type) {
    __environment = environment
    elva_setup { flag, file, function, line, message in
        guard let logFlag = LogFlag(unsignedIntValue: CUnsignedInt(flag)),
              let file = String(cString: file, encoding: .utf8),
              let function = String(cString: function, encoding: .utf8),
              let message = String(cString: message, encoding: .utf8) else { return }

        __environment?.log(logFlag: logFlag, message: message, filename: file, function: function, line: Int(line))
    }
}
