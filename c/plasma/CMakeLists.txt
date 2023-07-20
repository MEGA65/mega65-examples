cmake_minimum_required(VERSION 3.5)
set(LLVM_MOS_PLATFORM mega65)
find_package(llvm-mos-sdk REQUIRED)
project(plasma VERSION 0.1.0 LANGUAGES C)
include(cmake/CPM.cmake)
add_compile_options(-mcpu=mos65ce02 -Os -Wall -Wextra -Wshadow -Wconversion -Wno-language-extension-token -Wsigned)

CPMAddPackage(NAME mega65libc GITHUB_REPOSITORY mega65/mega65-libc GIT_TAG v0.2.0 SOURCE_SUBDIR clang)
add_executable(plasma plasma.c)
target_link_libraries(plasma mega65libc)
set_target_properties(plasma PROPERTIES OUTPUT_NAME plasma.prg)

add_custom_target(run COMMENT "Run with Xemu" COMMAND xmega65 -besure -prg $<TARGET_FILE:plasma>)
add_custom_target(hw COMMENT "Transfer and run on hardware" COMMAND matrix65 --port /dev/cu.usbserial-AQ027F6E prg --run $<TARGET_FILE:plasma> --reset)
