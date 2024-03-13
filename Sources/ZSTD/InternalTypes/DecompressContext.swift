//
// Created by mengyu.li on 2024/2/6.
//

@_implementationOnly import Elva_zstd

final class DecompressContext {
    let pointer: OpaquePointer

    init() throws {
        guard let pointer: OpaquePointer = ZSTD_createDCtx() else { throw ZSTD.Error.decoderCreate }
        self.pointer = pointer
    }

    deinit {
        ZSTD_freeDCtx(pointer)
    }
}

extension DecompressContext {
    func set(parameters: [ZSTD.DecompressOption.Parameter]) throws {
        for parameter in parameters {
            switch parameter {
            case .windowLogMax(let value):
                let result: Int = ZSTD_DCtx_setParameter(pointer, ZSTD_d_windowLogMax, value)
                if ZSTD.Error.isError(result) { throw ZSTD.Error.setParameter(code: result) }
            }
        }
    }

    func load(dictionary: ZSTD.Dictionary) throws {
        let result = try ZSTD_DCtx_loadDictionary(pointer, dictionary.pointer, dictionary.size)
        if ZSTD.Error.isError(result) { throw ZSTD.Error.loadDictionary(code: result) }
    }
}
