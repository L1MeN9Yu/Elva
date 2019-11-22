//
// Created by Mengyu Li on 2019/11/22.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

@_silgen_name("elva_decompressFile")
func elva_decompressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>) -> Int32