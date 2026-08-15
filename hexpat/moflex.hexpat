#pragma loop_limit 0xFFFFFFFF

import type.base;
import std.io;

/* heavily based on docs by quatric:
https://gist.github.com/quatric/3e2f0caa5c22a9a8b24d9cf1ffdfe860#42-3ds--dsi--moflex
*/

/*
 https://github.com/brainphreak/clownsec-moflex-encoder/blob/10a3644/docs/moflex-format.md?plain=1#L28
 to check time stamp hash
 addr: address to start at (Timestamp)
 return: crc16 that should match the Timestamp hash in the block
*/
fn sync_check(u64 addr) {
    u16 crc = 0;
    for(u8 i = 0, i < 8, i = i+1) {
        u8 byte = std::mem::read_unsigned(addr, 1, std::mem::Endian::Big);
        addr = addr + 1;
        crc ^= byte << 8;
        for(u8 j = 0, j < 8, j=j+1) {
            crc = (crc & 0x8000) ? ((crc << 1) ^ 0x0001) & 0xFFFF : (crc << 1) & 0xFFFF;
        }
    }
    return crc ^ 0xAAAA;
};

/*
 get the actual size of the given packet
 this only works if the blocks are properly aligned
 addr: address to start at
 return: size of packet
*/
fn measure_packets(u64 addr) {
    u64 start = addr;
    u64 size = 0;
    std::print("{:X}", addr);
    while(1) {
        if(addr >= std::mem::size()) { // fail safe in case you make it too big
            break;
        }
        //std::print("a {:X}", addr);
        if((addr % (2048)) == 0) {
            if((std::mem::read_unsigned(addr, 2, std::mem::Endian::Big) == 0x4C32)) {
                break;
            }
        }
        // add but also align it
        if(addr < ((start + 0x10) & 0xFFFFFFFFFFF0)) {
            addr += 1;
            size += 1;
        }
        else {
            addr += 0x10;
            size += 0x10;
        }
    }
    //std::print("a {:X}", addr);
    return size;
};

/*
 iterate through the file to count blocks
 this only works if the blocks are properly aligned
 return: number of blocks
*/
fn count_blocks() {
    u64 count = 0;
    u64 addr = 0;
    //std::print("{:X}", addr);
    while(1) {
        if(addr >= std::mem::size()) { // fail safe in case you make it too big
            break;
        }
        //std::print("a {:X}", addr);
        if((std::mem::read_unsigned(addr, 2, std::mem::Endian::Big) == 0x4C32)) {
            count += 1;
        }
        addr += 2048;
    }
    return count;
};

enum type : u8 {
    end_of_list,
    video,
    audio,
    video_with_layout,
    data,
};

struct video_descriptor {
    u8 streamIndex;
    u8 codecID;
    be u16 fpsDenominator;
    be u16 fpsNumerator;
    be u16 width;
    be u16 height;
    u16 unk;
};

struct audio_descriptor {
    u8 unk0 [[comment("channels?")]];
    u8 unk1;
    u8 unk2;
    be u16 unk3 [[comment("bit rate - 1?")]];
    u8 unk4;
};

struct video_with_layout_descriptor {
    video_descriptor descriptor;
    u8 layout [[name("Layout byte for 3D (ImageLayout & 0xF) | (ImageRotation << 4)")]];
};

struct data_descriptor {
    u8 unk0;
    u8 unk1;
};

struct descriptor {
    type type;
    if (type != type::end_of_list) {
        u8 size;
        match(type) {
            (type::video): video_descriptor payload [[comment("video payload")]];
            (type::audio): audio_descriptor payload [[comment("audio payload")]];
            (type::video_with_layout): video_with_layout_descriptor payload [[comment("video with layout payload")]];
            (type::data): data_descriptor payload [[comment("data payload (used for seek table at stream index 2)")]];
        }
    }
};

struct header {
    be type::Hex<u16> Magic [[comment("be16 0x4C32")]];
    be type::Hex<u16> ts_hash [[name("Timestamp hash"), comment("be16 CRC-16 with polynomial 0x0001 (a bare shift/feedback LFSR), init 0, XOR-out 0xAAAA")]];
    be u64 Timestamp [[comment(std::format("be64 timestamp(microseconds)\nHash: 0x{:X}", sync_check($)))]];
    be u16 block_size [[name("Alignment"), comment("2047 (0x7FF)")]];
    descriptor descriptors[while($[$] != type::end_of_list)];
    descriptor end_of_list_descriptor [[comment("The descriptor marking the list's end")]];
    u8 flags;
};

struct chunk {
    header head;
    u8 packets[measure_packets($)];
};

u64 block_count = count_blocks();

std::print("Number of blocks: {:}", block_count);

chunk blocks[block_count] @ 0x00;