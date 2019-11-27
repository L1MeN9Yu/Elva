//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_silgen_name("ZSTD_compressFile")
func ZSTD_compressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>, _ level: Int32) -> Int32

@_silgen_name("ZSTD_decompressFile")
func ZSTD_decompressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>) -> Int32