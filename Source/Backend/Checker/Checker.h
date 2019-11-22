//
//  Checker.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef Checker_h
#define Checker_h

#include "Log.h"

/*! CHECK_ZSTD
 * Check the zstd error code and die if an error occurred after printing a
 * message.
 */
#define CHECK_ZSTD(fn, ...)                                     \
do {                                                            \
    size_t const err = (fn);                                    \
    LogCritical("%s", ZSTD_getErrorName(err));                  \
} while (0)


int clampCompressLevel(int compressLevel);

#endif /* Checker_h */
