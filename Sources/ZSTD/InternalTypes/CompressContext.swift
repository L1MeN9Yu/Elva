//
// Created by mengyu.li on 2024/2/6.
//

@_implementationOnly import Elva_zstd

final class CompressContext {
    let pointer: OpaquePointer

    init() throws {
        guard let pointer: OpaquePointer = ZSTD_createCCtx() else { throw ZSTD.Error.encoderCreate }
        self.pointer = pointer
    }

    deinit {
        ZSTD_freeCCtx(pointer)
    }
}

extension CompressContext {
    func set(level: ZSTD.Level) throws {
        let result: Int = ZSTD_CCtx_setParameter(pointer, ZSTD_c_compressionLevel, level.rawValue)
        if ZSTD.Error.isError(result) { throw ZSTD.Error.setParameter(description: ZSTD.Error.errorName(code: result)) }
    }

    func load(dictionary: ZSTD.Dictionary) throws {
        let result: Int = try ZSTD_CCtx_loadDictionary(pointer, dictionary.pointer, dictionary.size)
        if ZSTD.Error.isError(result) { throw ZSTD.Error.loadDictionary(description: ZSTD.Error.errorName(code: result)) }
    }
}
