#include <filesystem>
#include <iostream>
#include <fstream>

int main() {
	std::string file = "あああ.txt";
	
	std::ofstream outfile(std::filesystem::path((const char8_t*)&*(file).c_str()), std::ios_base::out | std::ios_base::binary);
	outfile << "hi あああ" << std::endl;
	outfile.close();
	
	std::ifstream infile(std::filesystem::path((const char8_t*)&*(file).c_str()), std::ios_base::in | std::ios_base::binary);
	//https://stackoverflow.com/a/2602258
	std::stringstream buffer;
	buffer << infile.rdbuf();
	std::cout << buffer.str() << std::endl;
	
	std::ofstream outfile2(std::filesystem::path((const char8_t*)&*("2" + file).c_str()), std::ios_base::out | std::ios_base::binary);
	outfile2 << buffer.str() << std::endl;
	outfile2.close();
}
