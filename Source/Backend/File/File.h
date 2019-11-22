//
//  File.h
//  Elva
//
//  Created by Mengyu Li on 2019/11/22.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#ifndef File_h
#define File_h


FILE *try_fopen(const char *filename, const char *instruction);

size_t try_fread(void *buffer, size_t sizeToRead, FILE *file);

size_t try_fwrite(const void *buffer, size_t sizeToWrite, FILE *file);

void *try_malloc(size_t size);

void try_fclose(FILE *file);

#endif /* File_h */
