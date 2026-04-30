import std.string;
import type.base;
import std.core;
import std.io;

// https://problemkaputt.de/gbatek-3ds-files-video-layout-images-clim-flim.htm

enum encoding : u8 {
    L8, // 0
    A8, // 1
    LA44, // 2
    LA88, // 3
    HILO88, // 4
    RGB565, // 5
    RGB888, // 6
    RGBA5551, // 7
    RGBA4444, // 8
    RGBA8888, // 9
    ETC1, // A
    ETC1A4, // B
    L4, // C
    A4, // D
};

struct chunk {
    char imag[4] [[name("Magic"), comment("imag")]];
    u32 chunksize [[name("Chunk size"), comment("0x10")]];
    u16 width [[name("Width")]];
    u16 height [[name("Height")]];
    encoding format [[name("Texture format")]];
    u8 zero [[name("Zero")]];
    u8 zero1 [[name("Zero")]];
    u8 zero2 [[name("Zero")]];
    u32 footeroffset [[name("Footer offset")]];
};

struct footer {
    char clim[4] [[name("Magic"), comment("CLIM")]];
    u8 endianess[2] [[name("Endianess"), comment("FF FE: little endian, FE FF: Big endian.")]];
    u32 footersize [[name("Footer size")]];
    u16 version [[name("Version?"), comment("2 2")]];
    u32 filesize [[name("File size"), comment("datasize + 28")]];
    u32 blockcount [[name("Number of blocks"), comment("1")]];
    chunk imag [[name("Chunk ID"), comment("imag")]];
};

footer clim @ std::mem::size() - sizeof(footer);
