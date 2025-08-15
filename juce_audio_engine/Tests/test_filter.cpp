#include <gtest/gtest.h>
#include "Effects/Filter.h"
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

class FilterTest : public ::testing::Test {
protected:
    void SetUp() override {
        filter = std::make_unique<LowpassFilter>();
    }

    void TearDown() override {
        filter.reset();
    }

    std::unique_ptr<LowpassFilter> filter;
    const float tolerance = 0.001f;
    const double testSampleRate = 44100.0;
};

// Test filter initialization and defaults
TEST_F(FilterTest, FilterInitialization) {
    // Test default values
    EXPECT_EQ(filter->getCutoff(), 1000.0f);
    EXPECT_EQ(filter->getResonance(), 1.0f);
    
    // Should be able to process samples immediately
    float output = filter->processSample(0.5f);
    EXPECT_FALSE(std::isnan(output));
    EXPECT_FALSE(std::isinf(output));
}

// Test cutoff frequency parameter
TEST_F(FilterTest, CutoffFrequency) {
    filter->setSampleRate(testSampleRate);
    
    // Test setting various cutoff frequencies
    std::vector<float> cutoffFreqs = {100.0f, 440.0f, 1000.0f, 5000.0f, 15000.0f};
    
    for (float freq : cutoffFreqs) {
        filter->setCutoff(freq);
        EXPECT_EQ(filter->getCutoff(), freq);
        
        // Process some audio to ensure stability
        for (int i = 0; i < 20; ++i) {
            float sample = std::sin(2.0 * M_PI * 440.0 * i / testSampleRate);
            float output = filter->processSample(sample);
            EXPECT_FALSE(std::isnan(output));
            EXPECT_FALSE(std::isinf(output));
            EXPECT_GE(output, -2.0f);  // Reasonable bounds
            EXPECT_LE(output, 2.0f);
        }
    }
}

// Test cutoff frequency clamping
TEST_F(FilterTest, CutoffClamping) {
    // Test values below minimum get clamped to 20Hz
    filter->setCutoff(-100.0f);
    EXPECT_EQ(filter->getCutoff(), 20.0f);
    
    filter->setCutoff(5.0f);
    EXPECT_EQ(filter->getCutoff(), 20.0f);
    
    // Test values above maximum get clamped to 20kHz
    filter->setCutoff(50000.0f);
    EXPECT_EQ(filter->getCutoff(), 20000.0f);
    
    filter->setCutoff(25000.0f);
    EXPECT_EQ(filter->getCutoff(), 20000.0f);
    
    // Test valid range works
    filter->setCutoff(1500.0f);
    EXPECT_EQ(filter->getCutoff(), 1500.0f);
}

// Test resonance parameter
TEST_F(FilterTest, ResonanceParameter) {
    filter->setSampleRate(testSampleRate);
    filter->setCutoff(1000.0f);
    
    // Test various resonance values
    std::vector<float> resonanceValues = {0.5f, 1.0f, 2.0f, 5.0f, 8.0f};
    
    for (float resonance : resonanceValues) {
        filter->setResonance(resonance);
        EXPECT_EQ(filter->getResonance(), resonance);
        
        // Process audio and check for stability
        for (int i = 0; i < 50; ++i) {
            float sample = std::sin(2.0 * M_PI * 1000.0 * i / testSampleRate);
            float output = filter->processSample(sample);
            EXPECT_FALSE(std::isnan(output));
            EXPECT_FALSE(std::isinf(output));
            EXPECT_GE(output, -5.0f);  // Allow for resonance boost
            EXPECT_LE(output, 5.0f);
        }
    }
}

// Test resonance clamping
TEST_F(FilterTest, ResonanceClamping) {
    // Test values below minimum get clamped to 0.1
    filter->setResonance(-0.5f);
    EXPECT_EQ(filter->getResonance(), 0.1f);
    
    filter->setResonance(0.05f);
    EXPECT_EQ(filter->getResonance(), 0.1f);
    
    // Test values above maximum get clamped to 10.0
    filter->setResonance(15.0f);
    EXPECT_EQ(filter->getResonance(), 10.0f);
    
    filter->setResonance(20.0f);
    EXPECT_EQ(filter->getResonance(), 10.0f);
    
    // Test valid range works
    filter->setResonance(3.5f);
    EXPECT_EQ(filter->getResonance(), 3.5f);
}

// Test sample rate setting
TEST_F(FilterTest, SampleRateSetting) {
    std::vector<double> sampleRates = {22050.0, 44100.0, 48000.0, 88200.0, 96000.0};
    
    for (double sampleRate : sampleRates) {
        filter->setSampleRate(sampleRate);
        filter->setCutoff(1000.0f);
        filter->setResonance(1.0f);
        
        // Process audio at different sample rates
        for (int i = 0; i < 20; ++i) {
            float sample = std::sin(2.0 * M_PI * 440.0 * i / sampleRate);
            float output = filter->processSample(sample);
            EXPECT_FALSE(std::isnan(output));
            EXPECT_FALSE(std::isinf(output));
        }
    }
}

// Test filter reset functionality
TEST_F(FilterTest, FilterReset) {
    filter->setSampleRate(testSampleRate);
    filter->setCutoff(1000.0f);
    filter->setResonance(2.0f);
    
    // Process some samples to build up filter state
    for (int i = 0; i < 100; ++i) {
        filter->processSample(1.0f);
    }
    
    // Reset the filter
    filter->reset();
    
    // Process a sample after reset
    float resetOutput = filter->processSample(0.0f);
    
    // Create a fresh filter for comparison
    LowpassFilter freshFilter;
    freshFilter.setSampleRate(testSampleRate);
    freshFilter.setCutoff(1000.0f);
    freshFilter.setResonance(2.0f);
    float freshOutput = freshFilter.processSample(0.0f);
    
    // Should be nearly identical
    EXPECT_NEAR(resetOutput, freshOutput, tolerance);
}
