//
//  File.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <errno.h>
#include <sys/stat.h>
#include <utime.h>
#include <zconf.h>
#include <fcntl.h>
#include "File.h"
#include "Log.h"

FILE *try_fopen(const char *filename, const char *instruction) {
    FILE *const inFile = fopen(filename, instruction);
    if (inFile) return inFile;
    LogError("File Open Error : %s", filename);
    return NULL;
}

void *try_malloc(size_t size) {
    void *const buff = malloc(size);
    if (buff) return buff;
    LogError("Memory Alloc Error : %s");
    return NULL;
}

size_t try_fread(void *buffer, size_t sizeToRead, FILE *file) {
    size_t const readSize = fread(buffer, 1, sizeToRead, file);
    if (readSize == sizeToRead) return readSize;   /* good */
    if (feof(file)) return readSize;   /* good, reached end of file */
    LogError("File Read Error");
    return 0;
}

size_t try_fwrite(const void *buffer, size_t sizeToWrite, FILE *file) {
    size_t const writtenSize = fwrite(buffer, 1, sizeToWrite, file);
    if (writtenSize == sizeToWrite) return sizeToWrite;   /* good */
    LogError("File Write Error");
    return 0;
}

void try_fclose(FILE *file) {
    if (!fclose(file)) {return;};
    LogError("File Close Error");
}

//-------------------------------------//

bool OpenInputFile(const char *input_path, FILE **file) {
    *file = NULL;

    *file = fopen(input_path, "rb");
    if (!*file) {
        LogError("failed to open input file [%s]: %s\n",
                PrintablePath(input_path), strerror(errno));
        return false;
    }
    return true;
}

bool OpenOutputFile(const char *output_path, FILE **file, bool force) {
    int fd;
    *file = NULL;

    fd = open(output_path, O_CREAT | (force ? 0 : O_EXCL) | O_WRONLY | O_TRUNC,
            S_IRUSR | S_IWUSR);
    if (fd < 0) {
        LogError("failed to open output file [%s]: %s\n",
                PrintablePath(output_path), strerror(errno));
        return false;
    }
    *file = fdopen(fd, "wb");
    if (!*file) {
        LogError("failed to open output file [%s]: %s\n",
                PrintablePath(output_path), strerror(errno));
        return false;
    }
    return true;
}

void CopyStat(const char *input_path, const char *output_path) {
    struct stat statbuf;
    struct utimbuf times;
    int res;
    if (input_path == 0 || output_path == 0) {
        return;
    }
    if (stat(input_path, &statbuf) != 0) {
        return;
    }
    times.actime = statbuf.st_atime;
    times.modtime = statbuf.st_mtime;
    utime(output_path, &times);
    res = chmod(output_path, (mode_t) (statbuf.st_mode & (S_IRWXU | S_IRWXG | S_IRWXO)));
    if (res != 0) {
        LogError("setting access bits failed for [%s]: %s\n",
                PrintablePath(output_path), strerror(errno));
    }
    res = chown(output_path, (uid_t) -1, statbuf.st_gid);
    if (res != 0) {
        LogError("setting group failed for [%s]: %s\n",
                PrintablePath(output_path), strerror(errno));
    }
    res = chown(output_path, statbuf.st_uid, (gid_t) -1);
    if (res != 0) {
        LogError("setting user failed for [%s]: %s\n",
                PrintablePath(output_path), strerror(errno));
    }
}
