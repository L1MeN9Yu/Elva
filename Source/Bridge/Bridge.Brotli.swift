//
// Created by Mengyu Li on 2019/11/28.
// Copyright (c) 2019 Mengyu Li. All rights reserved.
//

import Foundation

@_silgen_name("Brotli_GetMode")
func Brotli_GetMode(_ generic: UnsafeMutablePointer<UInt32>, _ text: UnsafeMutablePointer<UInt32>, _ font: UnsafeMutablePointer<UInt32>, _ def: UnsafeMutablePointer<UInt32>!)

@_silgen_name("Brotli_GetQuality")
func Brotli_GetQuality(_ min: UnsafeMutablePointer<UInt32>, _ max: UnsafeMutablePointer<UInt32>, _ def: UnsafeMutablePointer<UInt32>)

@_silgen_name("Brotli_GetWindowBits")
func Brotli_GetWindowBits(_ min: UnsafeMutablePointer<UInt32>, _ max: UnsafeMutablePointer<UInt32>, _ large_max: UnsafeMutablePointer<UInt32>, _ def: UnsafeMutablePointer<UInt32>)

@_silgen_name("Brotli_GetInputBlockBits")
func Brotli_GetInputBlockBits(_ min: UnsafeMutablePointer<UInt32>, _ max: UnsafeMutablePointer<UInt32>)

@_silgen_name("Brotli_CompressData")
func Brotli_CompressData(_ inputData: UnsafeRawPointer, _ inputSize: Int, _ mode: UInt32, _ window_bits: UInt32, _ quality: UInt32, _ outputData: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ outputSize: UnsafeMutablePointer<Int>) -> Int32

@_silgen_name("Brotli_DecompressData")
func Brotli_DecompressData(_ inputData: UnsafeRawPointer, _ inputSize: Int, _ outputData: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ outputSize: UnsafeMutablePointer<Int>, _ bufferCapacity: Int) -> Int32

@_silgen_name("Brotli_CompressFile")
func Brotli_CompressFile(_ input_path: UnsafePointer<Int8>, _ output_path: UnsafePointer<Int8>, _ mode: UInt32, _ window_bits: UInt32, _ quality: UInt32) -> Int32

@_silgen_name("Brotli_DecompressFile")
func Brotli_DecompressFile(_ input_path: UnsafePointer<Int8>, _ output_path: UnsafePointer<Int8>) -> Int32