//
//  Checker.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include "ZSTD_Checker.h"
#include <zstd.h>

int minCompressLevel(int minCompressLevel) {
    return minCompressLevel < ZSTD_minCLevel() ? ZSTD_minCLevel() : minCompressLevel;
}

int maxCompressLevel(int maxCompressLevel) {
    return maxCompressLevel > ZSTD_maxCLevel() ? ZSTD_maxCLevel() : maxCompressLevel;
}

int clampCompressLevel(int compressLevel) {
    return maxCompressLevel(minCompressLevel(compressLevel));
}
