//
//  Log.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <zconf.h>
#include "Log.h"

#define LOG_MAX_BUF_SIZE 512

static LogCallback __logCallBack = NULL;

void registerLogCallback(LogCallback logCallback) {
    __logCallBack = logCallback;
}

void elvaLog(LogFlag flag, const char *file, const char *function, int line, const char *format, ...) {
    if (__logCallBack) {
        static char buffer[LOG_MAX_BUF_SIZE];
        va_list args;
        va_start(args, format);
        vsnprintf(buffer, LOG_MAX_BUF_SIZE, format, args);
        va_end(args);
        __logCallBack(flag, file, function, line, buffer);
    }
}

const char *PrintablePath(const char *path) {
    return path ? path : "null path";
}
