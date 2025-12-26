#pragma once

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <cstdio>

#define MIN(a,b) (((a)<(b))?(a):(b))

uint32_t lz11_get_occurence_length(uint8_t* newPtr, uint32_t newLength, uint8_t* oldPtr, uint32_t oldLength, uint32_t* disp);
void* lz11_compress(uint32_t* size, void* input, uint32_t inputSize);
