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
