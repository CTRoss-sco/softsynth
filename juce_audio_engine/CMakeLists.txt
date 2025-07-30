cmake_minimum_required(VERSION 3.15)
project(SynthEngine VERSION 1.0.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add JUCE
add_subdirectory(JUCE)

# Create a library instead of executable for FFI compatibility
add_library(SynthEngine SHARED
    Source/SynthEngine.cpp
    Source/SynthEngine.h
    Source/Oscillator.cpp
    Source/Oscillator.h
    Source/Effects/Effect.h
    Source/Effects/Filter.h
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/Effects/Filter.cpp"
    Source/Effects/ReverbEffect.cpp
    Source/Effects/ReverbEffect.h
    Source/Effects/DelayEffect.cpp
    Source/Effects/DelayEffect.h
)

# Link JUCE modules to your SynthEngine
target_link_libraries(SynthEngine PRIVATE
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_audio_formats
    juce::juce_audio_processors
    juce::juce_core
    juce::juce_data_structures
    juce::juce_events
    juce::juce_graphics
    juce::juce_gui_basics
    juce::juce_gui_extra
)

# Compile definitions for JUCE
target_compile_definitions(SynthEngine PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0
)

# Export symbols for DLL
target_compile_definitions(SynthEngine PRIVATE JUCE_DLL_BUILD=1)

# Include directories for Effects
target_include_directories(SynthEngine PRIVATE Source/Effects)

# Temporarily keep the test executable
add_executable(TestApp Source/Main.cpp)
target_link_libraries(TestApp PRIVATE SynthEngine)