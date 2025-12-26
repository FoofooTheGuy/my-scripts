cmake_minimum_required(VERSION 3.20)
project(lz11-decompress)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB MY_SRC
	"${CMAKE_CURRENT_SOURCE_DIR}/sources/*.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
	"${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp"
)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")

add_executable(${PROJECT_NAME} ${MY_SRC})
