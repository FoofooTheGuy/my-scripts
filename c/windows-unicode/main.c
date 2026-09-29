#include <windows.h>
#include <stdint.h>
#include <stdio.h>

int wmain() {
	char* name = "あ.txt";
	
	int reserveSize = MultiByteToWideChar(CP_UTF8, 0, name, strlen(name) + 1, NULL, 0);
	wchar_t* longg = malloc(reserveSize * sizeof(wchar_t));
	
	MultiByteToWideChar(CP_UTF8, 0, name, strlen(name) + 1, longg, reserveSize);

	for(int i = 0; i < strlen(name); i++) {
		printf("%X\n", name[i]);
	}
	puts("the grand reveal");
	for(int i = 0; i < wcslen(longg); i++) {
		printf("%X\n", longg[i]);
	}
	
	FILE *fp = _wfopen(longg, L"wt+");
	if(!fp) {
		puts("failed to open file");
		return 1;
	}
	free(longg);
	return 0;
}
