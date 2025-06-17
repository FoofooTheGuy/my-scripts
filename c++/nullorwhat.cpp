#include <iostream>
#include <cstdint>

int main() {
    const char* str = NULL;
    if(str) {
        puts("1");
    }
    else if(!str) {
        puts("0");
    }
    printf("%016lX\n", (uintptr_t)str);
    return 0;
}
