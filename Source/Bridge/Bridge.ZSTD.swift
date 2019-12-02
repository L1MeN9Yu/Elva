//
// Created by Mengyu Li on 2019/11/27.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

@_silgen_name("ZSTD_GetLevel")
func ZSTD_GetLevel(_ min: UnsafeMutablePointer<UInt32>, _ max: UnsafeMutablePointer<UInt32>)

@_silgen_name("ZSTD_CompressFile")
func ZSTD_CompressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>, _ level: UInt32) -> Int32

@_silgen_name("ZSTD_CompressData")
func ZSTD_CompressData(_ inputData: UnsafeRawPointer, _ inputSize: Int, _ level: UInt32, _ outputData: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ outputSize: UnsafeMutablePointer<Int>) -> Int32

@_silgen_name("ZSTD_DecompressData")
func ZSTD_DecompressData(_ inputData: UnsafeRawPointer, _ inputSize: Int, _ outputData: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ outputSize: UnsafeMutablePointer<Int>) -> Int32

@_silgen_name("ZSTD_DecompressFile")
func ZSTD_DecompressFile(_ inputFile: UnsafePointer<Int8>, _ outputFile: UnsafePointer<Int8>) -> Int32