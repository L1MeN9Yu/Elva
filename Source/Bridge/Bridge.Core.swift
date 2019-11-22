//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

typealias LogCallback = @convention(c) (_ flag: Int32, _ file: UnsafePointer<Int8>, _ function: UnsafePointer<Int8>, _ line: Int32, _ message: UnsafePointer<Int8>) -> Void

@_silgen_name("elva_setup")
func elva_setup(_ logCallBack: LogCallback)