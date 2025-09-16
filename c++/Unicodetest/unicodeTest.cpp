#include <filesystem>
#include <iostream>
#include <vector>
#include <fstream>

#ifdef _WIN32
#include <windows.h>
#endif

int progmain(int argc, char** argv) {
	std::cout << "progmain" << std::endl;
	std::string file = "あああ.txt";
	
	
	if(argc == 2) {
		file = argv[1];
		file += ".txt";
	}
	
	int i = 0;
	while(file[i] != NULL) {
		std::cout << file[i] << std::endl;
		printf("char %d: %X\n", i, file[i]);
		++i;
	}
	
	std::cout << file << std::endl;
	
	//std::filesystem::path((const char8_t*)&*(file).c_str())
	std::ofstream outfile(std::filesystem::path((const char8_t*)&*(file).c_str()), std::ios_base::out | std::ios_base::binary);
	std::cout << "created file" << std::endl;
	outfile << "hi あああ" << std::endl;
	outfile.close();
	
	std::ifstream infile(std::filesystem::path((const char8_t*)&*(file).c_str()), std::ios_base::in | std::ios_base::binary);
	//https://stackoverflow.com/a/2602258
	std::stringstream buffer;
	buffer << infile.rdbuf();
	std::cout << buffer.str() << std::endl;
	
	std::ofstream outfile2(std::filesystem::path((const char8_t*)&*("2_" + file).c_str()), std::ios_base::out | std::ios_base::binary);
	outfile2 << buffer.str() << std::endl;
	outfile2.close();
	return 0;
}

// entry point (real)
#ifndef _WIN32
int main(int argc, char** argv) {
	std::cout << "main" << endl;
	int ret = progmain(argc, argv);
	return ret;
}
#else

// https://stackoverflow.com/a/41665246
std::string WstrToUtf8Str(const std::wstring& wstr)
{
	std::string retStr = "";
	if (!wstr.empty())
	{
		int sizeRequired = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, NULL, 0, NULL, NULL);
		
		if (sizeRequired > 0)
		{
			retStr.resize(sizeRequired);
			int bytesConverted = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, &retStr[0], sizeRequired, NULL, NULL);
			if (!bytesConverted)
			{
				std::wcout << L"WstrToUtf8Str failed to convert wstring '" << wstr.c_str() << L"'";
				return "";
			}
		}
	}
	return retStr;
}	

int wmain(int argc, wchar_t** argv) {
	std::cout << "wmain" << std::endl;
	std::cout << argc << std::endl;
	
	// put argv in std::vector (yay!)
	std::vector<std::string> argvecmb;
	{
		int j = 0;
		for(size_t i = 0; i < argc; i++) {
			std::wcout << argv[i] << std::endl;
			std::string arg = WstrToUtf8Str(argv[i]);
			argvecmb.push_back(arg);
			std::cout << argvecmb.at(i) << std::endl;
		}
	}

    char** charcharArray = new char*[argvecmb.size()];

    for (size_t i = 0; i < argvecmb.size(); i++) {
        charcharArray[i] = new char[argvecmb.at(i).length() + 1];
        strcpy_s(charcharArray[i], argvecmb.at(i).length() + 1, argvecmb.at(i).c_str());
    }
	
	int ret = progmain(argc, charcharArray);
	
	for (size_t i = 0; i < argvecmb.size(); ++i) {
		delete[] charcharArray[i];
	}
    delete[] charcharArray;
	
	return ret;
}
#endif

