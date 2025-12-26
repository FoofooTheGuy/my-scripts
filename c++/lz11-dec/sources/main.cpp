// decompress LZ11 compressed file
#include <iostream>
#include <fstream>
#include <vector>

#include "lz.hpp"

int main(int argc, char* argv[]) {
	if (argc != 3) {
		std::cout << "usage:" << argv[0] << " <in compressed> <out decompressed>" << std::endl;
		return 1;
	}
	
	std::ifstream infile(argv[1], std::ios_base::binary | std::ios_base::ate);
	auto size = infile.tellg();
	std::vector<uint8_t> lzFile(size);
	infile.seekg(0);
	infile.read(reinterpret_cast<char*>(lzFile.data()), size);
	infile.close();
	
	uint32_t decompressedsize = Get_Decompressed_size(lzFile.data());
	if(decompressedsize == 0xFFFFFFFF) {
		std::cout << "Type is not 11" << std::endl;
		return 2;
	}
	std::vector<uint8_t> decompressedFile(decompressedsize);
	
	if(DecompressLZ11(lzFile.data(), decompressedFile.data()) == 0xFFFFFFFF) {
		std::cout << "Type is not 11" << std::endl;
		return 3;
	}
	
	std::ofstream outfile(argv[2], std::ios_base::binary);
	outfile.write(reinterpret_cast<const char*>(decompressedFile.data()), decompressedFile.size());
	return 0;
}
