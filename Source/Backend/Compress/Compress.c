//
//  Compress.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/21.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <zstd.h>
#include "Checker.h"
#include "File.h"
#include "Compress.h"

int elva_compressFile(const char *inputFile, const char *outputFile, int level) {
    /* Open the input and output files. */
    FILE *const fileIn = try_fopen(inputFile, "rb");
    FILE *const fileOut = try_fopen(outputFile, "wb");
    /* Create the input and output buffers.
     * They may be any size, but we recommend using these functions to size them.
     * Performance will only suffer significantly for very tiny buffers.
     */
    size_t const buffInSize = ZSTD_CStreamInSize();
    void *const buffIn = try_malloc(buffInSize);
    size_t const buffOutSize = ZSTD_CStreamOutSize();
    void *const buffOut = try_malloc(buffOutSize);

    /* Create the context. */
    ZSTD_CCtx *const compressContext = ZSTD_createCCtx();
    if (compressContext == NULL) {
        LogCritical("ZSTD_createCCtx() failed!");
        return 1;
    }

    /* Set any parameters you want.
     * Here we set the compression level, and enable the checksum.
     */
    CHECK_ZSTD(ZSTD_CCtx_setParameter(compressContext, ZSTD_c_compressionLevel, level));
    CHECK_ZSTD(ZSTD_CCtx_setParameter(compressContext, ZSTD_c_checksumFlag, 1));

    /* This loop read from the input file, compresses that entire chunk,
     * and writes all output produced to the output file.
     */
    size_t const toRead = buffInSize;
    for (;;) {
        size_t read = try_fread(buffIn, toRead, fileIn);
        /* Select the flush mode.
         * If the read may not be finished (read == toRead) we use
         * ZSTD_e_continue. If this is the last chunk, we use ZSTD_e_end.
         * Zstd optimizes the case where the first flush mode is ZSTD_e_end,
         * since it knows it is compressing the entire source in one pass.
         */
        int const lastChunk = (read < toRead);
        ZSTD_EndDirective const mode = lastChunk ? ZSTD_e_end : ZSTD_e_continue;
        /* Set the input buffer to what we just read.
         * We compress until the input buffer is empty, each time flushing the
         * output.
         */
        ZSTD_inBuffer input = {buffIn, read, 0};
        int finished;
        do {
            /* Compress into the output buffer and write all of the output to
             * the file so we can reuse the buffer next iteration.
             */
            ZSTD_outBuffer output = {buffOut, buffOutSize, 0};
            size_t const remaining = ZSTD_compressStream2(compressContext, &output, &input, mode);
            CHECK_ZSTD(remaining);
            try_fwrite(buffOut, output.pos, fileOut);
            /* If we're on the last chunk we're finished when zstd returns 0,
             * which means its consumed all the input AND finished the frame.
             * Otherwise, we're finished when we've consumed all the input.
             */
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

    return 0;
}