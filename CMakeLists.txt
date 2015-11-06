cmake_minimum_required(VERSION 3.2)
project(LoveShaderConverter)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES src/LoveShaderConverter.cpp)
add_executable(LoveShaderConverter ${SOURCE_FILES})

find_package(Boost 1.5.8)
