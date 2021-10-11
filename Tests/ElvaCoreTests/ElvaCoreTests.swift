//
// Created by Mengyu Li on 2021/9/28.
//

@testable import ElvaCore
import XCTest

final class ElvaCoreTests: XCTestCase {
    func testBufferedMemoryStreamReadAll() {
        let inputMemory = BufferedMemoryStream(startData: Self.content)
        let outputMemory = BufferedMemoryStream()

        XCTAssertNotEqual(inputMemory, outputMemory)

        XCTAssertEqual(inputMemory.size, Self.content.count)
        XCTAssertEqual(inputMemory.representation, Self.content)

        let writeCount = inputMemory.readAll(sink: outputMemory)

        XCTAssertEqual(writeCount, Self.content.count)
        XCTAssertEqual(outputMemory.representation, Self.content)
        XCTAssertEqual(outputMemory, inputMemory)
        XCTAssertEqual(outputMemory.representation, inputMemory.representation)
    }

    func testBufferedMemoryStreamRead() {
        let constWriteCount = 2
        XCTAssert(constWriteCount < Self.content.count)

        let inputMemory = BufferedMemoryStream(startData: Self.content)
        let outputMemory = BufferedMemoryStream()

        XCTAssertNotEqual(inputMemory, outputMemory)

        XCTAssertEqual(inputMemory.size, Self.content.count)
        XCTAssertEqual(inputMemory.representation, Self.content)

        let writeBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: constWriteCount)
        defer { writeBuffer.deallocate() }
        let writeCount = inputMemory.read(writeBuffer, length: constWriteCount)
        XCTAssertEqual(writeCount, constWriteCount)
        let writeData = Data(Array(UnsafeMutableBufferPointer(start: writeBuffer, count: constWriteCount)))
        XCTAssertEqual(writeData, Self.content[0..<constWriteCount])
    }

    func testBufferedMemoryStreamWrite() {
        let outputMemory = BufferedMemoryStream()
        let writeCount = outputMemory.write([UInt8](Self.content), length: Self.content.count)

        XCTAssertEqual(writeCount, Self.content.count)
        XCTAssertEqual(outputMemory.representation, Self.content)
    }

    func testFileWriteStream() throws {
        let url = URL(fileURLWithPath: "elva_core")
        let fileWriteStream = try FileWriteStream(path: url.path)
        let written = fileWriteStream.write([UInt8](Self.content), length: Self.content.count)
        XCTAssertEqual(written, Self.content.count)
        fileWriteStream.close()
        let fileData = try Data(contentsOf: url)
        XCTAssertEqual(fileData, Self.content)
        try FileManager.default.removeItem(at: url)
    }

    func testFileReadStream() throws {
        let constWriteCount = 2
        let url = URL(fileURLWithPath: "elva_core")
        try Self.content.write(to: url)
        let fileReadStream = try FileReadStream(path: url.path)
        let writeBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: constWriteCount)
        defer { writeBuffer.deallocate() }
        let read = fileReadStream.read(writeBuffer, length: constWriteCount)
        XCTAssertEqual(read, constWriteCount)
        fileReadStream.close()
        let writeData = Data(Array(UnsafeMutableBufferPointer(start: writeBuffer, count: constWriteCount)))
        XCTAssertEqual(writeData, Self.content[0..<constWriteCount])
        try FileManager.default.removeItem(at: url)
    }
}

private extension ElvaCoreTests {
    static let content = Data("Elva".utf8)
}
