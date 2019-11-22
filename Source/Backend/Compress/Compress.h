//
//  Compress.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/21.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef Compress_h
#define Compress_h

__attribute__((nonnull(1, 2)))
extern int elva_compressFile(const char *inputFile, const char *outputFile, int level);

#endif /* Compress_h */
