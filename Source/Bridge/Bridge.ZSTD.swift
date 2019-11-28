//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_silgen_name("ZSTD_GetLevel")
func ZSTD_GetLevel(_ min: UnsafeMutablePointer<UInt32>, _ max: UnsafeMutablePointer<UInt32>)

@_silgen_name("ZSTD_CompressFile")
func ZSTD_compressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>, _ level: UInt32) -> Int32

@_silgen_name("ZSTD_DecompressFile")
func ZSTD_decompressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>) -> Int32