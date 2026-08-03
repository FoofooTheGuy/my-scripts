#pragma loop_limit 8192

import type.base;
import std.io;

/*
 get the actual size of the given packet
 addr: address to start at
 return size of packet
*/
fn measure_packets(u64 addr) {
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
        addr += 1;
        size += 1;
    }
    return size;
};

// iterate through the file to count blocks
// return: number of blocks
fn count_blocks() {
    u64 count = 0;
    u64 addr = 0;
    std::print("{:X}", addr);
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
    be u16 unk0 [[comment("Changes depending on timestamp?")]];
    be u64 Timestamp [[comment("be64 timestamp(microseconds)")]];
    be u16 block_size [[name("Align?"), comment("block_size - 1")]];
    descriptor descriptors[while($[$] != type::end_of_list)];
    descriptor end_of_list_descriptor [[comment("The descriptor marking the list's end")]];
    u8 flags;
};

struct chunk {
    header head;
    u8 packets[measure_packets($)];
};

u64 block_count = count_blocks();

std::print("blocks: {:}", block_count);

chunk blocks[block_count] @ 0x00;