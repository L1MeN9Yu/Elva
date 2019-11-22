//
//  Core.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/21.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include "Core.h"
#include <zstd.h>

void setup(LogCallback logCallBack) {
    registerLogCallback(logCallBack);
    LogDebug("zstd version : %s", ZSTD_versionString());
}
