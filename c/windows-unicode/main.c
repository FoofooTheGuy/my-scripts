#include <stdint.h>
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#endif

int wmain() {
	char* name = "あ.txt";
	
	int wc_size = MultiByteToWideChar(CP_UTF8, 0, name, strlen(name) + 1, NULL, 0);
	if(!wc_size) {
		puts("failed to convert to wc");
		return 1;
	}
	wchar_t* wc = malloc(wc_size * sizeof(wchar_t));
	if(!wc) {
		puts("failed to allocate wc");
		return 2;
	}
	int ret = MultiByteToWideChar(CP_UTF8, 0, name, strlen(name) + 1, wc, wc_size);
	if(!ret) {
		puts("failed to convert to wc");
		return 3;
	}
	
	FILE *fp = _wfopen(wc, L"wt+");
	if(!fp) {
		puts("failed to open file");
		return 4;
	}
	
	for(int i = 0; i < strlen(name) + 1; i++) {
		printf("%02X\n", name[i]);
	}
	puts("the grand reveal");
	for(int i = 0; i < wcslen(wc) + 1; i++) {
		printf("%04X\n", wc[i]);
	}
	
	// now try this thing
	WIN32_FIND_DATAW FindFileData;
	HANDLE hFind;

	printf("Target file is %s\n", name);
	hFind = FindFirstFileW(wc, &FindFileData);
	if (hFind == INVALID_HANDLE_VALUE)
	{
		printf ("FindFirstFile failed (%d)\n", GetLastError());
		return 5;
	}
	
	//printf("The first file found is %ls\n", FindFileData.cFileName);
	puts("read it back");
	for(int i = 0; i < wcslen(FindFileData.cFileName) + 1; i++) {
		printf("%04X\n", FindFileData.cFileName[i]);
	}
	
	free(wc);
	
	int mb_size = WideCharToMultiByte(CP_UTF8, 0, FindFileData.cFileName, wcslen(FindFileData.cFileName) + 1, NULL, 0, NULL, NULL);
	if(!mb_size) {
		return 6;
	}
	char* mb = malloc(mb_size);
	if(!mb) {
		return 7;
	}
	ret = WideCharToMultiByte(CP_UTF8, 0, FindFileData.cFileName, wcslen(FindFileData.cFileName) + 1, mb, mb_size, NULL, NULL);
	if(!ret) {
		return 8;
	}
	
	puts("back to utf8");
	
	for(int i = 0; i < strlen(mb) + 1; i++) {
		printf("%02X\n", mb[i]);
	}
	
	FindClose(hFind);
	free(mb);
	return 0;
}
