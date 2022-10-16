cmake_minimum_required(VERSION 3.5)
set(LLVM_MOS_PLATFORM mega65)
find_package(llvm-mos-sdk REQUIRED)
project(plasma VERSION 0.1.0 LANGUAGES C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS YES)

include(CPM.cmake)
CPMAddPackage(NAME mega65libc GITHUB_REPOSITORY mega65/mega65-libc GIT_TAG master SOURCE_SUBDIR clang)

add_compile_options(-mcpu=mos65c02 -Os -Wall -Wextra -Wshadow -Wconversion -Wno-language-extension-token)

add_executable(plasma plasma.c)
target_link_libraries(plasma mega65libc)
set_target_properties(plasma PROPERTIES OUTPUT_NAME plasma_cpp.prg)