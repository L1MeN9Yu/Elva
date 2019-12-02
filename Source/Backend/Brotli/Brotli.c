//
//  Brotli.c
//  Elva
//
//  Created by Mengyu Li on 2019/11/27.
//  Copyright © 2019 Mengyu Li. All rights reserved.
//

#include "Brotli.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <brotli/encode.h>
#include <brotli/decode.h>
#include <zconf.h>
#include "File.h"
#include "Log.h"

#define SUCCEED 0
#define INVALID_PARAMETER 1
#define MEMORY_ERROR 2
#define COMPRESS_ERROR 3
#define DECOMPRESS_ERROR 4

__attribute__((used))
void Brotli_GetMode(unsigned int *generic, unsigned int *text, unsigned int *font, unsigned int *def) {
    *generic = BROTLI_MODE_GENERIC;
    *text = BROTLI_MODE_TEXT;
    *font = BROTLI_MODE_FONT;
    *def = BROTLI_DEFAULT_MODE;
}

__attribute__((used))
void Brotli_GetQuality(unsigned int *min, unsigned int *max, unsigned int *def) {
    *min = BROTLI_MIN_QUALITY;
    *max = BROTLI_MAX_QUALITY;
    *def = BROTLI_DEFAULT_QUALITY;
}

__attribute__((used))
void Brotli_GetWindowBits(unsigned int *min, unsigned int *max, unsigned int *large_max, unsigned int *def) {
    *min = BROTLI_MIN_WINDOW_BITS;
    *max = BROTLI_MAX_WINDOW_BITS;
    *large_max = BROTLI_LARGE_MAX_WINDOW_BITS;
    *def = BROTLI_DEFAULT_WINDOW;
}

__attribute__((used))
void Brotli_GetInputBlockBits(unsigned int *min, unsigned int *max) {
    *min = BROTLI_MIN_INPUT_BLOCK_BITS;
    *max = BROTLI_MAX_INPUT_BLOCK_BITS;
}

//-------------------------------------//


static const size_t kFileBufferSize = 1 << 19;

static BROTLI_BOOL HasMoreInput(FILE *file) {
    return feof(file) ? BROTLI_FALSE : BROTLI_TRUE;
}

static BROTLI_BOOL ProvideInput(uint8_t *input, size_t *available_in, const uint8_t **next_in, FILE *file_in, const char *input_path) {
    *available_in = fread(input, 1, kFileBufferSize, file_in);
    *next_in = input;
    if (ferror(file_in)) {
        LogError("failed to read input [%s]: %s\n", PrintablePath(input_path), strerror(errno));
        return BROTLI_FALSE;
    }
    return BROTLI_TRUE;
}

static BROTLI_BOOL WriteOutput(uint8_t *output, uint8_t *next_out, FILE *file_out, const char *output_path) {
    size_t out_size = (size_t) (next_out - output);
    if (out_size == 0) return BROTLI_TRUE;

    fwrite(output, 1, out_size, file_out);
    if (ferror(file_out)) {
        LogError("failed to write output [%s]: %s\n", PrintablePath(output_path), strerror(errno));
        return BROTLI_FALSE;
    }
    return BROTLI_TRUE;
}

static BROTLI_BOOL ProvideOutput(size_t *available_out, uint8_t *output, uint8_t **next_out, FILE *file_out, const char *output_path) {
    if (!WriteOutput(output, *next_out, file_out, output_path)) return BROTLI_FALSE;
    *available_out = kFileBufferSize;
    *next_out = output;
    return BROTLI_TRUE;
}

static BROTLI_BOOL FlushOutput(size_t *available_out, uint8_t *output, uint8_t **next_out, FILE *file_out, const char *output_path) {
    if (!WriteOutput(output, *next_out, file_out, output_path)) return BROTLI_FALSE;
    *available_out = 0;
    return BROTLI_TRUE;
}

