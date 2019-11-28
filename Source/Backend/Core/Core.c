//
//  Core.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/21.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include "Core.h"
#include <zstd/zstd.h>
#include <brotli/version.h>

static void show_zstd_version(void) {
    LogTrace("zstd version : %s", ZSTD_versionString());
}

static void show_brotli_version(void) {
    unsigned int major = BROTLI_VERSION >> 24;
    unsigned int minor = (BROTLI_VERSION & 0x00FFFFFF) >> 12;
    unsigned int patch = BROTLI_VERSION & 0x00000FFF;
    LogTrace("brotli version : %u.%u.%u", major, minor, patch);
}

__attribute__((used))
void elva_setup(LogCallback logCallBack) {
    registerLogCallback(logCallBack);
    show_zstd_version();
    show_brotli_version();
}
