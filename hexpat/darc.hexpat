import std.string;
import type.base;
import std.core;
import std.io;

struct header {
    char magic[4] [[name("Magic"), comment("darc")]];
    u8 endianess[2] [[name("Endianess"), comment("FF FE: little endian, FE FF: Big endian.")]];
    type::Hex<u16> header_length [[name("Header"), comment("Header length in bytes.")]];
    type::Hex<u32> version [[name("Version")]];
    u32 file_length [[name("File length"), comment("File length in bytes.")]];
    type::Hex<u32> table_offset [[name("Table offset"), comment("Absolute")]];
    type::Hex<u32> table_length [[name("Table length"), comment("Table length in bytes")]];
    type::Hex<u32> file_data_offset [[name("File data offset"), comment("Absolute")]];
};

struct table_entry {
    type::Hex<u32> file_name_offset [[name("File name offset"), comment("Relative to the end of the entries of the table")]];
    type::Hex<u32> offset [[name("File offset"), comment("Absolute")]];
    type::Hex<u32> length [[name("File length")]];
};

// get the length of first entry, which tells us the amount of entries
u32 entry_count @ sizeof(header) + (sizeof(u32) * 2);
struct file_table {
    table_entry entries[entry_count];
    std::string::NullString16 file_name[entry_count];
};

struct file_data {
    u8 data[];
};

struct file {
    header header;
    file_table table;
    u8 files_padding[header.file_data_offset - $];
};

file darc @ 0;

/*for (u8 i = 0, i < entry_count, i += 1) {
    u32 offset = darc.table.entries[i].file_name_offset & 0xFFFFFF;
    
    std::string::NullString16 file_name @ sizeof(header) + (sizeof(table_entry) * entry_count) + offset;
    std::print("file #{}: {}", i, file_name);
}*/
