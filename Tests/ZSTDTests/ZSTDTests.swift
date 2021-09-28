import Foundation
import XCTest
@testable import ZSTD

final class ZSTDTests: XCTestCase {
    func testZSTDFile() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let output = des.appendingPathComponent("content.json.zstd")
        try ZSTD.compress(inputFile: input, outputFile: output)
        let decompressOutput = des.appendingPathComponent("content.decompress.json")
        try ZSTD.decompress(inputFile: output, outputFile: decompressOutput)
    }

    func testZSTDData() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let originalData = try Data(contentsOf: input)
        print("\(originalData.count)")
        let data = try ZSTD.compress(data: originalData)
        do {
            print("\(data.count)")
            let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let input = des.appendingPathComponent("content.json.zstd")
            try data.write(to: input)
            do {
                let data = try ZSTD.decompress(data: data)
                print("\(data.count)")
                let string = String(data: data, encoding: .utf8)
                print("\(String(describing: string))")
            }
        }
    }
}
