// decompress LZ11 compressed file
#include <iostream>
#include <fstream>
#include <vector>

#include "lz.hpp"

int main(int argc, char* argv[]) {
	if (argc != 3) {
		std::cout << "usage:" << argv[0] << " <in uncompressed> <out compressed>" << std::endl;
		return 1;
	}
	
	std::ifstream infile(argv[1], std::ios_base::binary | std::ios_base::ate);
	auto size = infile.tellg();
	std::vector<uint8_t> uncompressed(size);
	infile.seekg(0);
	infile.read(reinterpret_cast<char*>(uncompressed.data()), size);
	infile.close();
	
	uint32_t lzSize = 0;
	void* lzFile = lz11_compress(&lzSize, uncompressed.data(), uncompressed.size());

	std::ofstream outfile(argv[2], std::ios_base::binary);
	outfile.write(reinterpret_cast<const char*>(lzFile), lzSize);
	return 0;
}
