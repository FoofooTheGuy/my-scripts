#pragma once

#include <cstdint>
#include <cstring>
#include <cstdio>

uint32_t DecompressLZ11(const uint8_t* in, uint8_t* out);
uint32_t Get_Decompressed_size(const uint8_t* in);
