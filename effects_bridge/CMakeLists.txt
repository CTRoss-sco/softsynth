cmake_minimum_required(VERSION 3.15)
project(EffectsFHI)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include the existing JUCE project - IMPORTANT: Use absolute path
get_filename_component(JUCE_AUDIO_ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../juce_audio_engine" ABSOLUTE)
add_subdirectory(${JUCE_AUDIO_ENGINE_DIR} juce_audio_engine_build)

# Create the Effects FFI library
add_library(EffectsFHI SHARED
    src/effects_ffi.cpp
    ${JUCE_AUDIO_ENGINE_DIR}/Source/Effects/ReverbEffect.cpp  # Include directly
)

# Include directories
target_include_directories(EffectsFHI PRIVATE
    src/
    ${JUCE_AUDIO_ENGINE_DIR}/Source/
    ${JUCE_AUDIO_ENGINE_DIR}/Source/Effects/
)

# Link to the existing SynthEngine library
target_link_libraries(EffectsFHI PRIVATE
    SynthEngine
)

# Output settings
set_target_properties(EffectsFHI PROPERTIES
    OUTPUT_NAME "EffectsFHI"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>/"
)

# Windows-specific settings
if(WIN32)
    target_compile_definitions(EffectsFHI PRIVATE _WIN32)
endif()