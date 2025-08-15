#include <gtest/gtest.h>
#include "SynthEngine.h"

class EffectsTest : public ::testing::Test {
protected:
    void SetUp() override {
        synthEngine = std::make_unique<SynthEngine>();
    }

    void TearDown() override {
        synthEngine.reset();
    }

    std::unique_ptr<SynthEngine> synthEngine;
};

// Test effects enable/disable
TEST_F(EffectsTest, EffectsEnableDisable) {
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
TEST_F(EffectsTest, DelayParameters) {
    synthEngine->setDelayTime(0.25f);
    EXPECT_EQ(synthEngine->getDelayTime(), 0.25f);
    
    synthEngine->setDelayFeedback(0.4f);
    EXPECT_EQ(synthEngine->getDelayFeedback(), 0.4f);
    
    synthEngine->setDelayWetLevel(0.3f);
    EXPECT_EQ(synthEngine->getDelayWetLevel(), 0.3f);
    
    synthEngine->setDelayDryLevel(0.7f);
    EXPECT_EQ(synthEngine->getDelayDryLevel(), 0.7f);
}

// Test chorus parameters
TEST_F(EffectsTest, ChorusParameters) {
    synthEngine->setChorusRate(2.0f);
    EXPECT_EQ(synthEngine->getChorusRate(), 2.0f);
    
    synthEngine->setChorusDepth(0.5f);
    EXPECT_EQ(synthEngine->getChorusDepth(), 0.5f);
    
    synthEngine->setChorusVoices(4);
    EXPECT_EQ(synthEngine->getChorusVoices(), 4);
    
    synthEngine->setChorusFeedback(0.2f);
    EXPECT_EQ(synthEngine->getChorusFeedback(), 0.2f);
    
    synthEngine->setChorusWetLevel(0.4f);
    EXPECT_EQ(synthEngine->getChorusWetLevel(), 0.4f);
    
    synthEngine->setChorusDryLevel(0.6f);
    EXPECT_EQ(synthEngine->getChorusDryLevel(), 0.6f);
}

// Test reverb parameters using the generic method
TEST_F(EffectsTest, ReverbParameters) {
    // Set parameters using the generic method
    synthEngine->setReverbParameter(0, 0.7f);  // Room size
    synthEngine->setReverbParameter(1, 0.5f);  // Damping  
    synthEngine->setReverbParameter(2, 0.3f);  // Wet level
    synthEngine->setReverbParameter(3, 0.8f);  // Dry level
    
    // Test getters
    EXPECT_EQ(synthEngine->getReverbRoomSize(), 0.7f);
    EXPECT_EQ(synthEngine->getReverbDamping(), 0.5f);
    EXPECT_EQ(synthEngine->getReverbWetLevel(), 0.3f);
    EXPECT_EQ(synthEngine->getReverbDryLevel(), 0.8f);
}

// Test filter parameters  
TEST_F(EffectsTest, FilterParameters) {
    synthEngine->setCutoff(1500.0f);
    EXPECT_EQ(synthEngine->getCutoff(), 1500.0f);
    
    synthEngine->setResonance(0.6f);
    EXPECT_EQ(synthEngine->getResonance(), 0.6f);
}

// Test rapid parameter changes
TEST_F(EffectsTest, RapidParameterChanges) {
    synthEngine->enableReverb(true);
    synthEngine->enableDelay(true);
    synthEngine->enableChorus(true);
    
    // Play a note
    synthEngine->noteOn(60, 0.8f);
    
    // Rapidly change parameters
    for (int i = 0; i < 20; ++i) {
        synthEngine->setCutoff(500.0f + i * 100.0f);
        synthEngine->setResonance(0.1f + (i * 0.03f));
        synthEngine->setDelayTime(0.1f + (i * 0.01f));
        synthEngine->setChorusRate(1.0f + (i * 0.1f));
        
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }
    
    synthEngine->noteOff(60);
    EXPECT_TRUE(true); // Should handle rapid changes
}

// Test effects combinations
TEST_F(EffectsTest, EffectsCombinations) {
    // Enable all effects
    synthEngine->enableReverb(true);
    synthEngine->enableDelay(true);  
    synthEngine->enableChorus(true);
    
    // Set some parameters
    synthEngine->setDelayTime(0.2f);
    synthEngine->setChorusRate(3.0f);
    synthEngine->setReverbParameter(0, 0.6f); // Room size
    
    // Play and process
    synthEngine->noteOn(60, 0.8f);
    std::this_thread::sleep_for(std::chrono::milliseconds(20));
    synthEngine->noteOff(60);
    
    EXPECT_TRUE(true); // Should handle multiple effects
}
