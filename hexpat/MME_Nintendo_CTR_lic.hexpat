#pragma description MME_Nintendo_CTR_*.lic

import std.string;
import std.array;
import std.ctype;
import std.io;

import type.base;

fn find_char(str input, char findchar) {
    for (u64 i = 0, i < std::string::length(input), i=i+1) {
        if(std::string::at(input, i) == findchar) {
            return i;
        }
    }
};

// https://stackoverflow.com/a/13935718
/*
   base64.cpp and base64.h

   Copyright (C) 2004-2008 René Nyffenegger

   This source code is provided 'as-is', without any express or implied
   warranty. In no event will the author be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this source code must not be misrepresented; you must not
      claim that you wrote the original source code. If you use this source code
      in a product, an acknowledgment in the product documentation would be
      appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
      misrepresented as being the original source code.

   3. This notice may not be removed or altered from any source distribution.

   René Nyffenegger rene.nyffenegger@adp-gmbh.ch

*/

str base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

fn is_base64(u8 c) {
    return (std::ctype::isalnum(c) || (c == '+') || (c == '/'));
};

fn base64_decode(str encoded_string) {
    s64 in_len = std::string::length(encoded_string);
    s64 i = 0;
    s64 j = 0;
    s64 in_ = 0;
    char char_array_4[4];
    char char_array_3[3];
    str ret = "";
    
    while (in_len) {
        if((std::string::at(encoded_string, in_) == '=') || !is_base64(encoded_string[in_])) {
            break;
        }
        char_array_4[i] = encoded_string[in_];
        in_=in_+1;
        i=i+1;
        if (i == 4) {
            for (i = 0, i < 4, i=i+1) {
                char_array_4[i] = find_char(base64_chars, char_array_4[i]);
            }
            
            char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
            char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
            char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];
            
            for (i = 0, i < 3, i=i+1) {
                ret = std::format("{}{:02X} ", ret, char_array_3[i]);
            }
            i = 0;
        }
        in_len=in_len-1;
    }

    if (i) {
        for (j = i, j < 4, j=j+1) {
            char_array_4[j] = 0;
        }
        
        for (j = 0, j < 4, j=j+1) {
            char place;
            
            // copy of find_char because i think it's legit bugged
            //char_array_4[j] = find_char(base64_chars, char_array_4[j]);
            for (u64 k = 0, k < std::string::length(base64_chars), k=k+1) {
                if(std::string::at(base64_chars, k) == char_array_4[j]) {
                    place = k;
                }
            }
            char_array_4[j] = place;
        }
        
        char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
        char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
        char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];
        
        for (j = 0, (j < i - 1), j=j+1) {
            ret = std::format("{}{:02X} ", ret, char_array_3[j]);
        }
    }
    
    return ret;
};

struct lic {
    std::string::NullString magic [[name("Magic"), comment("Nintendo")]];
    u8 unk0[(0x10 - $) + 0x70];
    std::string::NullString key [[name("Timestamp"), comment("Seems to be base64 as it still works if you append non-base64 characters. Also encrypted?")]];
    u8 unk1[std::mem::size() - $];
};

lic file @ 0x00;
std::print(std::format("Decoded Timestamp: (Still encrypted)\n{}", base64_decode(std::string::to_string(file.key))));