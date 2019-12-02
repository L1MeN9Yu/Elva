//
//  ZSTD.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/28.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef ZSTD_h
#define ZSTD_h

__attribute__((nonnull(1, 2), used))
extern void ZSTD_GetLevel(unsigned int *min, unsigned int *max);

__attribute__((nonnull(1, 2), used))
extern int ZSTD_CompressFile(const char *inputFile, const char *outputFile, unsigned int level);

__attribute__((used))
extern int ZSTD_CompressData(const void *inputData, size_t inputSize, unsigned int level, void **outputData, size_t *outputSize);

__attribute__((used))
extern int ZSTD_DecompressData(const void *inputData, size_t inputSize, void **outputData, size_t *outputSize);

__attribute__((nonnull(1, 2), used))
extern int ZSTD_DecompressFile(const char *inputFile, const char *outputFile);

#endif /* ZSTD_h */
