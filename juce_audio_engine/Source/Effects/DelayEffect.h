#pragma once
#include "Effect.h"
#include <vector>

class DelayEffect : public Effect {
private:
    std::vector<float> delayBuffer;
    int bufferSize;
    int writePosition;
    double sampleRate;
    
    // Parameters
    float delayTime;        // 0.0 - 2.0 seconds
    float feedback;         // 0.0 - 0.95 (prevent runaway)
    float wetLevel;         // 0.0 - 1.0
    float dryLevel;         // 0.0 - 1.0
    bool enabled;
    
    int getDelayInSamples() const;
    
public:
    DelayEffect();
    
    // Override Effect base class methods
    float processSample(float sample) override;
    void setSampleRate(double sr) override;
    void reset() override;
    void setParameter(int paramId, float value) override;
    bool isActive() const override;
    
    // Delay-specific methods
    void setDelayTime(float timeInSeconds);
    void setFeedback(float feedback);
    void setWetLevel(float wet);
    void setDryLevel(float dry);
    void setEnabled(bool enable);
    
    // Parameter getters
    float getDelayTime() const { return delayTime; }
    float getFeedback() const { return feedback; }
    float getWetLevel() const { return wetLevel; }
    float getDryLevel() const { return dryLevel; }
};