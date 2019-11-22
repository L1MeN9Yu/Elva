//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

@_silgen_name("elva_compressFile")
func elva_compressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>, _ level: Int32) -> Int32