static BROTLI_BOOL CloseFiles(const char *input_path, FILE *file_in, FILE *file_out, const char *output_path, BROTLI_BOOL success) {
    BROTLI_BOOL is_ok = BROTLI_TRUE;
    if (file_out) {
        if (!success && output_path) {
            unlink(output_path);
        }
        if (fclose(file_out) != 0) {
            if (success) {
                LogError("fclose failed [%s]: %s\n", PrintablePath(output_path), strerror(errno));
            }
            is_ok = BROTLI_FALSE;
        }

        if (success && is_ok) {
            CopyStat(input_path, output_path);
        }
    }

    if (file_in) {
        if (fclose(file_in) != 0) {
            if (is_ok) {
                LogError("fclose failed [%s]: %s\n",
                        PrintablePath(input_path), strerror(errno));
            }
            is_ok = BROTLI_FALSE;
        }
    }

    return is_ok;
}

__attribute__((used))
int Brotli_CompressFile(const char *input_path, const char *output_path, uint32_t mode, uint32_t window_bits, uint32_t quality) {
    int ret = 0;

    FILE *file_in = NULL;
    ret = OpenInputFile(input_path, &file_in);
    if (ret != true) {return 1;}

    FILE *file_out = NULL;
    ret = OpenOutputFile(output_path, &file_out, true);
    if (ret != true) {return 1;}

    BrotliEncoderState *encoderState = BrotliEncoderCreateInstance(NULL, NULL, NULL);
    if (!encoderState) {return 2;}

    ret = BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_MODE, mode);
    if (ret != BROTLI_TRUE) {return 3;}

    ret = BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_QUALITY, quality);
    if (ret != BROTLI_TRUE) {return 3;}

    ret = BrotliEncoderSetParameter(encoderState, BROTLI_PARAM_LGWIN, window_bits);
    if (ret != BROTLI_TRUE) {return 3;}

    {
        BROTLI_BOOL is_eof = BROTLI_FALSE;

        uint8_t *buffer;
        uint8_t *input;
        uint8_t *output;

        buffer = (uint8_t *) malloc(kFileBufferSize * 2);
        input = buffer;
        output = buffer + kFileBufferSize;
        size_t available_in = 0;
        const uint8_t *next_in = NULL;
        size_t available_out = kFileBufferSize;
        uint8_t *next_out = output;

        for (;;) {
            if (available_in == 0 && !is_eof) {
                if (!ProvideInput(input, &available_in, &next_in, file_in, input_path)) {
                    ret = BROTLI_FALSE;
                    break;
                }
                is_eof = !HasMoreInput(file_in);
            }

            if (!BrotliEncoderCompressStream(encoderState,
                    is_eof ? BROTLI_OPERATION_FINISH : BROTLI_OPERATION_PROCESS,
                    &available_in, &next_in,
                    &available_out, &next_out, NULL)) {
                LogError("failed to compress data [%s]\n", PrintablePath(input_path));
                ret = BROTLI_FALSE;
                break;
            }

            if (available_out == 0) {
                if (!ProvideOutput(&available_out, output, &next_out, file_out, output_path)) {
                    ret = BROTLI_FALSE;
                    break;
                }
            }

            if (BrotliEncoderIsFinished(encoderState)) {
                ret = FlushOutput(&available_out, output, &next_out, file_out, output_path);
                break;
            }
        }
    }

    BrotliEncoderDestroyInstance(encoderState);
    if (!CloseFiles(input_path, file_in, file_out, output_path, ret)) {ret = BROTLI_FALSE;}
    if (ret != BROTLI_TRUE) {
        return 3;
    }

    return 0;
}

