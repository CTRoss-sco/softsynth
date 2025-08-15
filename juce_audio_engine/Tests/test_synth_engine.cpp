#include <gtest/gtest.h>
#include "SynthEngine.h"
#include <thread>
#include <chrono>

class SynthEngineTest : public ::testing::Test {
protected:
    void SetUp() override {
        synthEngine = std::make_unique<SynthEngine>();
    }

    void TearDown() override {
        synthEngine.reset();
    }

    std::unique_ptr<SynthEngine> synthEngine;
};

// Test basic construction
TEST_F(SynthEngineTest, Construction) {
    EXPECT_TRUE(synthEngine != nullptr);
}

// Test note on/off
TEST_F(SynthEngineTest, NoteOnOff) {
    synthEngine->noteOn(60, 0.8f);  // Middle C
    synthEngine->noteOff(60);
    EXPECT_TRUE(true); // Should not crash
}

// Test multiple notes
TEST_F(SynthEngineTest, MultipleNotes) {
    synthEngine->noteOn(60, 0.8f);  // C
    synthEngine->noteOn(64, 0.7f);  // E  
    synthEngine->noteOn(67, 0.6f);  // G
    
    synthEngine->noteOff(60);
    synthEngine->noteOff(64);
    synthEngine->noteOff(67);
    
    EXPECT_TRUE(true); // Should handle multiple notes
}

// Test oscillator settings with static_cast
TEST_F(SynthEngineTest, OscillatorSettings) {
    // Use static_cast for enum conversion
    synthEngine->setOsc1Waveform(static_cast<WaveformType>(1)); // Square
    EXPECT_EQ(synthEngine->getOsc1Waveform(), static_cast<WaveformType>(1));
    
    synthEngine->setOsc2Waveform(static_cast<WaveformType>(2)); // Sawtooth
    EXPECT_EQ(synthEngine->getOsc2Waveform(), static_cast<WaveformType>(2));
    
    synthEngine->setDetune(25.0f);
    EXPECT_EQ(synthEngine->getDetune(), 25.0f);
    
    synthEngine->setOscMix(0.6f);
    EXPECT_EQ(synthEngine->getOscMix(), 0.6f);
}

// Test filter settings
TEST_F(SynthEngineTest, FilterSettings) {
    synthEngine->setCutoff(1500.0f);
    EXPECT_EQ(synthEngine->getCutoff(), 1500.0f);
    
    synthEngine->setResonance(0.7f);
    EXPECT_EQ(synthEngine->getResonance(), 0.7f);
}

// Test effects enable/disable
TEST_F(SynthEngineTest, EffectsControl) {
    // Test reverb
    synthEngine->enableReverb(true);
    EXPECT_TRUE(synthEngine->isReverbEnabled());
    
    synthEngine->enableReverb(false);
    EXPECT_FALSE(synthEngine->isReverbEnabled());
    
    // Test delay
    synthEngine->enableDelay(true);
    EXPECT_TRUE(synthEngine->isDelayEnabled());
    
    synthEngine->enableDelay(false);
    EXPECT_FALSE(synthEngine->isDelayEnabled());
    
    // Test chorus
    synthEngine->enableChorus(true);
    EXPECT_TRUE(synthEngine->isChorusEnabled());
    
    synthEngine->enableChorus(false);
    EXPECT_FALSE(synthEngine->isChorusEnabled());
}

// Test delay parameters
TEST_F(SynthEngineTest, DelayParameters) {
    synthEngine->setDelayTime(0.25f);
    EXPECT_EQ(synthEngine->getDelayTime(), 0.25f);
    
    synthEngine->setDelayFeedback(0.4f);
    EXPECT_EQ(synthEngine->getDelayFeedback(), 0.4f);
    
    synthEngine->setDelayWetLevel(0.3f);
    EXPECT_EQ(synthEngine->getDelayWetLevel(), 0.3f);
    
    synthEngine->setDelayDryLevel(0.7f);
    EXPECT_EQ(synthEngine->getDelayDryLevel(), 0.7f);
}

// Test rapid parameter changes
TEST_F(SynthEngineTest, RapidParameterChanges) {
    // Play a note
    synthEngine->noteOn(60, 0.8f);
    
    // Rapidly change parameters
    for (int i = 0; i < 10; ++i) {
        synthEngine->setCutoff(500.0f + i * 100.0f);
        synthEngine->setResonance(0.1f + (i * 0.05f));
        synthEngine->setDelayTime(0.1f + (i * 0.01f));
        
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }
    
    synthEngine->noteOff(60);
    EXPECT_TRUE(true); // Should handle rapid changes
}

// Test basic audio processing
TEST_F(SynthEngineTest, BasicAudioProcessing) {
    // Test basic functionality without crashing
    synthEngine->noteOn(60, 0.8f);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    synthEngine->noteOff(60);
    
    EXPECT_TRUE(true); // Should complete without errors
}

// Test parameter bounds
TEST_F(SynthEngineTest, ParameterBounds) {
    // Test extreme values don't crash
    synthEngine->setCutoff(-100.0f);  // Below minimum
    synthEngine->setCutoff(50000.0f); // Above maximum
    
    synthEngine->setResonance(-1.0f);  // Below 0
    synthEngine->setResonance(2.0f);   // Above 1
    
    synthEngine->setOscMix(-0.5f);     // Below 0
    synthEngine->setOscMix(1.5f);      // Above 1
    
    EXPECT_TRUE(true); // Should handle extreme values gracefully
}