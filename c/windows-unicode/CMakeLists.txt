cmake_minimum_required(VERSION 3.10)

# https://stackoverflow.com/a/53635241
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# Project name and version
project(unicode VERSION 1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

if (DEBUG)
	set(BUILD_TYPE "Debug")
else()
	set(BUILD_TYPE "Release")
endif()

# Define the source files for the executable
set(EXE_SOURCES
	main.c
)

# Create the executable
add_executable(${PROJECT_NAME} ${EXE_SOURCES})
#set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${EXE_NAME})