__attribute__((used))
int Brotli_DecompressFile(const char *input_path, const char *output_path) {
    int ret = 0;
    FILE *file_in = NULL;
    ret = OpenInputFile(input_path, &file_in);
    if (ret != true) {return 1;}

    FILE *file_out = NULL;
    ret = OpenOutputFile(output_path, &file_out, true);
    if (ret != true) {return 1;}

    BrotliDecoderState *decoderState = BrotliDecoderCreateInstance(NULL, NULL, NULL);
    if (!decoderState) {return 2;}

    ret = BrotliDecoderSetParameter(decoderState, BROTLI_DECODER_PARAM_LARGE_WINDOW, 1u);
    if (ret != BROTLI_TRUE) {return 3;}

    {
        BrotliDecoderResult result = BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT;

        uint8_t *buffer;
        uint8_t *input;
        uint8_t *output;

        buffer = (uint8_t *) malloc(kFileBufferSize * 2);
        input = buffer;
        output = buffer + kFileBufferSize;
        size_t available_in = 0;
        const uint8_t *next_in = NULL;
        size_t available_out = kFileBufferSize;
        uint8_t *next_out = output;

        for (;;) {
            if (result == BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT) {
                if (!HasMoreInput(file_in)) {
                    LogError("corrupt input [%s]\n", PrintablePath(input_path));
                    ret = BROTLI_FALSE;
                    break;
                }
                if (!ProvideInput(input, &available_in, &next_in, file_in, input_path)) return BROTLI_FALSE;
            } else if (result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT) {
                if (!ProvideOutput(&available_out, output, &next_out, file_out, output_path)) return BROTLI_FALSE;
            } else if (result == BROTLI_DECODER_RESULT_SUCCESS) {
                if (!FlushOutput(&available_out, output, &next_out, file_out, output_path)) return BROTLI_FALSE;
                if (available_in != 0 || HasMoreInput(file_in)) {
                    LogError("corrupt input [%s]\n", PrintablePath(input_path));
                    ret = BROTLI_FALSE;
                    break;
                }
                ret = BROTLI_TRUE;
                break;
            } else {
                LogError("corrupt input [%s]\n", PrintablePath(input_path));
                ret = BROTLI_FALSE;
                break;
            }

            result = BrotliDecoderDecompressStream(
                    decoderState,
                    &available_in,
                    &next_in,
                    &available_out,
                    &next_out,
                    0);
        }
    }

    BrotliDecoderDestroyInstance(decoderState);

    if (!CloseFiles(input_path, file_in, file_out, output_path, ret)) {ret = BROTLI_FALSE;}
    if (ret != BROTLI_TRUE) {return 3;}
    return 0;
}

__attribute__((used))
int Brotli_CompressData(const void *inputData, size_t inputSize, uint32_t mode, uint32_t window_bits, uint32_t quality, void **outputData, size_t *outputSize) {
    const size_t maxOutputSize = BrotliEncoderMaxCompressedSize(inputSize);
    uint8_t *outputBuffer = malloc(maxOutputSize * sizeof(uint8_t));
    size_t output_size = maxOutputSize;

    BROTLI_BOOL ret = BrotliEncoderCompress(quality, window_bits, (BrotliEncoderMode) mode, inputSize, inputData, &output_size, outputBuffer);
    if (ret != BROTLI_TRUE) {return COMPRESS_ERROR;}
    *outputData = outputBuffer;
    *outputSize = output_size;
    return SUCCEED;
}

__attribute__((used))
int Brotli_DecompressData(const void *inputData, size_t inputSize, void **outputData, size_t *outputSize, size_t bufferCapacity) {
    size_t available_in = inputSize;
    const uint8_t *next_in = inputData;

    size_t outputBufferSize = 0;
    size_t outputBufferCapacity = bufferCapacity;
    uint8_t *outputBuffer = (uint8_t *) malloc(outputBufferCapacity * sizeof(uint8_t));

    BrotliDecoderState *s = BrotliDecoderCreateInstance(NULL, NULL, NULL);
    BrotliDecoderResult result = BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT;
    size_t total_out = 0;

    while (result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT) {
        size_t available_out = outputBufferCapacity - outputBufferSize;
        uint8_t *next_out = outputBuffer + outputBufferSize;

        result = BrotliDecoderDecompressStream(s, &available_in, &next_in, &available_out, &next_out, &total_out);
        outputBufferSize = outputBufferCapacity - available_out;

        if (available_out < bufferCapacity) {
            outputBufferCapacity += bufferCapacity;
            outputBuffer = realloc(outputBuffer, outputBufferCapacity * sizeof(uint8_t));
        }
    }

    BrotliDecoderDestroyInstance(s);

    if (result != BROTLI_DECODER_RESULT_SUCCESS && result != BROTLI_DECODER_RESULT_NEEDS_MORE_INPUT) {
        free(outputBuffer);
        return DECOMPRESS_ERROR;
    }

    *outputData = outputBuffer;
    *outputSize = total_out;
    return SUCCEED;
}
