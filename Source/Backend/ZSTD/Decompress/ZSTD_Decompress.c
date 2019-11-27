//
//  Decompress.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <zstd.h>
#include "ZSTD_Checker.h"
#include "File.h"
#include "ZSTD_Decompress.h"

__attribute__((used))
int ZSTD_decompressFile(const char *inputFile, const char *outputFile) {
    FILE *const fileIn = try_fopen(inputFile, "rb");
    size_t const buffInSize = ZSTD_DStreamInSize();
    void *const buffIn = try_malloc(buffInSize);
    FILE *const fileOut = try_fopen(outputFile, "wb");
    size_t const buffOutSize = ZSTD_DStreamOutSize();  /* Guarantee to successfully flush at least one complete compressed block in all circumstances. */
    void *const buffOut = try_malloc(buffOutSize);

    ZSTD_DCtx *const decompressContext = ZSTD_createDCtx();
    if (decompressContext == NULL) {
        LogCritical("ZSTD_createDCtx() failed!");
        return 1;
    }

    /* This loop assumes that the input file is one or more concatenated zstd
     * streams. This example won't work if there is trailing non-zstd data at
     * the end, but streaming decompression in general handles this case.
     * ZSTD_decompressStream() returns 0 exactly when the frame is completed,
     * and doesn't consume input after the frame.
     */
    size_t const toRead = buffInSize;
    size_t read;
    size_t lastRet = 0;
    int isEmpty = 1;
    while ((read = try_fread(buffIn, toRead, fileIn))) {
        isEmpty = 0;
        ZSTD_inBuffer input = {buffIn, read, 0};
        /* Given a valid frame, zstd won't consume the last byte of the frame
         * until it has flushed all of the decompressed data of the frame.
         * Therefore, instead of checking if the return code is 0, we can
         * decompress just check if input.pos < input.size.
         */
        while (input.pos < input.size) {
            ZSTD_outBuffer output = {buffOut, buffOutSize, 0};
            /* The return code is zero if the frame is complete, but there may
             * be multiple frames concatenated together. Zstd will automatically
             * reset the context when a frame is complete. Still, calling
             * ZSTD_DCtx_reset() can be useful to reset the context to a clean
             * state, for instance if the last decompression call returned an
             * error.
             */
            size_t const ret = ZSTD_decompressStream(decompressContext, &output, &input);
            CHECK_ZSTD(ret);
            try_fwrite(buffOut, output.pos, fileOut);
            lastRet = ret;
        }
    }

    if (isEmpty) {
        LogError("input is empty");
        return 2;
    }

    if (lastRet != 0) {
        /* The last return value from ZSTD_decompressStream did not end on a
         * frame, but we reached the end of the file! We assume this is an
         * error, and the input was truncated.
         */
        LogError("EOF before end of stream: %zu\n", lastRet)
        return 3;
    }

    ZSTD_freeDCtx(decompressContext);
    try_fclose(fileIn);
    try_fclose(fileOut);
    free(buffIn);
    free(buffOut);

    return 0;
}
