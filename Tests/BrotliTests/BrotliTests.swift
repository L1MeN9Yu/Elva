//
// Created by Mengyu Li on 2021/9/28.
//

@testable import Brotli
import Foundation
import XCTest

final class BrotliTests: XCTestCase {
    func testBrotliFile() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let output = des.appendingPathComponent("content.json.br")
        try Brotli.compress(inputFile: input, outputFile: output)
        let decompressOutput = des.appendingPathComponent("content.decompress.json")
        try Brotli.decompress(inputFile: output, outputFile: decompressOutput)
    }

    func testBrotliData() throws {
        guard let originalData = "带的2j1儿科2e🤣😊😗都去啊发到你9219额1561".data(using: .utf8) else { fatalError() }
        print("\(originalData.count)")
        let data = try Brotli.compress(data: originalData)
        print("\(data.count)")
        do {
            let data = try Brotli.decompress(data: data)
            print("\(data.count)")
            let string = String(data: data, encoding: .utf8)
            print("\(String(describing: string))")
        }
    }
}
