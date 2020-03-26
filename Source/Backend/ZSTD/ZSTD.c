//
//  ZSTD.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/28.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include <zstd/zstd.h>
#include "ZSTD.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include "File.h"
#include "Log.h"

#define SUCCEED 0
#define INVALID_PARAMETER 1
#define MEMORY_ERROR 2
#define COMPRESS_ERROR 3
#define DECOMPRESS_ERROR 4

__attribute__((used))
int ZSTD_CompressFile(const char *inputFile, const char *outputFile, unsigned int level) {
    FILE *const fileIn = try_fopen(inputFile, "rb");
    FILE *const fileOut = try_fopen(outputFile, "wb");

    size_t const buffInSize = ZSTD_CStreamInSize();
    void *const buffIn = try_malloc(buffInSize);
    size_t const buffOutSize = ZSTD_CStreamOutSize();
    void *const buffOut = try_malloc(buffOutSize);

    ZSTD_CCtx *const compressContext = ZSTD_createCCtx();
    if (compressContext == NULL) {
        LogCritical("ZSTD_createCCtx() failed!");
        return 1;
    }

    {
        size_t const err = ZSTD_CCtx_setParameter(compressContext, ZSTD_c_compressionLevel, level);
        if (ZSTD_isError(err)) {
            LogCritical("check result : code = %d msg : %s", err, ZSTD_getErrorName(err));
            return 1;
        }
    }

    {
        size_t const err = ZSTD_CCtx_setParameter(compressContext, ZSTD_c_checksumFlag, 1);
        if (ZSTD_isError(err)) {
            LogCritical("check result : code = %d msg : %s", err, ZSTD_getErrorName(err));
        }
    }

    size_t const toRead = buffInSize;
    for (;;) {
        size_t read = try_fread(buffIn, toRead, fileIn);
        int const lastChunk = (read < toRead);
        ZSTD_EndDirective const mode = lastChunk ? ZSTD_e_end : ZSTD_e_continue;
        ZSTD_inBuffer input = {buffIn, read, 0};
        int finished;
        do {
            ZSTD_outBuffer output = {buffOut, buffOutSize, 0};
            size_t const remaining = ZSTD_compressStream2(compressContext, &output, &input, mode);
            if (ZSTD_isError(remaining)) {
                LogCritical("check result : code = %d msg : %s", remaining, ZSTD_getErrorName(remaining));
            }
            try_fwrite(buffOut, output.pos, fileOut);
            finished = lastChunk ? (remaining == 0) : (input.pos == input.size);
        } while (!finished);
        if (input.pos != input.size) {
            LogCritical("Impossible: zstd only returns 0 when the input is completely consumed!");
            return 1;
        }

        if (lastChunk) {
            break;
        }
    }

    ZSTD_freeCCtx(compressContext);
    try_fclose(fileOut);
    try_fclose(fileIn);
    free(buffIn);
    free(buffOut);

    return SUCCEED;
}

__attribute__((used))
int ZSTD_DecompressFile(const char *inputFile, const char *outputFile) {
    FILE *const fileIn = try_fopen(inputFile, "rb");
    size_t const buffInSize = ZSTD_DStreamInSize();
    void *const buffIn = try_malloc(buffInSize);
    FILE *const fileOut = try_fopen(outputFile, "wb");
    size_t const buffOutSize = ZSTD_DStreamOutSize();
    void *const buffOut = try_malloc(buffOutSize);

    ZSTD_DCtx *const decompressContext = ZSTD_createDCtx();
    if (decompressContext == NULL) {
        LogCritical("ZSTD_createDCtx() failed!");
        return 1;
    }

    size_t const toRead = buffInSize;
    size_t read;
    size_t lastRet = 0;
    int isEmpty = 1;
    while ((read = try_fread(buffIn, toRead, fileIn))) {
        isEmpty = 0;
        ZSTD_inBuffer input = {buffIn, read, 0};

        while (input.pos < input.size) {
            ZSTD_outBuffer output = {buffOut, buffOutSize, 0};

            size_t const ret = ZSTD_decompressStream(decompressContext, &output, &input);
            if (ZSTD_isError(ret)) {
                LogCritical("check result : code = %d msg : %s", ret, ZSTD_getErrorName(ret));
            }
            try_fwrite(buffOut, output.pos, fileOut);
            lastRet = ret;
        }
    }

    if (isEmpty) {
        LogError("input is empty");
        return 2;
    }

    if (lastRet != 0) {
        LogError("EOF before end of stream: %zu\n", lastRet);
        return 3;
    }

    ZSTD_freeDCtx(decompressContext);
    try_fclose(fileIn);
    try_fclose(fileOut);
    free(buffIn);
    free(buffOut);

    return SUCCEED;
}

__attribute__((used))
int ZSTD_CompressData(const void *inputData, size_t inputSize, unsigned int level, void **outputData, size_t *outputSize) {
    if (inputData == NULL || outputSize == NULL) {return INVALID_PARAMETER;}

    size_t const cBuffSize = ZSTD_compressBound(inputSize);
    void *const cBuff = malloc(cBuffSize);

    if (cBuff == NULL) {return MEMORY_ERROR;}

    size_t const cSize = ZSTD_compress(cBuff, cBuffSize, inputData, inputSize, level);

    if (ZSTD_isError(cSize)) {
        LogError("Compress Error : %s", ZSTD_getErrorName(cSize));
        return COMPRESS_ERROR;
    }

    *outputData = cBuff;
    *outputSize = cSize;

    return SUCCEED;
}

__attribute__((used))
int ZSTD_DecompressData(const void *inputData, size_t inputSize, void **outputData, size_t *outputSize) {
    if (inputData == NULL || outputSize == NULL) {return INVALID_PARAMETER;}

    unsigned long long const rSize = ZSTD_getFrameContentSize(inputData, inputSize);
    if (rSize == ZSTD_CONTENTSIZE_ERROR) {
        LogError("data is not compressed by zstd");
        return INVALID_PARAMETER;
    }
    if (rSize == ZSTD_CONTENTSIZE_UNKNOWN) {
        LogError("original size unknown");
        return INVALID_PARAMETER;
    }

    void *const rBuff = malloc((size_t) rSize);
    if (rBuff == NULL) {return MEMORY_ERROR;}

    size_t const dSize = ZSTD_decompress(rBuff, (size_t)rSize, inputData, inputSize);

    if (ZSTD_isError(dSize)) {
        LogError("Compress Error : %s", ZSTD_getErrorName(dSize));
        return DECOMPRESS_ERROR;
    }

    if (dSize != rSize) {
        LogError("Size check failed");
        return DECOMPRESS_ERROR;
    }

    *outputData = rBuff;
    *outputSize = dSize;

    return SUCCEED;
}

__attribute__((used))
void ZSTD_GetLevel(unsigned int *min, unsigned int *max) {
    *min = (unsigned int) ZSTD_minCLevel();
    *max = (unsigned int) ZSTD_maxCLevel();
}
