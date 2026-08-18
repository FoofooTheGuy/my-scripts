#pragma description Mobiclip MoFlex for CTR
#pragma loop_limit 0xFFFFFFFF

import type.base;
import std.io;

/* heavily based on existing documenation:
https://gist.github.com/quatric/3e2f0caa5c22a9a8b24d9cf1ffdfe860#42-3ds--dsi--moflex
https://github.com/brainphreak/clownsec-moflex-encoder/blob/10a3644/docs/moflex-format.md
*/

u16 last_sync_size = 0;

/*
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
        count += 1;
        addr += 2048;
    }
    return count;
};

enum descriptor_type : u8 {
    end_of_list,
    video,
    audio,
    video_with_layout,
    data,
};

// I'm just guessing lol
enum packet_type : u8 {
    unk0 = 0x80, // type, length
    unk1 = 0xB6, // type, u32, u8[7]?
    unk2 = 0xBA, // type, u32, length?, u8
    unk3 = 0xF6, // initial packet? type, u32, 
};

struct video_descriptor {
    be u8 streamIndex;
    be u8 codecID;
    be u16 fpsDenominator;
    be u16 fpsNumerator;
    be u16 width;
    be u16 height;
    be u16 unk;
};

struct audio_descriptor {
    be u8 unk0 [[comment("channels?")]];
    be u8 unk1;
    be u8 unk2;
    be u16 unk3 [[comment("bit rate - 1?")]];
    be u8 unk4;
};

struct video_with_layout_descriptor {
    video_descriptor descriptor;
    be u8 layout [[name("Layout byte for 3D (ImageLayout & 0xF) | (ImageRotation << 4)")]];
};

struct data_descriptor {
    be u8 unk0;
    be u8 unk1;
};

struct descriptor {
    descriptor_type type;
    if (type != descriptor_type::end_of_list) {
        be u8 size;
        match(type) {
            (descriptor_type::video): video_descriptor payload [[comment("video payload")]];
            (descriptor_type::audio): audio_descriptor payload [[comment("audio payload")]];
            (descriptor_type::video_with_layout): video_with_layout_descriptor payload [[comment("video with layout payload")]];
            (descriptor_type::data): data_descriptor payload [[comment("data payload (used for seek table at stream index 2)")]];
        }
    }
};

struct sync_block_header {
    be type::Hex<u16> Magic [[comment("be16 0x4C32")]];
    be type::Hex<u16> ts_hash [[name("Timestamp hash"), comment("be16 CRC-16 with polynomial 0x0001 (a bare shift/feedback LFSR), init 0, XOR-out 0xAAAA")]];
    be u64 Timestamp [[comment(std::format("be64 timestamp(microseconds)\nHash: 0x{:X}", sync_check($)))]];
    be u16 block_size [[name("Block length"), comment("Normally 2047 (0x7FF)")]];
    descriptor descriptors[while($[$] != descriptor_type::end_of_list)];
    descriptor end_of_list_descriptor [[comment("The descriptor marking the list's end")]];
    be u8 flags;
};

struct block_data {
    if((std::mem::read_unsigned($, 2, std::mem::Endian::Big) == 0x4C32)) {
        sync_block_header sync_block_head [[name("Sync block header")]];
        last_sync_size = (sync_block_head.block_size + 1);
    }
    be u8 flags [[comment("Seems to increase by 4 at each sync block")]];
};

struct packet {
    be u8 type;
    be u32 unk0;
    be u8 blob_size [[name("Blob size?")]];
    be u8 unk1;
    be u8 blob[blob_size];
};

struct block_full {
    block_data block;
    u8 unk_packets[last_sync_size - sizeof(block)];
};

u64 block_count = count_blocks();

std::print("Number of blocks: {:}", block_count);

block_full blocks[block_count] @ 0x00;