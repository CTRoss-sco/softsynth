cmake_minimum_required(VERSION 3.15)
project(SynthFFI VERSION 1.0.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include the SynthEngine
add_subdirectory(../juce_audio_engine ${CMAKE_BINARY_DIR}/juce_audio_engine)

# Create the FFI bridge library
add_library(SynthFFI SHARED
    src/ffi_bridge.cpp
    src/ffi_bridge.h
)

# Link with the SynthEngine and JUCE modules
target_link_libraries(SynthFFI PRIVATE 
    SynthEngine
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_core
)

# Define export symbols
target_compile_definitions(SynthFFI PRIVATE BUILDING_SYNTHFFI_DLL=1)

# Include directories
target_include_directories(SynthFFI PRIVATE 
    ../juce_audio_engine/Source
    src
)

# Add test executable
add_executable(TestFFI test_ffi.c)
target_link_libraries(TestFFI PRIVATE SynthFFI)
target_include_directories(TestFFI PRIVATE src)
