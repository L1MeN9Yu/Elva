//
// Created by Mengyu Li on 2020/2/26.
//

struct Logger { private init() {} }

extension Logger {
    static func trace(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.trace, message, filename, function, line)
    }

    static func debug(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.debug, message, filename, function, line)
    }

    static func info(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.info, message, filename, function, line)
    }

    static func warn(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.warn, message, filename, function, line)
    }

    static func error(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.error, message, filename, function, line)
    }

    static func crit(_ message: CustomStringConvertible?, filename: String = #file, function: String = #function, line: Int = #line) {
        Environment.log?(.crit, message, filename, function, line)
    }
}
