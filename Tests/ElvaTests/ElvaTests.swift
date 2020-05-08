import XCTest
@testable import Elva
import Foundation

final class ElvaTests: XCTestCase {

    func testBrotliFile() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let output = des.appendingPathComponent("content.json.br")
        Brotli.compress(inputFile: input, outputFile: output)
        let decompressOutput = des.appendingPathComponent("content.decompress.json")
        Brotli.decompress(inputFile: output, outputFile: decompressOutput)
    }

    func testBrotliData() {
        guard let originalData = "带的2j1儿科2e🤣😊😗都去啊发到你9219额1561".data(using: .utf8) else { fatalError() }
        print("\(originalData.count)")
        let compressResult = Brotli.compress(data: originalData)
        switch compressResult {
        case .failure(let error): print("\(error)")
        case .success(let data):
            print("\(data.count)")
            let decompressResult = Brotli.decompress(data: data)
            switch decompressResult {
            case .failure(let error): print("\(error)")
            case .success(let data):
                print("\(data.count)")
                let string = String(data: data, encoding: .utf8)
                print("\(string)")
            }
        }
    }

    func testZSTDFile() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let output = des.appendingPathComponent("content.json.zstd")
        ZSTD.compress(inputFile: input, outputFile: output)
        let decompressOutput = des.appendingPathComponent("content.decompress.json")
        ZSTD.decompress(inputFile: output, outputFile: decompressOutput)
    }

    func testZSTDData() throws {
        let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let input = des.appendingPathComponent("content.json")
        let originalData = try Data(contentsOf: input) 
        print("\(originalData.count)")
        let compressResult = ZSTD.compress(data: originalData)
        switch compressResult {
        case .failure(let error): print("\(error)")
        case .success(let data):
            print("\(data.count)")
            let des = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let input = des.appendingPathComponent("content.json.zstd")
            try data.write(to: input)
            let decompressResult = ZSTD.decompress(data: data)
            switch decompressResult {
            case .failure(let error): print("\(error)")
            case .success(let data):
                print("\(data.count)")
                let string = String(data: data, encoding: .utf8)
                print("\(string)")
            }
        }
    }

    static var allTests = [
        ("testExample", testBrotliFile),
    ]
}
