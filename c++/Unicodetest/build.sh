#! /bin/bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
echo finished
