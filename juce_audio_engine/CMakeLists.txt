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
    Source/Effects/ChorusEffect.cpp
    Source/Effects/ChorusEffect.h
)

# Link JUCE modules to SynthEngine
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

#Google Test setup

# Only add tests if this is the main project
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    
    # Enable testing
    enable_testing()
    
    # Fetch Google Test
    include(FetchContent)
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    )
    
    # For Windows: Prevent overriding the parent project's compiler/linker settings
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)
    
    # Create test executable
    add_executable(
        SynthEngineTests
        tests/test_synth_engine.cpp
        tests/test_oscillators.cpp
        tests/test_effects.cpp
        # tests/test_filter.cpp
    )
    
    # Link Google Test and SynthEngine library
    target_link_libraries(
        SynthEngineTests
        PRIVATE
        gtest_main
        SynthEngine
        juce::juce_audio_basics
        juce::juce_core
        juce::juce_audio_devices
        juce::juce_audio_processors
    )
    
    # Include directories for tests
    target_include_directories(
        SynthEngineTests 
        PRIVATE 
        Source
        Source/Effects
        ${CMAKE_CURRENT_SOURCE_DIR}
    )
    
    # Set C++ standard for tests
    target_compile_features(SynthEngineTests PRIVATE cxx_std_17)
    
    # Same compile definitions as main library
    target_compile_definitions(SynthEngineTests PRIVATE
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
    )
    
    # Discover tests for CTest
    include(GoogleTest)
    gtest_discover_tests(SynthEngineTests)
    
    # Custom test target for convenience
    add_custom_target(run_tests
        COMMAND SynthEngineTests
        DEPENDS SynthEngineTests
        COMMENT "Running SynthEngine unit tests..."
    )
    
endif()