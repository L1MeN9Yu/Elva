//
//  Brotli.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/27.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef Brotli_h
#define Brotli_h

#include <stdint.h>

__attribute__((nonnull(1, 2, 3), used))
extern void Brotli_GetMode(unsigned int *generic, unsigned int *text, unsigned int *font, unsigned int *def);

__attribute__((nonnull(1, 2, 3), used))
extern void Brotli_GetQuality(unsigned int *min, unsigned int *max, unsigned int *def);

__attribute__((nonnull(1, 2, 3, 4), used))
extern void Brotli_GetWindowBits(unsigned int *min, unsigned int *max, unsigned int *large_max, unsigned int *def);

__attribute__((nonnull(1, 2), used))
extern void Brotli_GetInputBlockBits(unsigned int *min, unsigned int *max);

__attribute__((nonnull(1, 2), used))
extern int Brotli_Compress(const char *input_path, const char *output_path, uint32_t mode, uint32_t window_bits, uint32_t quality);

__attribute__((nonnull(1, 2), used))
extern int Brotli_Decompress(const char *input_path, const char *output_path);

#endif /* Brotli_h */
