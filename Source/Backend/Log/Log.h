//
//  Log.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef Log_h
#define Log_h

typedef enum LogFlag {
    trace = 0,
    debug,
    info,
    warning,
    error,
    critical,
} LogFlag;

typedef void (*LogCallback)(LogFlag flag, const char *file, const char *function, int line, const char *message);

void registerLogCallback(LogCallback logCallback);

void elvaLog(LogFlag flag, const char *file, const char *function, int line, const char *format, ...);

#define LogMacro(flag, fmt, ...) \
do{                                                                             \
    elvaLog(flag,__FILE__,__PRETTY_FUNCTION__,__LINE__,fmt,##__VA_ARGS__);      \
}while(0);

#define LogTrace(fmt, ...)   LogMacro(0,fmt, ##__VA_ARGS__)
#define LogDebug(fmt, ...)   LogMacro(1,fmt, ##__VA_ARGS__)
#define LogInfo(fmt, ...)   LogMacro(2,fmt, ##__VA_ARGS__)
#define LogWarning(fmt, ...)   LogMacro(3,fmt, ##__VA_ARGS__)
#define LogError(fmt, ...)   LogMacro(4,fmt, ##__VA_ARGS__)
#define LogCritical(fmt, ...)   LogMacro(5,fmt, ##__VA_ARGS__)

const char *PrintablePath(const char *path);

#endif /* Log_h */
