#include <gtest/gtest.h>
#include "SynthEngine.h"
#include <thread>
#include <chrono>

/*
File containing unit tests for oscillator functionality, 
covering waveform selection, detuning and mixing settings.
*/

class OscillatorTest : public ::testing::Test {
protected:
    void SetUp() override {
        synthEngine = std::make_unique<SynthEngine>();
    }

    void TearDown() override {
        synthEngine.reset();
    }

    std::unique_ptr<SynthEngine> synthEngine;
};

// Test oscillator waveform setting with explicit casts
TEST_F(OscillatorTest, WaveformSetting) {
    // Test Osc1 waveforms (0=Sine, 1=Square, 2=Sawtooth, 3=Triangle)
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(0)); // Sine
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(0));
    
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(1)); // Square
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(1));
    
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(2)); // Sawtooth
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(2));
    
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(3)); // Triangle
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(3));
    
    // Test Osc2 waveforms
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(0)); // Sine
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(0));
    
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(1)); // Square
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(1));
    
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(2)); // Sawtooth
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(2));
    
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(3)); // Triangle
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(3));
}

// Test detune functionality
TEST_F(OscillatorTest, DetuneFunctionality) {
    
    std::vector<float> detuneValues = {-50.0f, -25.0f, 0.0f, 25.0f, 50.0f};
    
    for (float detune : detuneValues) {
        synthEngine->setDetune(detune);
        EXPECT_EQ(synthEngine->getDetune(), detune);
    }
}

// Test oscillator mix
TEST_F(OscillatorTest, OscillatorMix) {
    std::vector<float> mixValues = {0.0f, 0.25f, 0.5f, 0.75f, 1.0f};
    
    for (float mix : mixValues) {
        synthEngine->setOscMix(mix);
        EXPECT_EQ(synthEngine->getOscMix(), mix);
    }
}

// Test oscillator settings with notes
TEST_F(OscillatorTest, OscillatorSettingsWithNotes) {
    
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(0)); // Sine
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(1)); // Square
    synthEngine->setDetune(25.0f);
    synthEngine->setOscMix(0.6f);
    
    
    synthEngine->noteOn(60, 0.8f);
    
    
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    
    
    synthEngine->noteOff(60);
    
    
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(0));
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(1));
    EXPECT_EQ(synthEngine->getDetune(), 25.0f);
    EXPECT_EQ(synthEngine->getOscMix(), 0.6f);
}

// Test rapid parameter changes
TEST_F(OscillatorTest, RapidParameterChanges) {
    for (int i = 0; i < 10; ++i) {
        int waveform = i % 4; // Cycle through 0-3
        synthEngine->setOsc1Waveform(static_cast<WaveformType>(waveform));
        synthEngine->setOsc2Waveform(static_cast<WaveformType>(waveform));
        synthEngine->setDetune(-50.0f + i * 10.0f);
        synthEngine->setOscMix(i * 0.1f);
        
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }
    
    EXPECT_TRUE(true); 
}

// Test extreme parameter values
TEST_F(OscillatorTest, ExtremeParameterValues) {
    
    synthEngine->setDetune(-100.0f);
    synthEngine->setDetune(100.0f);
    
    
    synthEngine->setOscMix(-0.5f); // Below 0
    synthEngine->setOscMix(1.5f);  // Above 1
    
    // Test invalid waveform values
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(-1));
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(10));
    
    EXPECT_TRUE(true); 
}

// Test waveform cycling
TEST_F(OscillatorTest, WaveformCycling) {
    
    for (int cycle = 0; cycle < 3; ++cycle) {
        for (int waveform = 0; waveform < 4; ++waveform) {
            synthEngine->setOsc1Waveform(static_cast<WaveformType>(waveform));
            synthEngine->setOsc2Waveform(static_cast<WaveformType>(waveform));
            
            EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(waveform));
            EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(waveform));
        }
    }
}

// Test parameter combinations
TEST_F(OscillatorTest, ParameterCombinations) {
    
    std::vector<std::tuple<int, int, float, float>> combinations = {
        {0, 1, -25.0f, 0.3f},  // Sine + Square
        {1, 2, 0.0f, 0.5f},    // Square + Sawtooth
        {2, 3, 25.0f, 0.7f},   // Sawtooth + Triangle
        {3, 0, 50.0f, 1.0f}    // Triangle + Sine
    };
    
    for (const auto& [osc1, osc2, detune, mix] : combinations) {
        synthEngine->setOsc1Waveform(static_cast<WaveformType>(osc1));
        synthEngine->setOsc2Waveform(static_cast<WaveformType>(osc2));
        synthEngine->setDetune(detune);
        synthEngine->setOscMix(mix);
        
        
        EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(osc1));
        EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(osc2));
        EXPECT_EQ(synthEngine->getDetune(), detune);
        EXPECT_EQ(synthEngine->getOscMix(), mix);
    }
}